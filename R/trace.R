
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
ggtrace <- function(..., on_enter = quo(NULL), on_exit = quo(NULL), .trace = new.env(parent = emptyenv())) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) ggtrace_one(!!x, on_enter = on_enter, on_exit = on_exit, .trace = .trace))
  invisible()
}

#' @rdname ggtrace
#' @export
gguntrace <- function(...) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) gguntrace_one(!!x))
  invisible()
}

#' @rdname ggtrace
#' @export
gguntrace_all <- function(...) {
  lapply(names(current_traces), function(x) untrace_and_unregister(!!current_traces[[x]]))
  invisible()
}

#' @rdname ggtrace
#' @export
ggtrace_tree <- function(...) {
  ggtrace(
    ...,
    on_enter = quo(ggtrace_tree_enter(.debug)),
    on_exit = quo(ggtrace_tree_exit(.debug))
  )
}

#' @rdname ggtrace
#' @export
ggtrace_stack <- function(...) {
  ggtrace(
    ...,
    on_enter = quo(ggtrace_stack_enter(.debug))
  )
}

ggtrace_stack_enter <- function(.debug) {
  message("-- ", .debug$.fun, "()")
  print(rlang::trace_back())
}

ggtrace_tree_enter <- function(.debug) {
  .trace <- .debug$.trace
  if("depth" %in% names(.trace)) {
    .trace$depth <- .trace$depth + 1
  } else {
    .trace$depth <- 1
  }

  spaces <- paste0(rep("--", max(.trace$depth, 0)), collapse = "")
  message(spaces, " ", .debug$.fun, "()")
}

ggtrace_tree_exit <- function(.debug) {
  .trace <- .debug$.trace

  if("depth" %in% names(.trace)) {
    .trace$depth <- .trace$depth - 1
  } else {
    .trace$depth <- 0
  }
}

#' Trace one ggplot2 function
#'
#' @inheritParams ggdebug_one
#' @param on_enter A [rlang::quo()] to evaluate on entering the `fun`.
#' @param on_exit A [rlang::quo()] to evaluate on exiting the `fun`.
#' @param .trace An environment that will be available to `on_enter` and `on_exit` as `.trace`.
#'
#' @export
#'
#' @importFrom rlang quo
#'
ggtrace_one <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL), .trace = new.env(parent = emptyenv())) {
  trace_and_register(
    !!enquo(fun),
    on_enter = rlang::as_quosure(on_enter),
    on_exit = rlang::as_quosure(on_exit),
    .trace = .trace
  )
}

#' @rdname ggtrace_one
#' @export
gguntrace_one <- function(fun) {
  untrace_and_unregister(!!enquo(fun))
}


# Internals ---------------------

current_traces <- new.env(parent = emptyenv())

trace_and_register <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL),
                               .trace = new.env(parent = emptyenv()), action = "trace") {
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
      new_fun <- traced_function(inner_fun, on_enter, on_exit, .fun = fun_label, .trace = .trace)
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
      new_fun <- traced_function(fun, on_enter, on_exit, .fun = fun_label, .trace = .trace)
    } else {
      new_fun <- untraced_function(fun)
    }

    # reassign the function (need to unlock namespace first)
    locked_env <- environmentIsLocked(function_env)
    if(locked_env) unlockBinding(fun_name, function_env)
    assign(fun_name, new_fun, envir = function_env)
    if(locked_env) lockBinding(fun_name, function_env)
  }
}

untrace_and_unregister <- function(fun) {
  trace_and_register(!!enquo(fun), action = "untrace")
}

traced_function <- function(fun, on_enter = quo(NULL), on_exit = quo(NULL),
                            .fun = ".fun", .trace = new.env(parent = emptyenv())) {
  if(is_traced_function(fun)) {
    fun <- untraced_function(fun)
  }

  enter_exit_env <- new.env(parent = emptyenv())
  enter_exit_env$on_enter <- on_enter
  enter_exit_env$on_exit <- on_exit
  enter_exit_env$create_mask <- function(env = rlang::caller_env()) {
    mask <- rlang::as_data_mask(env)
    mask$.debug <- rlang::as_data_pronoun(list(.fun = .fun, .trace = .trace))
    mask
  }

  new_fun <- function_with_bracket(fun)
  fun_body <- body(new_fun)

  length_body <- length(fun_body)
  fun_body[[length_body + 1]] <- fun_body[[length_body]]
  fun_body[[length_body + 2]] <- fun_body[[length_body]]
  fun_body[3:(length_body + 1)] <- fun_body[2:length_body]
  fun_body[[2]] <- substitute(
    rlang::eval_tidy(on_enter, data = create_mask()),
    enter_exit_env
  )
  fun_body[[length_body + 1]] <- substitute(
    on.exit(rlang::eval_tidy(on_exit, data = create_mask()), add = TRUE),
    enter_exit_env
  )

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
