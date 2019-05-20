
#' Debug ggplot2 functions
#'
#' Debugs functions or [ggplot2::ggproto()] methods in ggplot2. Expressions are
#' evaluated in the ggplot2 namespace, so they can be unexported functions as well.
#' Use `undebug_all()` to clear all debugged functions. Note that ggplot2 need not
#' be attached to use these functions.
#'
#' @param ... One or more functions or [ggplot2::ggproto()] methods (see [ggdebug_one()])
#'
#' @export
#' @importFrom rlang !!
#'
#' @examples
#' library(ggplot2)
#' # the problem is in ggplot() or GeomPoint$draw_panel()
#' ggdebug(ggplot, GeomPoint$draw_panel)
#' # ggplot(mpg, aes(cty, hwy)) + geom_point()
#' # definitely not in ggplot(), but need to take another look
#' ggundebug(ggplot)
#' # ggplot(mpg, aes(cty, hwy)) + geom_point()
#' # stop debugging
#' ggundebug_all()
#'
ggdebug <- function(...) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) ggdebug_one(!!x))
  invisible()
}

#' @rdname ggdebug
#' @export
ggundebug <- function(...) {
  exprs <- rlang::quos(...)
  lapply(exprs, function(x) ggundebug_one(!!x))
  invisible()
}

#' @rdname ggdebug
#' @export
ggundebug_all <- function(...) {
  lapply(names(current_debugs), function(x) undebug_and_unregister(current_debugs[[x]]))
  invisible()
}

#' Debug one ggplot2 function
#'
#' @param fun A function or [ggplot2::ggproto()] method.
#' @param ... Passed to [debug()], or [debugonce()]
#'
#' @export
#' @importFrom rlang !! enquo
#'
ggdebug_one <- function(fun, ...) {
  debug_and_register(find_ggplot_function(!!enquo(fun)), ...)
}

#' @rdname ggdebug_one
#' @export
ggundebug_one <- function(fun, ...) {
  undebug_and_unregister(find_ggplot_function(!!enquo(fun)), ...)
}


# Internals ---------------------

current_debugs <- new.env(parent = emptyenv())

debug_and_register <- function(fun, ...) {
  hash <- digest::digest(list(fun, ...))
  current_debugs[[hash]] <- fun
  debug(fun, ...)
}

undebug_and_unregister <- function(fun, ...) {
  hash <- digest::digest(list(fun, ...))
  if(hash %in% names(current_debugs)) {
    rm(list = hash, envir = current_debugs)
  }
  undebug(fun, ...)
}
