agent_prefixes <- c(claude = ".claude", opencode = ".opencode")

#' Agents quiver knows how to install skills for
#'
#' @return A character vector of agent identifiers, for use as the `agent`
#'   argument to [quiver_install()], [quiver_status()], and
#'   [quiver_remove()].
#'
#' @examples
#' quiver_agents()
#'
#' @export
quiver_agents <- function() {
  names(agent_prefixes)
}

agent_skills_dir <- function(agent, scope, path) {
  base <- if (scope == "user") fs::path_home() else fs::path(path)
  fs::path(base, agent_prefixes[[agent]], "skills")
}
