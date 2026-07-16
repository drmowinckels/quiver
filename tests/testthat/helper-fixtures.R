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
