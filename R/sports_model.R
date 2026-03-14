#' S4 Class for Sports Model Results
#'
#' @slot accuracy Numeric. The backtested accuracy of the model.
#' @slot roi Numeric. The Return on Investment.
#' @slot games_tested Numeric. The number of games in the backtest.
#' @export
setClass('SportsModel',
         representation(
           accuracy = 'numeric',
           roi = 'numeric',
           games_tested = 'numeric'
         ),
         validity = function(object) {
           if(object@accuracy < 0 || object@accuracy > 1) {
             return('Accuracy must be between 0 and 1')
           }
           if(object@games_tested <= 0) {
             return('Games tested must be positive')
           }
           TRUE
         }
)

#' Create a new SportsModel object
#'
#' @param accuracy Numeric accuracy (0-1)
#' @param roi Numeric ROI
#' @param games_tested Integer number of games
#' @return A SportsModel object
#' @export
#' @importFrom methods new
#' @examples
#' make_sports_model(0.68, 0.12, 6000)
make_sports_model <- function(accuracy, roi, games_tested) {
  new('SportsModel', accuracy = accuracy, roi = roi, games_tested = games_tested)
}

#' Show method for SportsModel
#' @param object A SportsModel object
#' @importFrom methods show
#' @export
setMethod('show', 'SportsModel', function(object) {
  cat('Sports Betting Model Performance\n')
  cat('--------------------------------\n')
  cat(sprintf('Accuracy: %.1f%%\n', object@accuracy * 100))
  cat(sprintf('ROI: %+.1f%%\n', object@roi * 100))
  cat(sprintf('Sample Size: %d games\n', object@games_tested))
})
