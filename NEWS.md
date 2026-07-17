# quiver 0.0.0.9000

- Initial release: `quiver_install()`, `quiver_status()`, and
  `quiver_remove()`, with a pluggable source (`local_source()`) and
  pluggable agent adapters (`quiver_agents()`: `claude`, `opencode`), at
  project or user scope.
- Added a "Get started with quiver" vignette.
- Added `github_source()`, a second pluggable source that installs skills
  straight from a 'GitHub' repository, ported from `grimoire`
  (rladies/grimoire). It finds any `SKILL.md` anywhere in the repo tree,
  so it works with both a flat `skills/<name>/` layout and a categorised
  layout like `<category>/<name>/`.
- Added `ropensci_skills()`, `posit_skills()`, and `rladies_grimoire()` —
  `github_source()` constructors pre-pointed at the rOpenSci, Posit, and
  RLadies+ Agent Skills catalogues.
