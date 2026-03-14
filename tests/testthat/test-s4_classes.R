test_that("SportsModel S4 class works correctly", {
  model <- make_sports_model(0.65, 0.15, 1000)
  
  expect_s4_class(model, "SportsModel")
  expect_equal(model@accuracy, 0.65)
  expect_equal(model@roi, 0.15)
  expect_equal(model@games_tested, 1000)
  
  # Invalid accuracy
  expect_error(make_sports_model(1.5, 0.15, 1000))
})
