describe("quiver_remove()", {
  it("removes an installed skill and cleans up the manifest", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")

    expect_snapshot(
      result <- quiver_remove("demo-skill", agent = "claude", path = root)
    )

    expect_equal(result, "demo-skill")
    expect_false(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
  })

  it("removes the manifest and skills directory once the last skill is gone", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")

    capture_messages(quiver_remove("demo-skill", agent = "claude", path = root))

    expect_false(fs::file_exists(manifest_path("claude", "project", root)))
    expect_false(fs::dir_exists(agent_skills_dir("claude", "project", root)))
  })

  it("keeps the manifest when other skills remain installed", {
    root <- withr::local_tempdir()
    source_root <- local_source_root()
    capture_messages(quiver_install(
      c("demo-skill", "other-skill"),
      local_source(source_root),
      agent = "claude",
      path = root
    ))

    capture_messages(quiver_remove("demo-skill", agent = "claude", path = root))

    manifest <- read_manifest("claude", "project", root)
    expect_null(manifest$skills[["demo-skill"]])
    expect_false(is.null(manifest$skills[["other-skill"]]))
  })

  it("skips a hand-edited skill without force", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    writeLines(
      "edited",
      fs::path(skill_dir("claude", "project", root, "demo-skill"), "SKILL.md")
    )

    expect_snapshot(quiver_remove("demo-skill", agent = "claude", path = root))

    expect_true(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
  })

  it("removes a hand-edited skill when force = TRUE", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    writeLines(
      "edited",
      fs::path(skill_dir("claude", "project", root, "demo-skill"), "SKILL.md")
    )

    capture_messages(
      quiver_remove("demo-skill", agent = "claude", path = root, force = TRUE)
    )

    expect_false(fs::dir_exists(skill_dir(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
  })

  it("reports a skill that isn't installed rather than erroring", {
    root <- withr::local_tempdir()
    expect_snapshot(
      result <- quiver_remove("not-installed", agent = "claude", path = root)
    )
    expect_equal(result, character())
  })

  it("errors when skill is not a non-empty character vector", {
    expect_snapshot(quiver_remove(character(), agent = "claude"), error = TRUE)
  })
})
