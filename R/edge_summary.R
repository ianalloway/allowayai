#' Create an Edge Summary Object
#'
#' @description
#' Constructs an S3 object of class \code{edge_summary} that captures the
#' relationship between a model's predicted probability and the bookmaker's
#' implied probability across a set of games. This is the core diagnostic
#' object for evaluating whether a model has a genuine edge.
#'
#' @param model_probs Numeric vector. The model's predicted win probabilities (0 to 1).
#' @param market_odds Numeric vector. The bookmaker's decimal odds for each game.
#' @param outcomes Integer vector. Actual outcomes: 1 for win, 0 for loss.
#'   Optional; if provided, enables ROI and accuracy calculations.
#' @param label Character. A descriptive label for this model/dataset. Default "Model".
#'
#' @return An object of class \code{edge_summary}.
#' @export
#'
#' @examples
#' set.seed(42)
#' es <- edge_summary(
#'   model_probs = runif(20, 0.50, 0.70),
#'   market_odds = runif(20, 1.80, 2.10),
#'   outcomes    = rbinom(20, 1, 0.60),
#'   label       = "NFL Week 1 Model"
#' )
#' print(es)
edge_summary <- function(model_probs, market_odds, outcomes = NULL, label = "Model") {
  if (length(model_probs) != length(market_odds)) {
    stop("model_probs and market_odds must be the same length.")
  }
  if (!is.null(outcomes) && length(outcomes) != length(model_probs)) {
    stop("outcomes must be the same length as model_probs.")
  }
  if (any(model_probs < 0 | model_probs > 1)) {
    stop("model_probs must be between 0 and 1.")
  }
  if (any(market_odds <= 1)) {
    stop("market_odds must be greater than 1.")
  }

  implied <- 1 / market_odds
  edges   <- model_probs - implied

  result <- list(
    label        = label,
    n            = length(model_probs),
    model_probs  = model_probs,
    market_odds  = market_odds,
    implied_probs = implied,
    edges        = edges,
    mean_edge    = mean(edges),
    pct_positive = mean(edges > 0),
    outcomes     = outcomes
  )

  if (!is.null(outcomes)) {
    result$accuracy <- mean(outcomes == as.integer(model_probs > implied))
    result$roi      <- mean((outcomes * (market_odds - 1)) - (1 - outcomes))
  }

  class(result) <- c("edge_summary", "list")
  return(result)
}

#' Print method for edge_summary
#'
#' @param x An \code{edge_summary} object.
#' @param ... Additional arguments (unused).
#' @export
print.edge_summary <- function(x, ...) {
  cat(sprintf("=== Edge Summary: %s ===\n", x$label))
  cat(sprintf("Games Analyzed  : %d\n", x$n))
  cat(sprintf("Mean Edge       : %+.2f%%\n", x$mean_edge * 100))
  cat(sprintf("Pct with Edge   : %.1f%%\n", x$pct_positive * 100))
  if (!is.null(x$outcomes)) {
    cat(sprintf("Model Accuracy  : %.1f%%\n", x$accuracy * 100))
    cat(sprintf("Avg ROI per bet : %+.2f%%\n", x$roi * 100))
  }
  invisible(x)
}

#' Summary method for edge_summary
#'
#' @param object An \code{edge_summary} object.
#' @param ... Additional arguments (unused).
#' @export
summary.edge_summary <- function(object, ...) {
  cat(sprintf("Edge Summary: %s\n", object$label))
  cat("Edge distribution:\n")
  print(summary(object$edges))
  invisible(object)
}

#' Plot the edge distribution for an edge_summary object
#'
#' @description
#' Creates a ggplot2 histogram of the edge distribution (model probability minus
#' implied probability) for all games in an \code{edge_summary} object. A vertical
#' dashed line marks zero edge; positive values indicate a model advantage.
#'
#' @param x An \code{edge_summary} object.
#' @param bins Integer. Number of histogram bins. Default 20.
#' @param ... Additional arguments (unused).
#'
#' @return A \code{ggplot} object.
#' @export
#' @importFrom ggplot2 ggplot aes geom_histogram geom_vline labs theme_minimal
#'   scale_fill_manual theme element_text
#'
#' @examples
#' set.seed(42)
#' es <- edge_summary(
#'   model_probs = runif(50, 0.50, 0.70),
#'   market_odds = runif(50, 1.80, 2.10)
#' )
#' plot_edge(es)
plot_edge <- function(x, bins = 20, ...) {
  if (!inherits(x, "edge_summary")) stop("x must be an edge_summary object.")

  df <- data.frame(edge = x$edges)

  ggplot2::ggplot(df, ggplot2::aes(x = edge, fill = edge > 0)) +
    ggplot2::geom_histogram(bins = bins, color = "white", alpha = 0.85) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "#333333", linewidth = 0.8) +
    ggplot2::scale_fill_manual(
      values = c("TRUE" = "#2563eb", "FALSE" = "#dc2626"),
      labels = c("TRUE" = "Positive Edge", "FALSE" = "Negative Edge"),
      name   = NULL
    ) +
    ggplot2::labs(
      title    = paste("Edge Distribution:", x$label),
      subtitle = sprintf("Mean edge: %+.2f%% | %.0f%% of games have positive edge",
                         x$mean_edge * 100, x$pct_positive * 100),
      x        = "Edge (Model Prob - Implied Prob)",
      y        = "Count"
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold"),
      legend.position = "top"
    )
}
