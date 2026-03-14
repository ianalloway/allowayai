#' Convert Decimal Odds to Implied Probability
#'
#' @description
#' Converts bookmaker decimal odds to the implied probability of an outcome,
#' accounting for the overround (vig). This is the market's estimate of the
#' true probability before applying your model's edge.
#'
#' @param odds Numeric vector. Decimal odds (must be greater than 1).
#' @param remove_vig Logical. If TRUE, removes the bookmaker's overround
#'   from a two-outcome market and returns the fair probability. Default FALSE.
#' @param odds_b Numeric. The decimal odds for the opposing outcome. Required
#'   when \code{remove_vig = TRUE}.
#'
#' @return A numeric vector of implied probabilities (0 to 1).
#' @export
#' @importFrom stats setNames
#'
#' @examples
#' # Simple conversion
#' implied_prob(2.0)
#'
#' # Remove the vig from a two-outcome market
#' implied_prob(odds = 1.91, remove_vig = TRUE, odds_b = 1.91)
implied_prob <- function(odds, remove_vig = FALSE, odds_b = NULL) {
  if (any(odds <= 1)) stop("Decimal odds must be greater than 1.")

  raw <- 1 / odds

  if (remove_vig) {
    if (is.null(odds_b)) stop("odds_b is required when remove_vig = TRUE.")
    if (any(odds_b <= 1)) stop("odds_b must be greater than 1.")
    raw_b <- 1 / odds_b
    overround <- raw + raw_b
    return(raw / overround)
  }

  return(raw)
}
