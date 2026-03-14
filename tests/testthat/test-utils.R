test_that("summarize_types works correctly", {
  df <- data.frame(
    a = 1:5,
    b = letters[1:5],
    c = c(TRUE, FALSE, TRUE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
  
  res <- summarize_types(df)
  
  expect_equal(nrow(res), 3)
  expect_equal(res$column, c("a", "b", "c"))
  expect_equal(res$class, c("integer", "character", "logical"))
})
