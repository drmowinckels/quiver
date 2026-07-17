#' Install rOpenSci skills
#'
#' A [github_source()] pointed at the rOpenSci catalogue of Agent Skills for
#' package review, maintenance, and release:
#' <https://github.com/ropensci-review-tools/ropensci-skills>.
#'
#' @inheritParams github_source
#'
#' @return A `github_source` object, for use with [quiver_install()].
#'
#' @examples
#' \dontrun{
#' quiver_install("package-review", ropensci_skills(), agent = "claude")
#' }
#'
#' @export
ropensci_skills <- function(ref = NULL) {
  github_source("ropensci-review-tools/ropensci-skills", ref = ref)
}

#' Install Posit skills
#'
#' A [github_source()] pointed at
#' [`posit-dev/skills`](https://github.com/posit-dev/skills), Posit's
#' catalogue of Agent Skills for R, Quarto, and Shiny development.
#'
#' @inheritParams github_source
#'
#' @return A `github_source` object, for use with [quiver_install()].
#'
#' @examples
#' \dontrun{
#' quiver_install("testing-r-packages", posit_skills(), agent = "claude")
#' }
#'
#' @export
posit_skills <- function(ref = NULL) {
  github_source("posit-dev/skills", ref = ref)
}

#' Install the RLadies+ grimoire
#'
#' A [github_source()] pointed at
#' [`rladies/grimoire`](https://github.com/rladies/grimoire), the RLadies+
#' catalogue of Agent Skills for chapter organisers and community
#' management.
#'
#' @inheritParams github_source
#'
#' @return A `github_source` object, for use with [quiver_install()].
#'
#' @examples
#' \dontrun{
#' quiver_install("rladies-blog-post", rladies_grimoire(), agent = "claude")
#' }
#'
#' @export
rladies_grimoire <- function(ref = NULL) {
  github_source("rladies/grimoire", ref = ref)
}
