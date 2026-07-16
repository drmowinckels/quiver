describe("is_quiver_source()", {
  it("is true for objects created by new_source()", {
    expect_true(is_quiver_source(new_source("local", path = ".")))
  })

  it("is false for a plain list", {
    expect_false(is_quiver_source(list(path = ".")))
  })
})
