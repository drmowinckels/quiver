describe("read_manifest() / write_manifest()", {
  it("returns an empty manifest when none exists yet", {
    root <- withr::local_tempdir()
    expect_equal(
      read_manifest("claude", "project", root),
      list(skills = list())
    )
  })

  it("round-trips a manifest written to disk", {
    root <- withr::local_tempdir()
    manifest <- list(skills = list(`demo-skill` = list(checksum = "abc")))
    write_manifest("claude", "project", root, manifest)

    roundtripped <- read_manifest("claude", "project", root)
    expect_equal(roundtripped$skills$`demo-skill`$checksum, "abc")
  })

  it("defaults skills to an empty list when the file lacks that key", {
    root <- withr::local_tempdir()
    fs::dir_create(fs::path(root, ".claude", "skills"), recurse = TRUE)
    jsonlite::write_json(
      list(note = "no skills key here"),
      manifest_path("claude", "project", root),
      auto_unbox = TRUE
    )

    expect_equal(read_manifest("claude", "project", root)$skills, list())
  })

  it("writes the manifest under the agent's skills directory", {
    root <- withr::local_tempdir()
    write_manifest("claude", "project", root, list(skills = list()))
    expect_true(fs::file_exists(fs::path(
      root,
      ".claude",
      "skills",
      ".quiver-manifest.json"
    )))
  })
})

describe("compute_skill_checksum()", {
  it("is stable for identical contents regardless of file order", {
    dir1 <- withr::local_tempdir()
    writeLines("a", fs::path(dir1, "a.txt"))
    writeLines("b", fs::path(dir1, "b.txt"))

    dir2 <- withr::local_tempdir()
    writeLines("b", fs::path(dir2, "b.txt"))
    writeLines("a", fs::path(dir2, "a.txt"))

    expect_equal(compute_skill_checksum(dir1), compute_skill_checksum(dir2))
  })

  it("changes when a file's contents change", {
    dir <- withr::local_tempdir()
    writeLines("a", fs::path(dir, "a.txt"))
    before <- compute_skill_checksum(dir)

    writeLines("changed", fs::path(dir, "a.txt"))
    after <- compute_skill_checksum(dir)

    expect_false(identical(before, after))
  })

  it("returns NA for an empty directory", {
    dir <- withr::local_tempdir()
    expect_true(is.na(compute_skill_checksum(dir)))
  })
})

describe("update_manifest_entry()", {
  it("records the source identifier and checksum", {
    root <- withr::local_tempdir()
    source <- local_source(local_source_root())

    update_manifest_entry(
      "claude",
      "project",
      root,
      "demo-skill",
      source,
      "abc123"
    )

    manifest <- read_manifest("claude", "project", root)
    entry <- manifest$skills$`demo-skill`
    expect_equal(entry$checksum, "abc123")
    expect_equal(entry$source$type, "local")
  })
})

describe("skill_is_modified()", {
  it("returns NA when the skill is not installed", {
    root <- withr::local_tempdir()
    expect_true(is.na(skill_is_modified(
      "claude",
      "project",
      root,
      "demo-skill"
    )))
  })

  it("returns FALSE when the on-disk checksum still matches", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    expect_false(skill_is_modified("claude", "project", root, "demo-skill"))
  })

  it("returns TRUE after a hand edit", {
    root <- withr::local_tempdir()
    install_skill(root, "demo-skill")
    writeLines(
      "edited",
      fs::path(skill_dir("claude", "project", root, "demo-skill"), "SKILL.md")
    )
    expect_true(skill_is_modified("claude", "project", root, "demo-skill"))
  })
})
