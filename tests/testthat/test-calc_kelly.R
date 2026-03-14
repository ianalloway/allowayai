test_that("calc_kelly works correctly", {
  # Simple even money bet with 55% win probability
  # Edge = 0.55 * 1 - 0.45 * 1 = 0.1
  # Kelly = 0.1 / 1 = 0.1
  res <- calc_kelly(prob = 0.55, odds = 2.0)
  expect_equal(res$full_kelly, 0.1)
  
  # With fraction
  res_half <- calc_kelly(prob = 0.55, odds = 2.0, fraction = 0.5)
  expect_equal(res_half$recommended_bet_pct, 0.05)
  
  # Negative edge
  res_neg <- calc_kelly(prob = 0.45, odds = 2.0)
  expect_equal(res_neg$full_kelly, 0)
})
