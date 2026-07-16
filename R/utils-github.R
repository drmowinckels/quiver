split_repo <- function(repo) {
  parts <- strsplit(repo, "/", fixed = TRUE)[[1]]
  if (length(parts) != 2 || any(parts == "")) {
    cli::cli_abort(
      "{.arg repo} must be in the form {.val owner/repo}, not {.val {repo}}."
    )
  }
  list(owner = parts[1], repo = parts[2])
}

gh_repo_endpoint <- function(repo, suffix = "", ...) {
  or <- split_repo(repo)
  gh::gh(
    paste0("GET /repos/{owner}/{repo}", suffix),
    owner = or$owner,
    repo = or$repo,
    ...
  )
}

resolve_ref <- function(repo, ref = NULL) {
  if (!is.null(ref)) {
    return(ref)
  }
  latest <- tryCatch(
    gh_repo_endpoint(repo, "/releases/latest"),
    error = function(e) NULL
  )
  if (!is.null(latest)) {
    return(latest$tag_name)
  }
  info <- gh_repo_endpoint(repo)
  cli::cli_alert_info(paste(
    "No releases found for {.val {repo}} \u2014 using default branch",
    "{.val {info$default_branch}}"
  ))
  info$default_branch
}

resolve_commit_sha <- function(repo, ref) {
  if (grepl("^[0-9a-f]{40}$", ref)) {
    return(ref)
  }
  gh_repo_endpoint(repo, sprintf("/commits/%s", ref))$sha
}

get_repo_tree <- function(repo, sha) {
  gh_repo_endpoint(repo, sprintf("/git/trees/%s", sha), recursive = "1")$tree
}

is_safe_path_segment <- function(x) {
  grepl("^[A-Za-z0-9_.-]+$", x) && !x %in% c(".", "..")
}

# A relpath is judged purely on traversal safety: a dotfile mid-path (e.g.
# .gitkeep, .env.example) can't escape the target directory, so it must
# stay installable. Visibility filtering (is_visible_path_segment) is a
# separate concern that only applies to skill *discovery*, below.
is_safe_relpath <- function(x) {
  if (fs::is_absolute_path(x)) {
    return(FALSE)
  }
  segments <- strsplit(x, "[/\\\\]")[[1]]
  length(segments) > 0 &&
    all(vapply(segments, is_safe_path_segment, logical(1)))
}

is_visible_path_segment <- function(x) {
  is_safe_path_segment(x) && !startsWith(x, ".")
}

is_safe_dir_path <- function(x) {
  segments <- strsplit(x, "/", fixed = TRUE)[[1]]
  length(segments) > 0 &&
    all(vapply(segments, is_visible_path_segment, logical(1)))
}

# github_skill_paths() silently drops unsafe or dotfile-nested entries (a
# malicious or hidden tree entry just never becomes an installable skill),
# mirroring how source_list_skills.local_source() silently skips
# directories without a SKILL.md. A name collision is different: it's not
# a malicious entry, just two directories the caller can no longer tell
# apart by name, so it aborts loudly instead of silently resolving to
# whichever one sorts first.
github_skill_paths <- function(tree) {
  is_blob <- vapply(tree, function(x) identical(x$type, "blob"), logical(1))
  paths <- vapply(tree, function(x) x$path, character(1))
  is_skill_md <- is_blob & grepl("(^|/)SKILL\\.md$", paths)

  dirs <- sub("(^|/)SKILL\\.md$", "", paths[is_skill_md])
  names <- fs::path_file(dirs)
  safe <- vapply(dirs, is_safe_dir_path, logical(1))

  result <- dirs[safe]
  names(result) <- names[safe]
  result <- result[order(names(result))]

  duplicated_names <- unique(names(result)[duplicated(names(result))])
  if (length(duplicated_names) > 0) {
    cli::cli_abort(c(
      "x" = paste(
        "Skill name{?s} {.val {duplicated_names}} found in more than one",
        "directory."
      ),
      "i" = "Every skill must have a unique directory name across the repo."
    ))
  }

  result
}

list_skill_files_at <- function(tree, dir_path) {
  prefix <- paste0(dir_path, "/")
  is_match <- vapply(
    tree,
    function(x) identical(x$type, "blob") && startsWith(x$path, prefix),
    logical(1)
  )
  entries <- tree[is_match]
  if (length(entries) == 0) {
    cli::cli_abort("No files found for skill at {.path {dir_path}}.")
  }
  paths <- vapply(entries, function(x) x$path, character(1))
  relpaths <- sub(prefix, "", paths, fixed = TRUE)
  unsafe <- !vapply(relpaths, is_safe_relpath, logical(1))
  if (any(unsafe)) {
    cli::cli_abort(c(
      "x" = paste(
        "{.path {dir_path}} contains unsafe file path{?s}:",
        "{.path {relpaths[unsafe]}}"
      ),
      "i" = "Refusing to download files that could escape the target directory."
    ))
  }
  data.frame(path = paths, relpath = relpaths, stringsAsFactors = FALSE)
}

raw_url <- function(repo, sha, path) {
  sprintf("https://raw.githubusercontent.com/%s/%s/%s", repo, sha, path)
}

download_file_to <- function(repo, sha, path, dest) {
  ensure_parent_dir(dest)
  curl::curl_download(raw_url(repo, sha, path), fs::path(dest), quiet = TRUE)
  invisible(dest)
}
