#' Sample NFL Betting Lines Dataset
#'
#' @description
#' A sample dataset of 100 simulated NFL game betting lines, including a
#' model-predicted win probability, the bookmaker's closing line odds, and
#' the actual game outcome. Intended for use in package examples and vignettes.
#'
#' @format A data frame with 100 rows and 5 variables:
#' \describe{
#'   \item{game_id}{Integer. Unique game identifier.}
#'   \item{team}{Character. The team being bet on.}
#'   \item{model_prob}{Numeric. The model's predicted win probability (0 to 1).}
#'   \item{closing_odds}{Numeric. The bookmaker's closing decimal odds.}
#'   \item{outcome}{Integer. Actual result: 1 = win, 0 = loss.}
#' }
#' @source Simulated data generated for package demonstration purposes.
#' @usage data(nfl_lines)
"nfl_lines"
