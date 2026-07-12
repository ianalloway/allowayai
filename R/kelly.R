#' Calculate Fractional Kelly Bet Size
#'
#' Calculates the optimal bet size using the Kelly Criterion, with an optional
#' fractional multiplier to reduce variance.
#'
#' @param prob Numeric scalar. Estimated probability of winning, from 0 to 1.
#' @param odds Numeric scalar. Decimal odds greater than 1.
#' @param fraction Numeric scalar in (0, 1]. The fraction of full Kelly to wager.
#' @return An object of class `kelly_bet`.
#' @export
#' @examples
#' calc_kelly(prob = 0.60, odds = 2.0, fraction = 0.5)
calc_kelly <- function(prob, odds, fraction = 0.5) {
  full_kelly <- .full_kelly(prob, odds)
  .validate_fraction(fraction, "fraction")

  result <- list(
    model_prob = prob,
    implied_prob = 1 / odds,
    edge = prob - (1 / odds),
    full_kelly = full_kelly,
    fraction = fraction,
    recommended_bet_pct = full_kelly * fraction
  )
  class(result) <- c("kelly_bet", "list")
  result
}


.full_kelly <- function(prob, odds) {
  if (!is.numeric(prob) || length(prob) != 1L || !is.finite(prob) || prob < 0 || prob > 1) {
    stop("prob must be a finite numeric scalar between 0 and 1", call. = FALSE)
  }
  if (!is.numeric(odds) || length(odds) != 1L || !is.finite(odds) || odds <= 1) {
    stop("odds must be a finite numeric scalar greater than 1", call. = FALSE)
  }
  max(0, (prob * odds - 1) / (odds - 1))
}


.validate_fraction <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L || !is.finite(value) || value <= 0 || value > 1) {
    stop(sprintf("%s must be a finite numeric scalar in (0, 1]", name), call. = FALSE)
  }
  invisible(value)
}


#' Print method for kelly_bet
#'
#' @param x A `kelly_bet` object.
#' @param ... Additional arguments (unused).
#' @export
print.kelly_bet <- function(x, ...) {
  cat("--- Kelly Criterion Bet Sizing ---\n")
  cat(sprintf("Model Probability: %.1f%%\n", x$model_prob * 100))
  cat(sprintf("Implied Probability: %.1f%%\n", x$implied_prob * 100))
  cat(sprintf("Edge: %.1f%%\n", x$edge * 100))
  cat(sprintf("Full Kelly: %.2f%% of bankroll\n", x$full_kelly * 100))
  cat(sprintf(
    "Recommended Bet (%.2fx): %.2f%% of bankroll\n",
    x$fraction,
    x$recommended_bet_pct * 100
  ))
  invisible(x)
}
