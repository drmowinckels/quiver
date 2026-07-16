# quiver_status() / reports no skills installed when the manifest is empty

    Code
      result <- quiver_status(agent = "claude", path = root)
    Message
      No skills installed for "claude" ("project").

# quiver_status() / reports an installed, unmodified skill

    Code
      result <- quiver_status(agent = "claude", path = root)
    Message
      v demo-skill

# quiver_status() / flags a hand-edited skill as modified

    Code
      result <- quiver_status(agent = "claude", path = root)
    Message
      ! demo-skill — locally modified

