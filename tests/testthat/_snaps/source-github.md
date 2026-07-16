# github_source() / errors on a malformed repo slug

    Code
      github_source("nope")
    Condition
      Error in `split_repo()`:
      ! `repo` must be in the form "owner/repo", not "nope".

# source_skill_files.github_source() / errors for an unknown skill

    Code
      source_skill_files(source, "not-a-skill")
    Condition
      Error in `source_skill_files()`:
      ! No files found for skill "not-a-skill".

