#' Simulate Bankroll Growth with Kelly Criterion Sizing
#'
#' Runs a Monte Carlo simulation of bankroll evolution when betting with
#' Kelly-sized wagers. This helps visualize the long-run growth properties
#' and variance characteristics of a betting strategy.
#'
#' @param win_prob Numeric. Probability of winning each bet (0 to 1).
#' @param odds Numeric. Decimal odds for each bet (must be > 1).
#' @param n_bets Integer. Number of bets to simulate per path. Default is 200.
#' @param n_sims Integer. Number of simulation paths to run. Default is 100.
#' @param kelly_fraction Numeric. Kelly fraction (0 to 1). Default is 0.5.
#' @param initial_bankroll Numeric. Starting bankroll in dollars. Default is 1000.
#' @param plot Logical. If \\code{TRUE}, display a ggplot2 visualization of
#'   all simulation paths. Default is \\code{TRUE}.
#'
#' @return A list with:
#'   \\describe{
#'     \\item{final_bankrolls}{Numeric vector of final bankroll values for each sim}
#'     \\item{median_final}{Median final bankroll across all simulations}
#'     \\item{mean_final}{Mean final bankroll}
#'     \\item{prob_profit}{Proportion of simulations that ended profitable}
#'     \\item{max_drawdown_median}{Median maximum drawdown across simulations}
#'     \\item{paths}{Matrix of bankroll paths (n_bets+1 rows x n_sims columns)}
#'   }
#'
#' @details
#' Each simulation path independently generates \\code{n_bets} binary outcomes
#' according to \\code{win_prob}, sizes each bet using the Kelly Criterion
#' (with the specified \\code{kelly_fraction}), and tracks the bankroll after
#' each bet.
#'
#' This function was added to the package to address a gap identified during
#' development: while \\code{calc_kelly()} tells you how much to bet on a
#' single game, it does not show you what happens when you apply that strategy
#' over hundreds of bets. The simulation bridges that gap by making the
#' variance properties of Kelly betting tangible.
#'
#' @examples
#' # Simulate 100 paths of 200 bets with a 55% win rate at +110
#' result <- simulate_bankroll(
#'   win_prob = 0.55,
#'   odds = 2.10,
#'   n_bets = 200,
#'   n_sims = 50,
#'   kelly_fraction = 0.5,
#'   plot = FALSE
#' )
#' cat("Median final bankroll:", result$median_final, "\n")
#' cat("Probability of profit:", result$prob_profit * 100, "%\n")
#'
#' @export
simulate_bankroll <- function(win_prob, odds, n_bets = 200, n_sims = 100,
                               kelly_fraction = 0.5, initial_bankroll = 1000,
                               plot = TRUE) {
  if (win_prob <= 0 || win_prob >= 1) stop("win_prob must be between 0 and 1")
  if (odds <= 1) stop("odds must be greater than 1")
  if (kelly_fraction <= 0 || kelly_fraction > 1) stop("kelly_fraction must be in (0, 1]")

  # Calculate Kelly bet size
  kelly <- max(0, (win_prob * odds - 1) / (odds - 1)) * kelly_fraction

  # Simulation matrix
  paths <- matrix(NA, nrow = n_bets + 1, ncol = n_sims)
  paths[1, ] <- initial_bankroll

  set.seed(NULL)
  for (sim in 1:n_sims) {
    bankroll <- initial_bankroll
    for (bet in 1:n_bets) {
      wager <- bankroll * kelly
      if (runif(1) < win_prob) {
        bankroll <- bankroll + wager * (odds - 1)
      } else {
        bankroll <- bankroll - wager
      }
      paths[bet + 1, sim] <- bankroll
    }
  }

  final_bankrolls <- paths[n_bets + 1, ]

  # Calculate max drawdowns
  max_drawdowns <- vapply(1:n_sims, function(sim) {
    path <- paths[, sim]
    running_max <- cummax(path)
    drawdowns <- (running_max - path) / running_max
    max(drawdowns)
  }, numeric(1))

  result <- list(
    final_bankrolls = final_bankrolls,
    median_final = stats::median(final_bankrolls),
    mean_final = mean(final_bankrolls),
    prob_profit = mean(final_bankrolls > initial_bankroll),
    max_drawdown_median = stats::median(max_drawdowns),
    paths = paths
  )

  if (plot) {
    # Build data frame for plotting
    plot_data <- data.frame(
      bet = rep(0:n_bets, times = n_sims),
      bankroll = as.vector(paths),
      sim = rep(1:n_sims, each = n_bets + 1)
    )

    p <- ggplot2::ggplot(plot_data,
           ggplot2::aes(x = bet, y = bankroll, group = sim)) +
      ggplot2::geom_line(alpha = 0.15, color = "#3B82F6") +
      ggplot2::geom_hline(yintercept = initial_bankroll,
                          linetype = "dashed", color = "gray40") +
      ggplot2::labs(
        title = sprintf("Bankroll Simulation: %d paths, %.0f%% Kelly",
                        n_sims, kelly_fraction * 100),
        subtitle = sprintf("Win Prob: %.0f%% | Odds: %.2f | Kelly Bet: %.1f%% of bankroll",
                           win_prob * 100, odds, kelly * 100),
        x = "Bet Number",
        y = "Bankroll ($, log scale)"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(plot.title = ggplot2::element_text(face = "bold"))

    print(p)
  }

  return(invisible(result))
}
