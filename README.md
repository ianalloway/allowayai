# allowayai

**AI and Sports Analytics Utility Toolkit for R**

[![R package](https://img.shields.io/badge/R-package-blue)](https://github.com/ianalloway/allowayai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`allowayai` is an R package built around the workflows I write about on [AllowayAI](https://allowayai.substack.com) — sports analytics, machine learning model evaluation, and practical data science utilities. It is designed to be a clean, well-documented toolkit that bridges the gap between statistical theory and real-world betting and prediction workflows.

## Installation

You can install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("ianalloway/allowayai")
```

## Functions

The package's actual exports (see `NAMESPACE`):

| Function | Type | Description |
|---|---|---|
| `implied_prob()` | Function | Converts decimal odds to implied probability, with optional vig removal |
| `calc_kelly()` | S3 constructor | Calculates optimal bet sizing using the Kelly Criterion |
| `print.kelly_bet()` | S3 method | Pretty-prints a `kelly_bet` object |
| `edge_summary()` | S3 constructor | Summarizes model-vs-market edge across a set of games |
| `print.edge_summary()` | S3 method | Pretty-prints an `edge_summary` object |
| `summary.edge_summary()` | S3 method | Prints the edge distribution summary |
| `plot_edge()` | Function | ggplot2 histogram of the edge distribution for an `edge_summary` |
| `simulate_bankroll()` | Function | Monte Carlo simulation of Kelly-sized bankroll growth over many bets |
| `make_sports_model()` | S4 constructor | Creates a `SportsModel` S4 object |
| `show()` for `SportsModel` | S4 method | Displays model performance summary |
| `model_summary()` | Function | Formats a `SportsModel` (and optional `edge_summary`) as a report string |
| `summarize_types()` | Utility | Returns a data frame of column names and types |

## Usage

### Kelly Criterion Bet Sizing

```r
library(allowayai)

# Calculate optimal bet size for a 60% win probability at 2.0 decimal odds
bet <- calc_kelly(prob = 0.60, odds = 2.0, fraction = 0.5)
print(bet)
#> --- Kelly Criterion Bet Sizing ---
#> Model Probability: 60.0%
#> Implied Probability: 50.0%
#> Edge: 10.0%
#> Full Kelly: 20.00% of bankroll
#> Recommended Bet (0.50x): 10.00% of bankroll
```

### S4 Sports Model Object

```r
# Create a sports model performance record
model <- make_sports_model(accuracy = 0.68, roi = 0.12, games_tested = 6000)
show(model)
#> Sports Betting Model Performance
#> --------------------------------
#> Accuracy: 68.0%
#> ROI: +12.0%
#> Sample Size: 6000 games
```

### Data Frame Type Summary

```r
df <- data.frame(
  team = c("Chiefs", "Eagles"),
  wins = c(14, 13),
  playoff = c(TRUE, TRUE)
)

summarize_types(df)
#>    column      type
#> 1    team character
#> 2    wins   integer
#> 3 playoff   logical
```

## Package Structure

- **S3 classes and methods**: `kelly_bet` (`print`), `edge_summary` (`print`, `summary`)
- **S4 classes and methods**: `SportsModel` class with `show` method
- **Utility/plotting functions**: `implied_prob()`, `plot_edge()`, `simulate_bankroll()`, `model_summary()`, `summarize_types()`
- **Vignette**: Full walkthrough in `vignettes/allowayai.Rmd`
- **Tests**: `testthat` unit tests covering all functions
- **License**: MIT

## Author

Ian Alloway — [ianalloway.xyz](https://ianalloway.xyz) | [AllowayAI on Substack](https://allowayai.substack.com)
