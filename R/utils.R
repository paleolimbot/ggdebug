
#' Get all methods of a ggproto object
#'
#' @param obj A ggplot2 ggproto object.
#' @param ignore Method names to ignore
#' @param include_super Follow superclass ggproto objects
#' @param ns Namespace from which objects should be sourced
#'
#' @return A quosures that can be spliced (`!!!`) into [ggdebug()] or [ggtrace()]
#' @export
#'
ggmethods <- function(obj, ns = getNamespace("ggplot2"), ignore = "super", include_super = TRUE) {
  obj_quo <- enquo(obj)
  obj_label <- rlang::as_label(obj_quo)
  obj <- ns[[obj_label]]
  if(is.null(obj)) stop("Could not find ", obj_label, " in the ggplot2 namespace")
  if(!ggplot2::is.ggproto(obj)) stop(obj_label, " is not a ggproto object")
  names <- setdiff(names(obj), ignore)
  values <- lapply(names, function(x) obj[[x]])
  is_method <- vapply(values, inherits, "ggproto_method", FUN.VALUE = logical(1))
  method_names <- paste(obj_label, names, sep = "$")[is_method]
  method_exprs <- parse(text = method_names)
  method_quos <- rlang::as_quosures(method_exprs, env = ns)

  if(include_super && !identical(obj$super, NULL)) {
    super_obj <- obj$super()
    super_name <- class(super_obj)[1]
    super_sym <- rlang::sym(super_name)
    c(
      do.call(ggmethods, list(super_sym, ns = ns, ignore = ignore, include_super = TRUE)),
      method_quos
    )
  } else {
    method_quos
  }
}

#' @rdname ggmethods
#' @export
ggeverything <- function(ns = getNamespace("ggplot2"),
                         ignore = c("$.ggproto", "make_proto_method", "[[.ggproto",
                                    "fetch_ggproto", "[[[.ggproto",
                                     "mean_cl_boot", "median_hilow", "annotation_id",
                                     "mean_sdl", "mean_cl_normal")) {
  objects <- lapply(names(ns), function(x) ns[[x]])
  is_fun <- vapply(objects, is.function, logical(1))
  is_ggproto <- vapply(objects, ggplot2::is.ggproto, logical(1))
  include <- !(names(ns) %in% ignore)

  name_to_quosure <- function(name) rlang::as_quosure(rlang::sym(name), env = ns)

  funs_quos <- rlang::as_quosures(lapply(names(ns)[is_fun & include], name_to_quosure))
  ggproto_quos <- lapply(names(ns)[is_ggproto& include], name_to_quosure)
  methods_quos <- do.call(c, lapply(ggproto_quos, ggmethods, include_super = FALSE))

  c(funs_quos, methods_quos)
}

find_ggplot_function <- function(fun, ns = getNamespace("ggplot2")) {
  fun <- rlang::eval_tidy(enquo(fun), data = ns)
  if (inherits(fun, "ggproto_method")) {
    environment(fun)$f
  } else {
    fun
  }
}
