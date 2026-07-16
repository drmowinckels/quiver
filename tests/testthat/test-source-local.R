describe("local_source()", {
  it("errors when the path does not exist", {
    expect_snapshot(local_source("nonexistent-dir"), error = TRUE)
  })

  it("resolves to an absolute path", {
    root <- local_source_root()
    source <- local_source(root)
    expect_true(fs::is_absolute_path(source$path))
    expect_s3_class(source, c("local_source", "quiver_source"))
  })
})

describe("source_list_skills.local_source()", {
  it("lists skills that have a SKILL.md", {
    root <- local_source_root()
    source <- local_source(root)
    expect_equal(source_list_skills(source), c("demo-skill", "other-skill"))
  })

  it("returns an empty vector when there is no skills/ directory", {
    root <- withr::local_tempdir()
    source <- local_source(root)
    expect_equal(source_list_skills(source), character())
  })

  it("ignores a skills/ subdirectory without a SKILL.md", {
    root <- local_source_root()
    fs::dir_create(fs::path(root, "skills", "not-a-skill"))
    source <- local_source(root)
    expect_equal(source_list_skills(source), c("demo-skill", "other-skill"))
  })
})

describe("source_skill_files.local_source()", {
  it("lists every file under the skill directory", {
    root <- local_source_root()
    source <- local_source(root)
    files <- source_skill_files(source, "demo-skill")
    expect_setequal(
      files$relpath,
      c("SKILL.md", fs::path("references", "foo.md"))
    )
  })

  it("errors for an unknown skill", {
    root <- local_source_root()
    source <- local_source(root)
    expect_snapshot(source_skill_files(source, "not-a-skill"), error = TRUE)
  })

  it("excludes symlinks rather than following them outside the skill", {
    root <- local_source_root()
    escape_target <- fs::path(root, "outside.txt")
    writeLines("secret", escape_target)
    skill_dir <- fs::path(root, "skills", "demo-skill")
    fs::link_create(escape_target, fs::path(skill_dir, "escape.txt"))

    source <- local_source(root)
    files <- source_skill_files(source, "demo-skill")
    expect_false("escape.txt" %in% files$relpath)
  })
})

describe("source_copy_file.local_source()", {
  it("copies a file to the destination, creating parent directories", {
    root <- local_source_root()
    source <- local_source(root)
    files <- source_skill_files(source, "demo-skill")
    dest <- fs::path(withr::local_tempdir(), "nested", "SKILL.md")

    row <- files[files$relpath == "SKILL.md", ]
    source_copy_file(source, "demo-skill", row, dest)

    expect_true(fs::file_exists(dest))
    expect_equal(readLines(dest), readLines(row$abspath))
  })
})

describe("source_identifier.local_source()", {
  it("reports type local and the absolute path", {
    root <- local_source_root()
    source <- local_source(root)
    expect_equal(
      source_identifier(source),
      list(type = "local", path = as.character(source$path))
    )
  })
})
