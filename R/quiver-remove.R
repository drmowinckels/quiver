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
#' @examples
#' \dontrun{
#' quiver_remove("demo-skill", agent = "claude")
#' }
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
    dest <- skill_dir(agent, scope, path, s)
    if (!fs::dir_exists(dest)) {
      cli::cli_alert_info(
        "{.field {s}} is not installed for {.val {agent}} ({.val {scope}})"
      )
      next
    }

    modified <- skill_is_modified(agent, scope, path, s)
    if (!isFALSE(modified) && !force) {
      cli::cli_alert_warning(paste(
        "{.field {s}} has local changes or is untracked \u2014 skipping",
        "({.code force = TRUE} to remove anyway)"
      ))
      next
    }

    fs::dir_delete(dest)
    manifest$skills[[s]] <- NULL
    removed <- c(removed, s)
    cli::cli_alert_success("Removed {.field {s}}")
  }

  skills_root <- agent_skills_dir(agent, scope, path)
  if (length(manifest$skills) == 0) {
    if (fs::file_exists(manifest_path(agent, scope, path))) {
      fs::file_delete(manifest_path(agent, scope, path))
    }
    if (fs::dir_exists(skills_root) && length(fs::dir_ls(skills_root)) == 0) {
      fs::dir_delete(skills_root)
    }
  } else {
    write_manifest(agent, scope, path, manifest)
  }

  invisible(removed)
}
