checkout <- tempfile("quiver-checkout")
dir.create(file.path(checkout, "skills", "demo-skill"), recursive = TRUE)
writeLines(
  c("---", "name: demo-skill", "description: Demo skill.", "---"),
  file.path(checkout, "skills", "demo-skill", "SKILL.md")
)

source <- local_source(checkout)
