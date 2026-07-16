describe("split_repo()", {
  it("splits an owner/repo slug", {
    expect_equal(
      split_repo("rladies/grimoire"),
      list(owner = "rladies", repo = "grimoire")
    )
  })

  it("errors on a malformed slug", {
    expect_snapshot(split_repo("grimoire"), error = TRUE)
    expect_snapshot(split_repo("a/b/c"), error = TRUE)
  })
})

describe("resolve_ref()", {
  it("returns the given ref unchanged", {
    expect_equal(resolve_ref("rladies/grimoire", "v0.2.0"), "v0.2.0")
  })

  it("returns the latest release tag when ref is NULL", {
    testthat::local_mocked_bindings(
      gh = function(endpoint, ...) list(tag_name = "v0.1.0"),
      .package = "gh"
    )
    expect_equal(resolve_ref("rladies/grimoire", NULL), "v0.1.0")
  })

  it("falls back to the default branch when there are no releases", {
    testthat::local_mocked_bindings(
      gh = function(endpoint, ...) {
        if (grepl("releases/latest", endpoint)) {
          stop("404 Not Found")
        }
        list(default_branch = "main")
      },
      .package = "gh"
    )
    expect_snapshot(resolve_ref("rladies/grimoire", NULL))
  })
})

describe("resolve_commit_sha()", {
  it("returns the commit sha for a ref", {
    testthat::local_mocked_bindings(
      gh = function(endpoint, ...) list(sha = "deadbeef"),
      .package = "gh"
    )
    expect_equal(resolve_commit_sha("rladies/grimoire", "main"), "deadbeef")
  })

  it("short-circuits without an API call when ref is already a full sha", {
    testthat::local_mocked_bindings(
      gh = function(endpoint, ...) cli::cli_abort("should not be called"),
      .package = "gh"
    )
    sha <- "0123456789abcdef0123456789abcdef01234567"
    expect_equal(resolve_commit_sha("rladies/grimoire", sha), sha)
  })
})

describe("get_repo_tree()", {
  it("returns the tree entries", {
    testthat::local_mocked_bindings(
      gh = function(endpoint, ...) list(tree = fixture_github_tree()),
      .package = "gh"
    )
    tree <- get_repo_tree("rladies/grimoire", "deadbeef")
    expect_equal(length(tree), length(fixture_github_tree()))
  })
})

describe("is_safe_path_segment()", {
  it("accepts ordinary kebab-case names", {
    expect_true(is_safe_path_segment("rladies-blog-post"))
  })

  it("rejects traversal and slash-containing names", {
    expect_false(is_safe_path_segment(".."))
    expect_false(is_safe_path_segment("."))
    expect_false(is_safe_path_segment("foo/bar"))
    expect_false(is_safe_path_segment("foo\\bar"))
  })

  it("rejects names outside the identifier allowlist", {
    expect_false(is_safe_path_segment("foo bar"))
    expect_false(is_safe_path_segment("C:"))
    expect_false(is_safe_path_segment(""))
  })
})

describe("is_visible_path_segment()", {
  it("accepts ordinary kebab-case names", {
    expect_true(is_visible_path_segment("rladies-blog-post"))
  })

  it("rejects dotfile-style names", {
    expect_false(is_visible_path_segment(".claude-plugin"))
    expect_false(is_visible_path_segment(".env"))
  })

  it("rejects traversal and unsafe names too", {
    expect_false(is_visible_path_segment(".."))
    expect_false(is_visible_path_segment("foo/bar"))
  })
})

describe("is_safe_relpath()", {
  it("accepts ordinary nested relative paths", {
    expect_true(is_safe_relpath("SKILL.md"))
    expect_true(is_safe_relpath("references/foo.md"))
  })

  it("accepts a dotfile mid-path — it can't escape the target directory", {
    expect_true(is_safe_relpath(".env.example"))
    expect_true(is_safe_relpath("references/.gitkeep"))
  })

  it("rejects traversal and absolute paths", {
    expect_false(is_safe_relpath("../../etc/passwd"))
    expect_false(is_safe_relpath("references/../../../etc/passwd"))
    expect_false(is_safe_relpath("/etc/passwd"))
    expect_false(is_safe_relpath(""))
  })

  it("rejects Windows drive-absolute paths", {
    expect_false(is_safe_relpath("C:\\Windows\\System32"))
    expect_false(is_safe_relpath("C:/Windows/System32"))
  })
})

