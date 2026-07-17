new_source <- function(type, ...) {
  structure(list(...), class = c(paste0(type, "_source"), "quiver_source"))
}

is_quiver_source <- function(x) inherits(x, "quiver_source")

source_list_skills <- function(source) UseMethod("source_list_skills")

source_skill_files <- function(source, skill) UseMethod("source_skill_files")

source_copy_file <- function(source, skill, file, dest) {
  UseMethod("source_copy_file")
}

source_identifier <- function(source) UseMethod("source_identifier")

ensure_parent_dir <- function(dest) {
  fs::dir_create(fs::path_dir(dest), recurse = TRUE)
}
