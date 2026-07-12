#' Convert Decimal Odds to Implied Probability
#'
#' Converts bookmaker decimal odds to implied probability. For a two-outcome
#' market, `remove_vig = TRUE` normalizes the two implied probabilities.
#'
#' @param odds Numeric vector of decimal odds greater than 1.
#' @param remove_vig Logical. Normalize a two-outcome market when `TRUE`.
#' @param odds_b Numeric odds for the opposing outcome. Required when removing vig.
#' @return A numeric vector of implied probabilities.
#' @export
#' @examples
#' implied_prob(2.0)
#' implied_prob(odds = 1.91, remove_vig = TRUE, odds_b = 1.91)
implied_prob <- function(odds, remove_vig = FALSE, odds_b = NULL) {
  if (any(!is.finite(odds)) || any(odds <= 1)) {
    stop("odds must contain finite decimal odds greater than 1", call. = FALSE)
  }

  raw <- 1 / odds
  if (!remove_vig) {
    return(raw)
  }

  if (is.null(odds_b)) {
    stop("odds_b is required when remove_vig = TRUE", call. = FALSE)
  }
  if (any(!is.finite(odds_b)) || any(odds_b <= 1)) {
    stop("odds_b must contain finite decimal odds greater than 1", call. = FALSE)
  }
  raw / (raw + 1 / odds_b)
}
