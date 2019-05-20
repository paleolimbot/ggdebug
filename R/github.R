
#' Information about the currently installed version of ggplot2
#'
#' @param include_base,dependencies See [sessioninfo::package_info()]
#' @param path A path to a file within ggplot2
#' @param repo A repository and reference, like `tidyverse/ggplot2` or `tidyverse/ggplot2@v3.1.1`.
#' @param INSTALL_opts,... Options for install. Using --with-keep.source allows
#'   the functions in this section to find the GitHub repo from whence
#'   ggplot2 came.
#'
#' @export
#'
#' @examples
#' # install a specific version from GitHub with source attached
#' # gginstall("tidyverse/ggplot2")
#'
#' # get information about the currently installed version
#' gginfo()
#' ggrepo()
#'
#' # browse the source on GitHub
#' ggbrowse()
#' ggbrowse("R/aes.r")
#'
#' # can also pass functions like in ggdebug()
#' ggbrowse(aes)
#' ggbrowse(FacetWrap$map_data)
#'
gginfo <- function(include_base = FALSE, dependencies = FALSE) {
  sessioninfo::package_info("ggplot2", include_base = include_base, dependencies = dependencies)
}

#' @rdname gginfo
#' @export
ggrepo <- function() {
  info <- gginfo(include_base = FALSE, dependencies = FALSE)
  if(info$source == "local") {
    local_r_dir <- dirname(srcref_as_tibble(attr(ggplot2::ggplot, "srcref"))$src_file)
    if(is.na(local_r_dir)) return(NA_character_)

    local_dir <- dirname(local_r_dir)
    repo_url <- git2r::remote_url(local_dir, remote = "origin")
    repo_ref <- git2r::last_commit(local_dir)$sha
    repo_name <- stringr::str_extract(repo_url, "[a-z0-9A-Z]+/ggplot2")
    stringr::str_c(repo_name, "@", repo_ref)
  } else if(stringr::str_detect(info$source, "^CRAN")) {
    version <- info$ondiskversion
    stringr::str_c("cran/ggplot2@", version)
  } else if(stringr::str_detect(info$source, "^Github")) {
    stringr::str_match(info$source, "\\(([^\\)]+)\\)")[, 2]
  } else {
    NA_character_
  }
}

#' @rdname gginfo
#' @export
ggurl <- function(path = "/", repo = ggrepo()) {
  path <- ggpath(!!enquo(path))
  repo <- repo_split(repo)
  is_directory <- stringr::str_ends(path, "/")
  url_type <- if(is_directory) "tree" else "blob"
  prefix <- if(stringr::str_starts(path, "/")) "" else "/"
  stringr::str_c("https://github.com/", repo["repo"], "/", url_type, "/", repo["ref"], prefix, path)
}

#' @rdname gginfo
#' @export
ggbrowse <- function(path = "/", repo = ggrepo()) {
  path <- enquo(path)
  path_label <- rlang::as_label(path)
  url <- ggurl(path = !!path, repo = repo)
  if(is.na(url)) stop("Could not find URL for object ", path_label)
  if(interactive()) utils::browseURL(url)
  invisible(url)
}

#' @rdname gginfo
#' @export
ggpath <- function(path = "/") {
  path <- enquo(path)
  path_label <- rlang::as_label(path)
  path_eval <- try(rlang::eval_tidy(path), silent = TRUE)
  if(!inherits(path_eval, "try-error") && is.character(path_eval)) {
    path_eval[1]
  } else {
    obj <- find_ggplot_function(!!path)
    src <- srcref_as_tibble(attr(obj, "srcref"))
    file <- src$src_file
    if(is.na(file)) stop("Could not find file for object ", path_label)

    dir <- stringr::str_remove(stringr::str_extract(src$src_file, "ggplot2/.*$"), "^ggplot2/")
    stringr::str_c(dir, "#L", src$src_line_start, "-L", src$src_line_end)
  }
}

#' @rdname gginfo
#' @export
gginstall <- function(repo = "tidyverse/ggplot2", ..., INSTALL_opts = "--with-keep.source") {
  remotes::install_github(
    repo,
    ...,
    INSTALL_opts = INSTALL_opts
  )
}

repo_split <- function(repo) {
  parts <- stringr::str_split(repo, "@")[[1]]
  if(is.na(parts[2])) {
    ref <- "master"
  } else {
    ref <- parts[2]
  }

  c(repo = parts[1], ref = ref)
}

#' @importFrom purrr %||%
srcref_as_tibble <- function(x) {
  if(is.null(x)) {
    tibble::tibble(
      src_file = NA_character_,
      src_line_start = NA_integer_,
      src_line_end = NA_integer_
    )
  } else {
    src_file <- attr(x, "srcfile") %||% emptyenv()
    tibble::tibble(
      src_file = get0("filename", envir = src_file, inherits = FALSE) %||% NA_character_,
      src_line_start = x[1],
      src_line_end = x[3]
    )
  }
}
