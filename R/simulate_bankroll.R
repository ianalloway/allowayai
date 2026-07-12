#' Simulate Bankroll Growth with Kelly Criterion Sizing
#'
#' Runs a Monte Carlo simulation of bankroll evolution under a fixed fractional
#' Kelly strategy.
#'
#' @param win_prob Numeric scalar between 0 and 1.
#' @param odds Numeric scalar greater than 1.
#' @param n_bets Positive integer. Bets per simulation path.
#' @param n_sims Positive integer. Number of simulation paths.
#' @param kelly_fraction Numeric scalar in (0, 1].
#' @param initial_bankroll Positive numeric scalar.
#' @param plot Logical scalar. Print a ggplot2 chart when `TRUE`.
#' @return Invisibly, a list containing final-bankroll summaries and all paths.
#' @export
#' @examples
#' set.seed(42)
#' result <- simulate_bankroll(
#'   win_prob = 0.55,
#'   odds = 2.10,
#'   n_bets = 200,
#'   n_sims = 50,
#'   kelly_fraction = 0.5,
#'   plot = FALSE
#' )
#' result$median_final
simulate_bankroll <- function(win_prob, odds, n_bets = 200, n_sims = 100,
                              kelly_fraction = 0.5, initial_bankroll = 1000,
                              plot = TRUE) {
  full_kelly <- .full_kelly(win_prob, odds)
  .validate_fraction(kelly_fraction, "kelly_fraction")
  .validate_positive_integer(n_bets, "n_bets")
  .validate_positive_integer(n_sims, "n_sims")

  if (!is.numeric(initial_bankroll) || length(initial_bankroll) != 1L ||
      !is.finite(initial_bankroll) || initial_bankroll <= 0) {
    stop("initial_bankroll must be a finite positive numeric scalar", call. = FALSE)
  }
  if (!is.logical(plot) || length(plot) != 1L || is.na(plot)) {
    stop("plot must be TRUE or FALSE", call. = FALSE)
  }

  wager_fraction <- full_kelly * kelly_fraction
  wins <- matrix(
    stats::runif(n_bets * n_sims) < win_prob,
    nrow = n_bets,
    ncol = n_sims
  )
  multipliers <- ifelse(
    wins,
    1 + wager_fraction * (odds - 1),
    1 - wager_fraction
  )
  growth <- vapply(
    seq_len(n_sims),
    function(sim) cumprod(multipliers[, sim]),
    numeric(n_bets)
  )
  dim(growth) <- c(n_bets, n_sims)
  paths <- rbind(
    rep(initial_bankroll, n_sims),
    initial_bankroll * growth
  )

  final_bankrolls <- paths[n_bets + 1L, ]
  max_drawdowns <- apply(paths, 2L, function(path) {
    max((cummax(path) - path) / cummax(path))
  })

  result <- list(
    final_bankrolls = final_bankrolls,
    median_final = stats::median(final_bankrolls),
    mean_final = mean(final_bankrolls),
    prob_profit = mean(final_bankrolls > initial_bankroll),
    max_drawdown_median = stats::median(max_drawdowns),
    paths = paths
  )

  if (plot) {
    plot_data <- data.frame(
      bet = rep(0:n_bets, times = n_sims),
      bankroll = as.vector(paths),
      sim = rep(seq_len(n_sims), each = n_bets + 1L)
    )

    chart <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = bet, y = bankroll, group = sim)
    ) +
      ggplot2::geom_line(alpha = 0.15, color = "#3B82F6") +
      ggplot2::geom_hline(
        yintercept = initial_bankroll,
        linetype = "dashed",
        color = "gray40"
      ) +
      ggplot2::labs(
        title = sprintf(
          "Bankroll Simulation: %d paths, %.0f%% Kelly",
          n_sims,
          kelly_fraction * 100
        ),
        subtitle = sprintf(
          "Win Prob: %.0f%% | Odds: %.2f | Kelly Bet: %.1f%% of bankroll",
          win_prob * 100,
          odds,
          wager_fraction * 100
        ),
        x = "Bet Number",
        y = "Bankroll ($)"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold")
      )

    print(chart)
  }

  invisible(result)
}


.validate_positive_integer <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L || !is.finite(value) ||
      value < 1 || value != as.integer(value)) {
    stop(sprintf("%s must be a positive integer", name), call. = FALSE)
  }
  invisible(value)
}
