# quiver

A source- and agent-agnostic engine for installing [Agent
Skills](https://www.anthropic.com/news/skills) into a project or user
profile. `quiver` resolves a skill from a source — a local directory today,
a 'GitHub' repository or curated registry later — and installs it for a
given agent adapter, at project or user scope, with checksum-based
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

A source points at a checkout with the same layout 'GitHub'-hosted skill
repositories use: `skills/<name>/SKILL.md`, with any supporting files
(e.g. `references/`) alongside it.

## Status

This is an early, local-source-only slice: `local_source()` and the
`claude`/`opencode` agent adapters. A 'GitHub' source (ported from
`grimoire`) and a curated registry source are planned next.

## Contributing

Issues and PRs welcome. See `NEWS.md` for what's changed.
