describe("is_quiver_source()", {
  it("is true for objects created by new_source()", {
    expect_true(is_quiver_source(new_source("local", path = ".")))
  })

  it("is false for a plain list", {
    expect_false(is_quiver_source(list(path = ".")))
  })
})

describe("ensure_parent_dir()", {
  it("creates missing nested parent directories", {
    dest <- fs::path(withr::local_tempdir(), "nested", "deep", "SKILL.md")
    ensure_parent_dir(dest)
    expect_true(fs::dir_exists(fs::path_dir(dest)))
  })
})
