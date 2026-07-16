describe("quiver_install()", {
  it("installs a skill's files and records a manifest entry", {
    root <- withr::local_tempdir()
    source_root <- local_source_root()

    expect_snapshot(
      result <- quiver_install(
        "demo-skill",
        local_source(source_root),
        agent = "claude",
        path = root
      ),
      transform = redact_path(root)
    )

    dest <- skill_dir("claude", "project", root, "demo-skill")
    expect_true(fs::file_exists(fs::path(dest, "SKILL.md")))
    expect_true(fs::file_exists(fs::path(dest, "references", "foo.md")))
    expect_equal(result, as.character(dest))

    manifest <- read_manifest("claude", "project", root)
    expect_false(is.na(manifest$skills[["demo-skill"]]$checksum))
  })

  it("installs multiple skills at once", {
    root <- withr::local_tempdir()
    source_root <- local_source_root()

    capture_messages(
      result <- quiver_install(
        c("demo-skill", "other-skill"),
        local_source(source_root),
        agent = "claude",
        path = root
      )
    )

    expect_length(result, 2)
    expect_true(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
    expect_true(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "other-skill"
    )))
  })

  it("skips an already-installed skill without force", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    skill_file <- fs::path(
      skill_dir("claude", "project", root, "demo-skill"),
      "SKILL.md"
    )
    writeLines("hand-edited", skill_file)

    messages <- capture_messages(
      quiver_install(
        "demo-skill",
        local_source(local_source_root()),
        agent = "claude",
        path = root
      )
    )
    expect_match(paste(messages, collapse = ""), "skipping")

    expect_equal(readLines(skill_file), "hand-edited")
  })

  it("overwrites an already-installed skill when force = TRUE", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    skill_file <- fs::path(
      skill_dir("claude", "project", root, "demo-skill"),
      "SKILL.md"
    )
    writeLines("hand-edited", skill_file)

    messages <- capture_messages(
      quiver_install(
        "demo-skill",
        local_source(local_source_root()),
        agent = "claude",
        path = root,
        force = TRUE
      )
    )
    expect_match(paste(messages, collapse = ""), "Installed")

    expect_equal(readLines(skill_file)[1], "---")
    expect_false(identical(readLines(skill_file), "hand-edited"))
  })

  it("errors on an unknown skill name", {
    root <- withr::local_tempdir()
    expect_snapshot(
      quiver_install(
        "not-a-skill",
        local_source(local_source_root()),
        agent = "claude",
        path = root
      ),
      error = TRUE
    )
  })

  it("errors when skill is not a non-empty character vector", {
    source <- local_source(local_source_root())
    expect_snapshot(
      quiver_install(character(), source, agent = "claude"),
      error = TRUE
    )
    expect_snapshot(quiver_install(1, source, agent = "claude"), error = TRUE)
  })

  it("errors when source was not created by a source constructor", {
    expect_snapshot(
      quiver_install("demo-skill", list(path = "."), agent = "claude"),
      error = TRUE
    )
  })

  it("errors on an invalid agent", {
    root <- withr::local_tempdir()
    expect_snapshot(
      quiver_install(
        "demo-skill",
        local_source(local_source_root()),
        agent = "bogus",
        path = root
      ),
      error = TRUE
    )
  })

  it("installs under the requested agent's directory", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill", agent = "opencode")

    expect_true(fs::dir_exists(fs::path(
      root,
      ".opencode",
      "skills",
      "demo-skill"
    )))
    expect_false(fs::dir_exists(fs::path(
      root,
      ".claude",
      "skills",
      "demo-skill"
    )))
  })

  it("installs at user scope regardless of path", {
    home <- withr::local_tempdir()
    withr::local_envvar(HOME = home)
    root <- withr::local_tempdir()

    install_skill(root, "demo-skill", scope = "user")

    expect_true(fs::dir_exists(fs::path(
      home,
      ".claude",
      "skills",
      "demo-skill"
    )))
    expect_false(fs::dir_exists(fs::path(
      root,
      ".claude",
      "skills",
      "demo-skill"
    )))
  })

  it("removes the partial install directory when copying a file fails", {
    root <- withr::local_tempdir()
    source_root <- local_source_root()
    local_mocked_bindings(
      source_copy_file.local_source = function(source, skill, file, dest) {
        stop("disk blew up")
      }
    )

    capture_messages(expect_error(
      quiver_install(
        "demo-skill",
        local_source(source_root),
        agent = "claude",
        path = root
      ),
      "disk blew up"
    ))
    expect_false(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
  })
})
