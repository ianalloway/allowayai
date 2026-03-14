#' Generate a Formatted Model Performance Summary
#'
#' @description
#' Takes a \code{SportsModel} S4 object and an optional \code{edge_summary} S3
#' object and returns a formatted character string suitable for reporting or
#' logging. This function bridges the S3 and S4 class systems in the package.
#'
#' @param model A \code{SportsModel} S4 object.
#' @param edge An optional \code{edge_summary} S3 object. If provided, edge
#'   statistics are appended to the output.
#'
#' @return A character string (invisibly) containing the formatted summary.
#'   Also prints to the console.
#' @export
#'
#' @examples
#' m <- make_sports_model(accuracy = 0.683, roi = 0.124, games_tested = 6000)
#' model_summary(m)
model_summary <- function(model, edge = NULL) {
  if (!methods::is(model, "SportsModel")) {
    stop("model must be a SportsModel S4 object.")
  }

  lines <- c(
    "============================================",
    "  allowayai :: Sports Model Performance",
    "============================================",
    sprintf("  Accuracy     : %.1f%%", model@accuracy * 100),
    sprintf("  ROI          : %+.1f%%", model@roi * 100),
    sprintf("  Games Tested : %d", as.integer(model@games_tested))
  )

  if (!is.null(edge)) {
    if (!inherits(edge, "edge_summary")) {
      stop("edge must be an edge_summary S3 object.")
    }
    lines <- c(lines,
      "--------------------------------------------",
      sprintf("  Edge Label   : %s", edge$label),
      sprintf("  Mean Edge    : %+.2f%%", edge$mean_edge * 100),
      sprintf("  Pct Positive : %.1f%%", edge$pct_positive * 100)
    )
  }

  lines <- c(lines, "============================================")
  output <- paste(lines, collapse = "\n")
  cat(output, "\n")
  invisible(output)
}
