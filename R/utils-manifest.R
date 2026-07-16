skill_dir <- function(agent, scope, path, skill) {
  fs::path(agent_skills_dir(agent, scope, path), skill)
}

manifest_path <- function(agent, scope, path) {
  fs::path(agent_skills_dir(agent, scope, path), ".quiver-manifest.json")
}

read_manifest <- function(agent, scope, path) {
  mf <- manifest_path(agent, scope, path)
  if (!fs::file_exists(mf)) {
    return(list(skills = list()))
  }
  manifest <- jsonlite::read_json(mf, simplifyVector = FALSE)
  if (is.null(manifest$skills)) {
    manifest$skills <- list()
  }
  manifest
}

write_manifest <- function(agent, scope, path, manifest) {
  fs::dir_create(agent_skills_dir(agent, scope, path), recurse = TRUE)
  jsonlite::write_json(
    manifest,
    manifest_path(agent, scope, path),
    auto_unbox = TRUE,
    pretty = TRUE,
    null = "null"
  )
  invisible(manifest)
}

compute_skill_checksum <- function(dir) {
  files <- sort(fs::dir_ls(dir, recurse = TRUE, type = "file"))
  if (length(files) == 0) {
    return(NA_character_)
  }
  relpaths <- fs::path_rel(files, start = dir)
  hashes <- vapply(
    files,
    digest::digest,
    character(1),
    algo = "sha256",
    file = TRUE
  )
  names(hashes) <- relpaths
  digest::digest(hashes[order(names(hashes))], algo = "sha256")
}

update_manifest_entry <- function(agent, scope, path, skill, source, checksum) {
  manifest <- read_manifest(agent, scope, path)
  manifest$skills[[skill]] <- list(
    source = source_identifier(source),
    checksum = checksum,
    installed_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  )
  write_manifest(agent, scope, path, manifest)
  invisible(manifest)
}

skill_is_modified <- function(agent, scope, path, skill) {
  manifest <- read_manifest(agent, scope, path)
  entry <- manifest$skills[[skill]]
  dest <- skill_dir(agent, scope, path, skill)
  if (is.null(entry) || !fs::dir_exists(dest)) {
    return(NA)
  }
  current <- compute_skill_checksum(dest)
  !identical(current, entry$checksum)
}
