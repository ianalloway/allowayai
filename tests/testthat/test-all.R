test_that('Kelly criterion calculates correctly', {
  res <- calc_kelly(0.6, 2.0, 1.0)
  expect_equal(res$full_kelly, 0.2)
  
  res_half <- calc_kelly(0.6, 2.0, 0.5)
  expect_equal(res_half$recommended_bet_pct, 0.1)
  
  # Negative edge
  res_neg <- calc_kelly(0.4, 2.0)
  expect_equal(res_neg$full_kelly, 0)
})

test_that('SportsModel S4 class validates', {
  m <- make_sports_model(0.68, 0.12, 1000)
  expect_true(isS4(m))
  expect_equal(m@accuracy, 0.68)
  
  expect_error(make_sports_model(1.5, 0.12, 1000))
})

test_that('summarize_types works on data frames', {
  df <- data.frame(a = 1:5, b = letters[1:5])
  res <- summarize_types(df)
  expect_equal(nrow(res), 2)
  expect_equal(res$column, c('a', 'b'))
})
