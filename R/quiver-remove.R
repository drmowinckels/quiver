#' Remove installed skills
#'
#' Deletes previously installed skill folders. A skill that has been
#' hand-edited locally (its on-disk checksum no longer matches what
#' [quiver_install()] installed) is left in place unless `force = TRUE`.
#' When the last skill for an agent/scope is removed, the manifest file
#' (and the now-empty skills directory) are cleaned up too.
#'
#' @param skill Character vector of skill names to remove.
#' @inheritParams quiver_install
#'
#' @return The names of the skills that were removed, invisibly.
#'
#' @example man-roxygen/ex-setup-source.R
#' @examples
#' project <- tempfile("quiver-project")
#' dir.create(project)
#' quiver_install("demo-skill", source, agent = "claude", path = project)
#'
#' quiver_remove("demo-skill", agent = "claude", path = project)
#'
#' @export
quiver_remove <- function(
  skill,
  agent = quiver_agents(),
  scope = c("project", "user"),
  path = ".",
  force = FALSE
) {
  if (!is.character(skill) || length(skill) == 0) {
    cli::cli_abort("{.arg skill} must be a non-empty character vector.")
  }
  agent <- match.arg(agent)
  scope <- match.arg(scope)

  manifest <- read_manifest(agent, scope, path)
  removed <- character()

  for (s in skill) {
    if (quiver_remove_one(s, agent, scope, path, force)) {
      manifest$skills[[s]] <- NULL
      removed <- c(removed, s)
    }
  }

  finalize_removal_manifest(agent, scope, path, manifest)

  invisible(removed)
}

quiver_remove_one <- function(skill, agent, scope, path, force) {
  dest <- skill_dir(agent, scope, path, skill)
  if (!fs::dir_exists(dest)) {
    cli::cli_alert_info(
      "{.field {skill}} is not installed for {.val {agent}} ({.val {scope}})"
    )
    return(FALSE)
  }

  modified <- skill_is_modified(agent, scope, path, skill)
  if (!isFALSE(modified) && !force) {
    cli::cli_alert_warning(paste(
      "{.field {skill}} has local changes or is untracked \u2014 skipping",
      "({.code force = TRUE} to remove anyway)"
    ))
    return(FALSE)
  }

  fs::dir_delete(dest)
  cli::cli_alert_success("Removed {.field {skill}}")
  TRUE
}

finalize_removal_manifest <- function(agent, scope, path, manifest) {
  if (length(manifest$skills) > 0) {
    write_manifest(agent, scope, path, manifest)
    return(invisible())
  }

  if (fs::file_exists(manifest_path(agent, scope, path))) {
    fs::file_delete(manifest_path(agent, scope, path))
  }

  skills_root <- agent_skills_dir(agent, scope, path)
  if (fs::dir_exists(skills_root) && length(fs::dir_ls(skills_root)) == 0) {
    fs::dir_delete(skills_root)
  }

  invisible()
}
