
find_ggplot_function <- function(fun, ns = getNamespace("ggplot2")) {
  fun <- rlang::eval_tidy(enquo(fun), data = ns)
  if (inherits(fun, "ggproto_method")) {
    environment(fun)$f
  } else {
    fun
  }
}
