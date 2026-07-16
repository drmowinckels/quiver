describe("quiver_status()", {
  it("reports no skills installed when the manifest is empty", {
    root <- withr::local_tempdir()
    expect_snapshot(result <- quiver_status(agent = "claude", path = root))
    expect_equal(nrow(result), 0)
  })

  it("reports an installed, unmodified skill", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")

    expect_snapshot(result <- quiver_status(agent = "claude", path = root))
    expect_equal(result$skill, "demo-skill")
    expect_false(result$modified)
  })

  it("flags a hand-edited skill as modified", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    writeLines(
      "edited",
      fs::path(skill_dir("claude", "project", root, "demo-skill"), "SKILL.md")
    )

    expect_snapshot(result <- quiver_status(agent = "claude", path = root))
    expect_true(result$modified)
  })

  it("reports separately per agent", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill", agent = "claude")

    capture_messages(
      claude_status <- quiver_status(agent = "claude", path = root)
    )
    capture_messages(
      opencode_status <- quiver_status(agent = "opencode", path = root)
    )

    expect_equal(nrow(claude_status), 1)
    expect_equal(nrow(opencode_status), 0)
  })
})
