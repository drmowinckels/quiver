describe("github_source()", {
  it("errors on a malformed repo slug", {
    expect_snapshot(github_source("nope"), error = TRUE)
  })

  it("stores the repo and ref", {
    source <- github_source("rladies/grimoire")
    expect_equal(source$repo, "rladies/grimoire")
    expect_null(source$ref)
    expect_s3_class(source, c("github_source", "quiver_source"))
  })

  it("carries a custom ref through unresolved", {
    source <- github_source("rladies/grimoire", ref = "v0.2.0")
    expect_equal(source$ref, "v0.2.0")
  })
})

describe("source_list_skills.github_source()", {
  it("lists skills found anywhere in the tree, sorted by name", {
    local_mocked_github_source()
    source <- github_source("rladies/grimoire")
    expect_identical(
      source_list_skills(source),
      c("alt-text", "demo-skill", "quarto-authoring")
    )
  })

  it("resolves the tree only once across repeated calls", {
    calls <- 0
    testthat::local_mocked_bindings(
      resolve_ref = function(repo, ref = NULL) "v0.1.0",
      resolve_commit_sha = function(repo, ref) "deadbeef",
      get_repo_tree = function(repo, sha) {
        calls <<- calls + 1
        fixture_github_tree()
      }
    )
    source <- github_source("rladies/grimoire")
    source_list_skills(source)
    source_list_skills(source)
    expect_equal(calls, 1)
  })
})

describe("source_skill_files.github_source()", {
  it("lists every file under the skill directory", {
    local_mocked_github_source()
    source <- github_source("rladies/grimoire")
    files <- source_skill_files(source, "demo-skill")
    expect_setequal(files$relpath, c("SKILL.md", "references/foo.md"))
  })

  it("lists files for a nested-category skill", {
    local_mocked_github_source()
    source <- github_source("posit-dev/skills")
    files <- source_skill_files(source, "quarto-authoring")
    expect_setequal(files$relpath, c("SKILL.md", "references/tables.md"))
  })

  it("errors for an unknown skill", {
    local_mocked_github_source()
    source <- github_source("rladies/grimoire")
    expect_snapshot(source_skill_files(source, "not-a-skill"), error = TRUE)
  })
})

describe("source_copy_file.github_source()", {
  it("downloads a file to the destination, creating parent directories", {
    local_mocked_github_source()
    source <- github_source("rladies/grimoire")
    files <- source_skill_files(source, "demo-skill")
    dest <- fs::path(withr::local_tempdir(), "nested", "SKILL.md")

    row <- files[files$relpath == "SKILL.md", ]
    source_copy_file(source, "demo-skill", row, dest)

    expect_true(fs::file_exists(dest))
  })
})

describe("source_identifier.github_source()", {
  it("reports type github, repo, resolved ref, and sha", {
    local_mocked_github_source(sha = "deadbeef")
    source <- github_source("rladies/grimoire", ref = "v0.2.0")
    expect_identical(
      source_identifier(source),
      list(
        type = "github",
        repo = "rladies/grimoire",
        ref = "v0.2.0",
        sha = "deadbeef"
      )
    )
  })
})

describe("quiver_install() with a github_source()", {
  it("installs a skill end-to-end from a mocked github source", {
    local_mocked_github_source()
    project <- withr::local_tempdir()
    testthat::capture_messages(
      quiver_install(
        "demo-skill",
        github_source("rladies/grimoire"),
        agent = "claude",
        path = project
      )
    )
    dest <- fs::path(project, ".claude", "skills", "demo-skill")
    expect_true(fs::file_exists(fs::path(dest, "SKILL.md")))
    expect_true(fs::file_exists(fs::path(dest, "references", "foo.md")))
  })
})
