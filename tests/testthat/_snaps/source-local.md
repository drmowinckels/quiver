# local_source() / errors when the path does not exist

    Code
      local_source("nonexistent-dir")
    Condition
      Error in `local_source()`:
      ! `path` does not exist: 'nonexistent-dir'

# source_skill_files.local_source() / errors for an unknown skill

    Code
      source_skill_files(source, "not-a-skill")
    Condition
      Error in `source_skill_files()`:
      ! No files found for skill "not-a-skill".

