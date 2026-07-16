# Contributing to quiver

This outlines how to propose a change to quiver.

## Filing an issue

Bug reports and feature requests are welcome at
<https://github.com/drmowinckels/quiver/issues>. For bug reports, please
include a minimal reproducible example (a [reprex](https://reprex.tidyverse.org/)).

## Pull requests

- Please file an issue before starting on a pull request for anything beyond
  a small fix, so we can discuss the approach first.
- Create a feature branch off `main` for each change.
- Follow the existing code style: `tidyverse`-style R, `roxygen2` for
  documentation, `testthat` (3rd edition, `describe()`/`it()` blocks) for
  tests.
- New or changed behaviour should come with tests in the same pull request.
- Run `devtools::document()`, `devtools::test()`, and `devtools::check()`
  locally before opening the pull request.
- Add a bullet to `NEWS.md` describing the change.

## Code style

quiver uses [air](https://posit-dev.github.io/air/) for formatting and
[lintr](https://lintr.r-lib.org/) for linting. Please run both before
submitting:

```r
air::format_dir(".")
lintr::lint_package()
```

## Code of Conduct

Please note that quiver is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
