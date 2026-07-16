#' Install a skill from a source
#'
#' Copies one or more skills from `source` into the directory the given
#' `agent` reads skills from, at project or user scope. Already installed
#' skills are left untouched unless `force = TRUE`.
#'
#' @param skill Character vector of skill names available in `source`,
#'   e.g. the names of the subdirectories under `skills/` for a
#'   [local_source()].
#' @param source A skill source, e.g. created with [local_source()].
#' @param agent Which agent to install for; see [quiver_agents()].
#' @param scope `"project"` installs under `path`; `"user"` installs into
#'   the agent's directory in the user's home, regardless of `path`.
#' @param path Project directory to install into when `scope = "project"`.
#'   Defaults to the current directory.
#' @param force If `FALSE` (the default), an already-installed skill is left
#'   as-is. If `TRUE`, it is deleted and re-installed, discarding any local
#'   edits.
#'
#' @return The path(s) to the installed skill folder(s), invisibly.
#'
#' @example man-roxygen/ex-setup-source.R
#' @examples
#' project <- tempfile("quiver-project")
#' dir.create(project)
#'
#' quiver_install("demo-skill", source, agent = "claude", path = project)
#'
#' @export
quiver_install <- function(
  skill,
  source,
  agent = quiver_agents(),
  scope = c("project", "user"),
  path = ".",
  force = FALSE
) {
  if (!is.character(skill) || length(skill) == 0) {
    cli::cli_abort("{.arg skill} must be a non-empty character vector.")
  }
  if (!is_quiver_source(source)) {
    cli::cli_abort(c(
      "{.arg source} must be created by a source constructor,",
      "i" = "e.g. {.fn local_source}."
    ))
  }
  agent <- match.arg(agent)
  scope <- match.arg(scope)

  available <- source_list_skills(source)
  unknown <- setdiff(skill, available)
  if (length(unknown) > 0) {
    cli::cli_abort(c(
      "x" = "Unknown skill{?s}: {.val {unknown}}",
      "i" = "Available in this source: {.val {available}}"
    ))
  }

  cli::cli_h1("Installing {length(skill)} skill{?s} for {.val {agent}}")
  dest_dirs <- vapply(
    skill,
    quiver_install_one,
    character(1),
    source = source,
    agent = agent,
    scope = scope,
    path = path,
    force = force
  )
  invisible(unname(dest_dirs))
}

quiver_install_one <- function(skill, source, agent, scope, path, force) {
  dest <- skill_dir(agent, scope, path, skill)

  if (fs::dir_exists(dest) && !force) {
    cli::cli_alert_info(paste(
      "{.field {skill}} already exists at {.path {dest}} \u2014 skipping",
      "({.code force = TRUE} to overwrite)"
    ))
    return(as.character(dest))
  }

  if (fs::dir_exists(dest)) {
    fs::dir_delete(dest)
  }

  files <- source_skill_files(source, skill)
  fs::dir_create(dest, recurse = TRUE)
  tryCatch(
    for (i in seq_len(nrow(files))) {
      source_copy_file(
        source,
        skill,
        files[i, ],
        fs::path(dest, files$relpath[i])
      )
    },
    error = function(e) {
      fs::dir_delete(dest)
      stop(e)
    }
  )

  checksum <- compute_skill_checksum(dest)
  update_manifest_entry(agent, scope, path, skill, source, checksum)
  cli::cli_alert_success("Installed {.field {skill}} to {.path {dest}}")
  as.character(dest)
}
