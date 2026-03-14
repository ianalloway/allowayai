#' Calculate Fractional Kelly Bet Size
#'
#' @description
#' Calculates the optimal bet size using the Kelly Criterion, with an optional fractional multiplier to reduce variance.
#' 
#' @param prob Numeric. The model's estimated probability of winning (0 to 1).
#' @param odds Numeric. The decimal odds offered by the bookmaker.
#' @param fraction Numeric. The fraction of the Kelly bet to actually wager (default is 0.5 for Half-Kelly).
#' @return An object of class 'kelly_bet' containing the recommended bet size percentage.
#' @export
#' @examples
#' calc_kelly(prob = 0.60, odds = 2.0, fraction = 0.5)
calc_kelly <- function(prob, odds, fraction = 0.5) {
  if (prob < 0 || prob > 1) stop('Probability must be between 0 and 1')
  if (odds <= 1) stop('Decimal odds must be greater than 1')
  
  b <- odds - 1
  q <- 1 - prob
  
  kelly_pct <- (b * prob - q) / b
  
  # If edge is negative, bet size is 0
  if (kelly_pct < 0) kelly_pct <- 0
  
  final_pct <- kelly_pct * fraction
  
  res <- list(
    model_prob = prob,
    implied_prob = 1 / odds,
    edge = prob - (1 / odds),
    full_kelly = kelly_pct,
    fraction = fraction,
    recommended_bet_pct = final_pct
  )
  
  class(res) <- c('kelly_bet', 'list')
  return(res)
}

#' Print method for kelly_bet
#' @param x A kelly_bet object
#' @param ... Additional arguments
#' @export
print.kelly_bet <- function(x, ...) {
  cat('--- Kelly Criterion Bet Sizing ---\n')
  cat(sprintf('Model Probability: %.1f%%\n', x$model_prob * 100))
  cat(sprintf('Implied Probability: %.1f%%\n', x$implied_prob * 100))
  cat(sprintf('Edge: %.1f%%\n', x$edge * 100))
  cat(sprintf('Full Kelly: %.2f%% of bankroll\n', x$full_kelly * 100))
  cat(sprintf('Recommended Bet (%.2fx): %.2f%% of bankroll\n', x$fraction, x$recommended_bet_pct * 100))
  invisible(x)
}
