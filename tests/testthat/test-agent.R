describe("quiver_agents()", {
  it("lists the known agent identifiers", {
    expect_equal(quiver_agents(), c("claude", "opencode"))
  })
})

describe("agent_skills_dir()", {
  it("resolves a project-scope path under the given directory", {
    expect_equal(
      agent_skills_dir("claude", "project", "myproject"),
      fs::path("myproject", ".claude", "skills")
    )
  })

  it("resolves a user-scope path under the home directory, ignoring path", {
    home <- withr::local_tempdir()
    local_mocked_bindings(path_home = function(...) home, .package = "fs")
    expect_equal(
      agent_skills_dir("opencode", "user", "myproject"),
      fs::path(home, ".opencode", "skills")
    )
  })

  it("uses a different prefix per agent", {
    expect_equal(
      fs::path_file(fs::path_dir(agent_skills_dir("claude", "project", "."))),
      ".claude"
    )
    expect_equal(
      fs::path_file(fs::path_dir(agent_skills_dir("opencode", "project", "."))),
      ".opencode"
    )
  })
})
