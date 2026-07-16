# quiver_remove() / removes an installed skill and cleans up the manifest

    Code
      result <- quiver_remove("demo-skill", agent = "claude", path = root)
    Message
      v Removed demo-skill

# quiver_remove() / skips a hand-edited skill without force

    Code
      quiver_remove("demo-skill", agent = "claude", path = root)
    Message
      ! demo-skill has local changes or is untracked — skipping (`force = TRUE` to remove anyway)

# quiver_remove() / reports a skill that isn't installed rather than erroring

    Code
      result <- quiver_remove("not-installed", agent = "claude", path = root)
    Message
      i not-installed is not installed for "claude" ("project")

# quiver_remove() / errors when skill is not a non-empty character vector

    Code
      quiver_remove(character(), agent = "claude")
    Condition
      Error in `quiver_remove()`:
      ! `skill` must be a non-empty character vector.

