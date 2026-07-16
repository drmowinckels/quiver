# quiver_install() / installs a skill's files and records a manifest entry

    Code
      result <- quiver_install("demo-skill", local_source(source_root), agent = "claude",
      path = root)
    Message
      
      -- Installing 1 skill for "claude" ---------------------------------------------
      v Installed demo-skill to '<root>/.claude/skills/demo-skill'

# quiver_install() / errors on an unknown skill name

    Code
      quiver_install("not-a-skill", local_source(local_source_root()), agent = "claude",
      path = root)
    Condition
      Error in `quiver_install()`:
      x Unknown skill: "not-a-skill"
      i Available in this source: "demo-skill" and "other-skill"

# quiver_install() / errors when skill is not a non-empty character vector

    Code
      quiver_install(character(), source, agent = "claude")
    Condition
      Error in `quiver_install()`:
      ! `skill` must be a non-empty character vector.

---

    Code
      quiver_install(1, source, agent = "claude")
    Condition
      Error in `quiver_install()`:
      ! `skill` must be a non-empty character vector.

# quiver_install() / errors when source was not created by a source constructor

    Code
      quiver_install("demo-skill", list(path = "."), agent = "claude")
    Condition
      Error in `quiver_install()`:
      ! `source` must be created by a source constructor,
      i e.g. `local_source()`.

# quiver_install() / errors on an invalid agent

    Code
      quiver_install("demo-skill", local_source(local_source_root()), agent = "bogus",
      path = root)
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "claude", "opencode"

