
#' Trace ggplot2 functions
#'
#' Traces functions or [ggplot2::ggproto()] methods in ggplot2. Expressions are
#' evaluated in the ggplot2 namespace, so they can be unexported functions as well.
#' Use `gguntrace_all()` to clear all traced functions. Note that ggplot2 need not
#' be attached to use these functions. These functions do not use
#' [trace()] and [untrace()], because these functions do not work with ggproto methods.
#'
#' @inheritParams ggtrace_one
#' @param ... One or more functions or [ggplot2::ggproto()] methods (see [ggtrace_one()])
#'
#' @export
#' @importFrom rlang !! quo
#'
ggtrace <- function(..., on_enter = quo(NULL), on_exit = quo(NULL)) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) ggtrace_one(!!x, on_enter = on_enter, on_exit = on_exit))
  invisible()
}

#' @rdname ggdebug
#' @export
gguntrace <- function(...) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) gguntrace_one(!!x))
  invisible()
}

#' @rdname ggdebug
#' @export
gguntrace_all <- function(...) {
  lapply(names(current_traces), function(x) untrace_and_unregister(!!current_traces[[x]]))
  invisible()
}


#' Trace one ggplot2 function
#'
#' @inheritParams ggdebug_one
#' @param on_enter A [rlang::quo()] to evaluate on entering the `fun`.
#' @param on_exit A [rlang::quo()] to evaluate on exiting the `fun`.
#'
#' @export
#'
#' @importFrom rlang quo
#'
ggtrace_one <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL)) {
  trace_and_register(
    !!enquo(fun),
    on_enter = rlang::as_quosure(on_enter),
    on_exit = rlang::as_quosure(on_exit)
  )
}

#' @rdname ggtrace_one
#' @export
gguntrace_one <- function(fun) {
  untrace_and_unregister(!!enquo(fun))
}


# Internals ---------------------

current_traces <- new.env(parent = emptyenv())

trace_and_register <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL), action = "trace") {
  action <- match.arg(action, c("trace", "untrace"))

  fun_quo <- enquo(fun)
  fun_label <- rlang::as_label(fun_quo)

  fun <- rlang::eval_tidy(fun_quo, data = getNamespace("ggplot2"))

  # keep track of the function
  # have to do it based on fun label because we do a lot of
  # modifying of functions
  hash <- digest::digest(fun_label)
  if(action == "trace") {
    current_traces[[hash]] <- fun_quo
  } else if(hash %in% names(current_traces)) {
    rm(list = hash, envir = current_traces)
  }

  if (inherits(fun, "ggproto_method")) {
    wrapper_fun <- fun
    wrapper_env <- environment(wrapper_fun)
    ggproto_object <- wrapper_env$self
    inner_fun <- wrapper_env$f

    wrapper_fun_name <- find_function_name(ggproto_object, inner_fun)
    if(is.na(wrapper_fun_name)) stop("Could not resolve ggproto method name for ", fun_label)

    # apply on_enter and on_exit or remove
    if(action == "trace") {
      new_fun <- traced_function(inner_fun, on_enter, on_exit)
    } else {
      new_fun <- untraced_function(inner_fun)
    }

    # reassign the function
    assign(wrapper_fun_name, new_fun, envir = ggproto_object)
  } else {
    function_env <- environment(fun)
    fun_name <- find_function_name(function_env, fun)
    if(is.na(fun_name)) stop("Could not resolve function name for ", fun_label)

    # apply on_enter and on_exit
    if(action == "trace") {
      new_fun <- traced_function(fun, on_enter, on_exit)
    } else {
      new_fun <- untraced_function(fun)
    }

    # reassign the function
    assign(fun_name, new_fun, envir = function_env)
  }
}

untrace_and_unregister <- function(fun) {
  trace_and_register(!!enquo(fun), action = "untrace")
}

traced_function <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL)) {
  if(is_traced_function(fun)) {
    fun <- untraced_function(fun)
  }

  new_fun <- function_with_bracket(fun)
  fun_body <- body(new_fun)

  length_body <- length(fun_body)
  fun_body[[length_body + 1]] <- fun_body[[length_body]]
  fun_body[[length_body + 2]] <- fun_body[[length_body]]
  fun_body[3:(length_body + 1)] <- fun_body[2:length_body]
  fun_body[[2]] <- substitute(rlang::eval_tidy(on_enter), environment())
  fun_body[[length_body + 1]] <- substitute(on.exit(rlang::eval_tidy(on_exit), add = TRUE), environment())

  body(new_fun) <- fun_body

  attr(new_fun, ".original_function") <- fun
  new_fun
}

is_traced_function <- function(fun) {
  !is.null(attr(fun, ".original_function"))
}

untraced_function <- function(fun) {
  original_fun <- attr(fun, ".original_function")
  if(!is.null(original_fun)) {
    original_fun
  } else {
    fun
  }
}

find_function_name <- function(envir, fun) {
  fun_name <- NA_character_
  for(name in names(envir)) {
    obj <- get(name, envir = envir, inherits = FALSE)
    if(identical(obj, fun)) {
      fun_name <- name
      break
    }
  }
  fun_name
}

# function_with_bracket(function(x) identity(x))
# function_with_bracket(function(x) x)
# function_with_bracket(function(x) {x})
function_with_bracket <- function(fun) {
  fun_body <- body(fun)
  if(!rlang::quo_is_call(rlang::as_quosure(fun_body, environment(fun)), "{")) {
    body(fun) <- call("{", fun_body)
  }
  fun
}
