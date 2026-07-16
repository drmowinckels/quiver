#' Reference a 'GitHub' repository as a skill source
#'
#' Treats `repo` as a 'GitHub'-hosted skills repository: any `SKILL.md`
#' found anywhere in the tree is an installable skill, named after its
#' parent directory. This covers both a flat `skills/<name>/SKILL.md`
#' layout and a categorised layout like `<category>/<name>/SKILL.md`.
#'
#' @param repo `"owner/repo"` slug of the source repository.
#' @param ref Git ref (tag, branch, or SHA) to install from. Defaults to
#'   the latest 'GitHub' release, falling back to the default branch if the
#'   repo has no releases. Resolved once per source and reused across
#'   calls, so every skill installed from a single [quiver_install()] call
#'   comes from the same commit.
#'
#' @return A `github_source` object, for use with [quiver_install()].
#'
#' @examples
#' \dontrun{
#' source <- github_source("rladies/grimoire")
#' quiver_install("rladies-blog-post", source, agent = "claude")
#' }
#'
#' @export
github_source <- function(repo, ref = NULL) {
  split_repo(repo)
  new_source(
    "github",
    repo = repo,
    ref = ref,
    cache = new.env(parent = emptyenv())
  )
}

# cache is an environment (not a plain list field) so this mutation
# persists across every source_*() call on the same source object,
# resolving ref/sha/tree/paths from GitHub at most once per source.
github_source_resolve <- function(source) {
  if (is.null(source$cache$tree)) {
    resolved_ref <- resolve_ref(source$repo, source$ref)
    sha <- resolve_commit_sha(source$repo, resolved_ref)
    tree <- get_repo_tree(source$repo, sha)
    source$cache$ref <- resolved_ref
    source$cache$sha <- sha
    source$cache$tree <- tree
    source$cache$paths <- github_skill_paths(tree)
  }
  source$cache
}

#' @exportS3Method
source_list_skills.github_source <- function(source) {
  cache <- github_source_resolve(source)
  names(cache$paths)
}

#' @exportS3Method
source_skill_files.github_source <- function(source, skill) {
  cache <- github_source_resolve(source)
  if (!skill %in% names(cache$paths)) {
    cli::cli_abort("No files found for skill {.val {skill}}.")
  }
  list_skill_files_at(cache$tree, cache$paths[[skill]])
}

#' @exportS3Method
source_copy_file.github_source <- function(source, skill, file, dest) {
  cache <- github_source_resolve(source)
  download_file_to(source$repo, cache$sha, file$path, dest)
}

#' @exportS3Method
source_identifier.github_source <- function(source) {
  cache <- github_source_resolve(source)
  list(type = "github", repo = source$repo, ref = cache$ref, sha = cache$sha)
}
