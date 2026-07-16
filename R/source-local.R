#' Reference a local directory as a skill source
#'
#' Treats `path` as a checkout of a skills repository: skills live at
#' `path/skills/<name>/`, each with a `SKILL.md`, same layout as a 'GitHub'
#' source. Useful for developing a skill locally, or installing from a
#' repository you've already cloned.
#'
#' @param path Path to the directory containing a `skills/` folder.
#'
#' @return A `local_source` object, for use with [quiver_install()].
#'
#' @example man-roxygen/ex-setup-source.R
#' @examples
#' source
#'
#' @export
local_source <- function(path) {
  if (!fs::dir_exists(path)) {
    cli::cli_abort("{.arg path} does not exist: {.path {path}}")
  }
  new_source("local", path = fs::path_abs(path))
}

#' @exportS3Method
source_list_skills.local_source <- function(source) {
  root <- fs::path(source$path, "skills")
  if (!fs::dir_exists(root)) {
    return(character())
  }
  candidates <- fs::dir_ls(root, type = "directory")
  has_skill_md <- fs::file_exists(fs::path(candidates, "SKILL.md"))
  sort(fs::path_file(candidates[has_skill_md]))
}

#' @exportS3Method
source_skill_files.local_source <- function(source, skill) {
  skill_root <- fs::path(source$path, "skills", skill)
  if (!fs::dir_exists(skill_root)) {
    cli::cli_abort("No files found for skill {.val {skill}}.")
  }

  files <- fs::dir_ls(skill_root, recurse = TRUE, type = "file")
  relpath <- as.character(fs::path_rel(files, start = skill_root))

  data.frame(
    abspath = as.character(files),
    relpath = relpath,
    stringsAsFactors = FALSE
  )
}

#' @exportS3Method
source_copy_file.local_source <- function(source, skill, file, dest) {
  fs::dir_create(fs::path_dir(dest), recurse = TRUE)
  fs::file_copy(file$abspath, dest, overwrite = TRUE)
  invisible(dest)
}

#' @exportS3Method
source_identifier.local_source <- function(source) {
  list(type = "local", path = as.character(source$path))
}
