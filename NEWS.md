# allowayai 0.2.0

## New Features

* Added `implied_prob()` — converts decimal odds to implied probability with optional vig removal.
* Added `edge_summary()` — new S3 class for capturing edge distributions across a set of games.
* Added `print.edge_summary()` and `summary.edge_summary()` — S3 methods for the new class.
* Added `plot_edge()` — ggplot2-based histogram of edge distributions.
* Added `model_summary()` — bridges S3 and S4 systems for formatted reporting.
* Added `nfl_lines` — bundled sample dataset of 100 simulated NFL betting lines.
* Expanded vignette with full worked examples using the bundled dataset.
* Added `NEWS.md` and `inst/CITATION`.

## Improvements

* Upgraded `DESCRIPTION` with full author metadata, `URL`, `BugReports`, `Language`, and `Date` fields.
* Added `ggplot2` and `stats` as formal `Imports`.
* All functions now have complete `roxygen2` documentation.

# allowayai 0.1.0

* Initial release.
* `calc_kelly()` — Kelly Criterion bet sizing (S3 class `kelly_bet`).
* `make_sports_model()` — S4 class `SportsModel` for model tracking.
* `summarize_types()` — data frame column type inspector.
