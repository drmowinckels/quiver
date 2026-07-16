# split_repo() / errors on a malformed slug

    Code
      split_repo("grimoire")
    Condition
      Error in `split_repo()`:
      ! `repo` must be in the form "owner/repo", not "grimoire".

---

    Code
      split_repo("a/b/c")
    Condition
      Error in `split_repo()`:
      ! `repo` must be in the form "owner/repo", not "a/b/c".

# resolve_ref() / falls back to the default branch when there are no releases

    Code
      resolve_ref("rladies/grimoire", NULL)
    Message
      i No releases found for "rladies/grimoire" — using default branch "main"
    Output
      [1] "main"

# github_skill_paths() / errors when two directories share the same skill name

    Code
      github_skill_paths(colliding)
    Condition
      Error in `github_skill_paths()`:
      x Skill name "foo" found in more than one directory.
      i Every skill must have a unique directory name across the repo.

# list_skill_files_at() / errors when the directory has no files

    Code
      list_skill_files_at(fixture_github_tree(), "skills/nope")
    Condition
      Error in `list_skill_files_at()`:
      ! No files found for skill at 'skills/nope'.

# list_skill_files_at() / refuses to build relpaths that escape the target directory

    Code
      list_skill_files_at(malicious, "skills/demo-skill")
    Condition
      Error in `list_skill_files_at()`:
      x 'skills/demo-skill' contains unsafe file path: '../../../etc/passwd'
      i Refusing to download files that could escape the target directory.

