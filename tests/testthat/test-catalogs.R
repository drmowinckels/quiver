describe("ropensci_skills()", {
  it("points at the ropensci-review-tools/ropensci-skills repo", {
    source <- ropensci_skills()
    expect_s3_class(source, c("github_source", "quiver_source"))
    expect_equal(source$repo, "ropensci-review-tools/ropensci-skills")
    expect_null(source$ref)
  })

  it("passes a custom ref through", {
    source <- ropensci_skills(ref = "v1.0.0")
    expect_equal(source$ref, "v1.0.0")
  })
})

describe("posit_skills()", {
  it("points at the posit-dev/skills repo", {
    source <- posit_skills()
    expect_s3_class(source, c("github_source", "quiver_source"))
    expect_equal(source$repo, "posit-dev/skills")
    expect_null(source$ref)
  })

  it("passes a custom ref through", {
    source <- posit_skills(ref = "v1.0.0")
    expect_equal(source$ref, "v1.0.0")
  })
})

describe("rladies_grimoire()", {
  it("points at the rladies/grimoire repo", {
    source <- rladies_grimoire()
    expect_s3_class(source, c("github_source", "quiver_source"))
    expect_equal(source$repo, "rladies/grimoire")
    expect_null(source$ref)
  })

  it("passes a custom ref through", {
    source <- rladies_grimoire(ref = "v1.0.0")
    expect_equal(source$ref, "v1.0.0")
  })
})
