#' Summarize Data Frame Types
#'
#' @description
#' A utility function that returns a clean summary of a data frame's column types,
#' checking if they are S3 or S4 objects under the hood.
#' 
#' @param df A data frame
#' @return A data frame summarizing the columns
#' @export
#' @examples
#' summarize_types(mtcars)
summarize_types <- function(df) {
  if (!is.data.frame(df)) stop('Input must be a data frame')
  
  res <- data.frame(
    column = names(df),
    class = sapply(df, function(x) class(x)[1]),
    typeof = sapply(df, typeof),
    is_S4 = sapply(df, isS4),
    stringsAsFactors = FALSE
  )
  rownames(res) <- NULL
  return(res)
}
