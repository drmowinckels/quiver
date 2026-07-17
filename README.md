# quiver

A source- and agent-agnostic engine for installing [Agent
Skills](https://www.anthropic.com/news/skills) into a project or user
profile. `quiver` resolves a skill from a source — a local directory or a
'GitHub' repository today, a curated registry later — and installs it for
a given agent adapter, at project or user scope, with checksum-based
protection against clobbering hand edits.

It grew out of duplicating the same fetch/checksum/install logic across a
couple of R packages that each ship their own skill catalogue for a
specific community (e.g. [`grimoire`](https://github.com/rladies/grimoire)
for RLadies+). Those packages can depend on `quiver` for the engine and
keep only their own catalogue and branding.

## Installing

```r
# install.packages("pak")
pak::pak("drmowinckels/quiver")
```

## Usage

```r
library(quiver)

quiver_agents() # agents quiver knows how to install skills for

source <- local_source("path/to/a/skills/checkout")
quiver_install("demo-skill", source, agent = "claude")               # project scope
quiver_install("demo-skill", source, agent = "claude", scope = "user") # user scope

quiver_status(agent = "claude")     # what's installed, and what's been hand-edited
quiver_remove("demo-skill", agent = "claude")
```

A local source points at a checkout with the same layout 'GitHub'-hosted
skill repositories use: `skills/<name>/SKILL.md`, with any supporting
files (e.g. `references/`) alongside it.

Skills can also be installed straight from 'GitHub', with `github_source()`
or one of the catalogue constructors built on it:

```r
quiver_install("package-review", ropensci_skills(), agent = "claude")
quiver_install("testing-r-packages", posit_skills(), agent = "claude")
quiver_install("rladies-blog-post", rladies_grimoire(), agent = "claude")

# or point at any 'GitHub' repository directly
quiver_install("demo-skill", github_source("owner/repo"), agent = "claude")
```

## Status

`local_source()` and `github_source()` (plus the `ropensci_skills()`,
`posit_skills()`, and `rladies_grimoire()` catalogue constructors) are
available now, alongside the `claude`/`opencode` agent adapters. A curated
registry source is planned next.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). See
`NEWS.md` for what's changed.

Please note that quiver is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