describe("is_safe_dir_path()", {
  it("accepts flat and nested directory paths", {
    expect_true(is_safe_dir_path("skills/demo-skill"))
    expect_true(is_safe_dir_path("alt-text"))
  })

  it("rejects a path with any dotfile-style segment", {
    expect_false(is_safe_dir_path(".claude-plugin/hidden-skill"))
    expect_false(is_safe_dir_path("skills/../escape"))
  })
})

describe("github_skill_paths()", {
  it("extracts skill name to directory path from SKILL.md blobs only", {
    paths <- github_skill_paths(fixture_github_tree())
    expect_equal(
      paths,
      c(
        "alt-text" = "alt-text",
        "demo-skill" = "skills/demo-skill",
        "quarto-authoring" = "quarto/quarto-authoring"
      )
    )
  })

  it("silently drops entries nested under a dotfile directory", {
    paths <- github_skill_paths(fixture_github_tree())
    expect_false("hidden-skill" %in% names(paths))
  })

  it("silently drops unsafe skill names instead of surfacing them", {
    malicious <- c(
      fixture_github_tree(),
      list(list(path = "skills/../SKILL.md", type = "blob", sha = "evil"))
    )
    expect_false("" %in% names(github_skill_paths(malicious)))
  })

  it("errors when two directories share the same skill name", {
    colliding <- list(
      list(path = "skills/foo/SKILL.md", type = "blob", sha = "a"),
      list(path = "other/foo/SKILL.md", type = "blob", sha = "b")
    )
    expect_snapshot(github_skill_paths(colliding), error = TRUE)
  })
})

describe("list_skill_files_at()", {
  it("returns full and relative paths for a skill directory", {
    files <- list_skill_files_at(fixture_github_tree(), "skills/demo-skill")
    expect_equal(sort(files$relpath), c("SKILL.md", "references/foo.md"))
    expect_true(all(startsWith(files$path, "skills/demo-skill/")))
  })

  it("includes a dotfile within the skill directory", {
    with_dotfile <- list(
      list(path = "skills/demo-skill/SKILL.md", type = "blob", sha = "a"),
      list(path = "skills/demo-skill/.env.example", type = "blob", sha = "b")
    )
    files <- list_skill_files_at(with_dotfile, "skills/demo-skill")
    expect_true(".env.example" %in% files$relpath)
  })

  it("errors when the directory has no files", {
    expect_snapshot(
      list_skill_files_at(fixture_github_tree(), "skills/nope"),
      error = TRUE
    )
  })

  it("refuses to build relpaths that escape the target directory", {
    malicious <- list(
      list(path = "skills/demo-skill/SKILL.md", type = "blob", sha = "sha1"),
      list(
        path = "skills/demo-skill/../../../etc/passwd",
        type = "blob",
        sha = "evil"
      )
    )
    expect_snapshot(
      list_skill_files_at(malicious, "skills/demo-skill"),
      error = TRUE
    )
  })
})

describe("download_file_to()", {
  it("creates the destination directory and downloads the file", {
    dest_dir <- withr::local_tempdir()
    dest <- fs::path(dest_dir, "nested", "SKILL.md")
    called_with <- NULL
    testthat::local_mocked_bindings(
      curl_download = function(url, destfile, ...) {
        called_with <<- url
        writeLines("content", destfile)
        invisible(destfile)
      },
      .package = "curl"
    )
    download_file_to(
      "rladies/grimoire",
      "deadbeef",
      "skills/demo-skill/SKILL.md",
      dest
    )
    expect_true(fs::file_exists(dest))
    expect_equal(
      called_with,
      raw_url("rladies/grimoire", "deadbeef", "skills/demo-skill/SKILL.md")
    )
  })
})
