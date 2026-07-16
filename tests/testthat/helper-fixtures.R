fixture_skill_md <- function(
  name = "demo-skill",
  description = "Demo skill for tests."
) {
  paste0(
    "---\n",
    "name: ",
    name,
    "\n",
    "description: ",
    description,
    "\n",
    "---\n\n",
    "# Demo skill\n\nBody text.\n"
  )
}

local_source_root <- function(env = parent.frame()) {
  root <- withr::local_tempdir(.local_envir = env)

  demo <- fs::path(root, "skills", "demo-skill")
  fs::dir_create(fs::path(demo, "references"), recurse = TRUE)
  writeLines(fixture_skill_md("demo-skill"), fs::path(demo, "SKILL.md"))
  writeLines("reference body\n", fs::path(demo, "references", "foo.md"))

  other <- fs::path(root, "skills", "other-skill")
  fs::dir_create(other, recurse = TRUE)
  writeLines(fixture_skill_md("other-skill"), fs::path(other, "SKILL.md"))

  root
}

redact_path <- function(root) {
  root <- as.character(fs::path(root))
  function(lines) gsub(root, "<root>", lines, fixed = TRUE)
}

install_skill <- function(
  path,
  skill = "demo-skill",
  agent = "claude",
  scope = "project",
  env = parent.frame()
) {
  source_root <- local_source_root(env = env)
  testthat::capture_messages(
    quiver_install(
      skill,
      local_source(source_root),
      agent = agent,
      scope = scope,
      path = path
    )
  )
  invisible(NULL)
}

fixture_github_tree <- function() {
  list(
    list(path = "skills/demo-skill/SKILL.md", type = "blob", sha = "sha1"),
    list(
      path = "skills/demo-skill/references/foo.md",
      type = "blob",
      sha = "sha2"
    ),
    list(path = "skills", type = "tree", sha = "sha3"),
    list(path = "alt-text/SKILL.md", type = "blob", sha = "sha4"),
    list(
      path = "quarto/quarto-authoring/SKILL.md",
      type = "blob",
      sha = "sha5"
    ),
    list(
      path = "quarto/quarto-authoring/references/tables.md",
      type = "blob",
      sha = "sha6"
    ),
    list(path = "quarto", type = "tree", sha = "sha7"),
    list(path = "README.md", type = "blob", sha = "sha8"),
    list(
      path = ".claude-plugin/hidden-skill/SKILL.md",
      type = "blob",
      sha = "sha9"
    )
  )
}

local_mocked_github_source <- function(env = parent.frame(), sha = "deadbeef") {
  testthat::local_mocked_bindings(
    resolve_ref = function(repo, ref = NULL) ref %||% "v0.1.0",
    resolve_commit_sha = function(repo, ref) sha,
    get_repo_tree = function(repo, sha) fixture_github_tree(),
    download_file_to = function(repo, sha, path, dest) {
      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      content <- if (basename(path) == "SKILL.md") {
        fixture_skill_md(fs::path_file(fs::path_dir(path)))
      } else {
        "reference body\n"
      }
      writeLines(content, dest)
      invisible(dest)
    },
    .env = env
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x
