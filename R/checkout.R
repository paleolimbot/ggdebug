
#' Checkout a repo and replace a directory with its contents
#'
#' This is intended for use with RStudio cloud to test different versions of ggplot2
#' with different versions of R.
#'
#' @param repo The repo from which to fetch ggplot2 source
#' @param path The path that should be replaced
#' @param ignore Files to ignore when removing all files in the target directory
#'
#' @export
#'
ggcheckout <- function(repo = "tidyverse/ggplot2", path = tempfile(), ignore = c("\\.Renviron", "\\.Rprofile")) {
  path <- normalizePath(path, mustWork = FALSE)

  # this is all shamelessly copied from remotes:::install_remote()
  remote <- remotes:::github_remote(repo)
  bundle <- remotes:::remote_download(remote)
  on.exit(unlink(bundle), add = TRUE)
  source <- remotes:::source_pkg(bundle, subdir = remote$subdir)
  on.exit(unlink(source, recursive = TRUE), add = TRUE)

  if(file.exists(path) && !dir.exists(path)) stop(path, " is a file")

  if(!dir.exists(path) || usethis::ui_yeah("Do you want to DELETE EVERYTHING at `{path}` and replace it with the repo `{repo}?`")) {
    if(!dir.exists(path)) {
      dir.create(path)
    } else {
      current_files <- fs::dir_ls(path, type = "file", all = TRUE, recursive = TRUE)
      current_dirs <- fs::dir_ls(path, type = "directory", recursive = TRUE)

      if(length(current_files) > 2000) {
        stop("Won't do a directory replace with a dir that contains more than 2,000 files")
      }

      ignore_pattern <- paste0("(", ignore, ")", collapse = "|")
      current_files <- current_files[!grepl(ignore_pattern, current_files)]
      current_dirs <- current_dirs[!grepl(ignore_pattern, current_dirs)]
      unlink(current_files)
      unlink(current_dirs, recursive = TRUE)
    }

    src_files <- fs::dir_ls(source, all = TRUE, type = "file")
    fs::file_copy(src_files, path)

    src_dirs <- fs::dir_ls(source, all = TRUE, type = "directory")
    lapply(src_dirs, function(x) fs::dir_copy(x, path))

    path
  }
}
