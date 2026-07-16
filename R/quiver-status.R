#' Report the status of installed skills
#'
#' Prints, and invisibly returns, which skills are installed for a given
#' agent and scope, and whether any have been hand-edited since install.
#'
#' @inheritParams quiver_install
#'
#' @return A data frame with columns `skill` and `modified`, invisibly.
#'
#' @examples
#' \dontrun{
#' quiver_status(agent = "claude")
#' }
#'
#' @export
quiver_status <- function(
  agent = quiver_agents(),
  scope = c("project", "user"),
  path = "."
) {
  agent <- match.arg(agent)
  scope <- match.arg(scope)

  manifest <- read_manifest(agent, scope, path)
  installed <- names(manifest$skills)

  if (length(installed) == 0) {
    cli::cli_inform("No skills installed for {.val {agent}} ({.val {scope}}).")
    return(invisible(data.frame(
      skill = character(),
      modified = logical(),
      stringsAsFactors = FALSE
    )))
  }

  rows <- lapply(
    installed,
    quiver_status_one,
    agent = agent,
    scope = scope,
    path = path
  )
  invisible(do.call(rbind, rows))
}

quiver_status_one <- function(skill, agent, scope, path) {
  modified <- isTRUE(skill_is_modified(agent, scope, path, skill))

  if (modified) {
    cli::cli_alert_warning("{.field {skill}} \u2014 locally modified")
  } else {
    cli::cli_alert_success("{.field {skill}}")
  }

  data.frame(skill = skill, modified = modified, stringsAsFactors = FALSE)
}
