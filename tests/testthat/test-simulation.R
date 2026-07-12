test_that("calc_kelly validates scalar inputs and fractions", {
  expect_error(calc_kelly(c(0.5, 0.6), 2), "scalar")
  expect_error(calc_kelly(NA_real_, 2), "finite")
  expect_error(calc_kelly(0.5, 1), "greater than 1")
  expect_error(calc_kelly(0.5, 2, fraction = 0), "in \(0, 1\]")
  expect_error(calc_kelly(0.5, 2, fraction = 1.1), "in \(0, 1\]")
})


test_that("simulate_bankroll is reproducible under caller-controlled seeds", {
  set.seed(42)
  first <- simulate_bankroll(
    win_prob = 0.55,
    odds = 2.1,
    n_bets = 20,
    n_sims = 4,
    plot = FALSE
  )

  set.seed(42)
  second <- simulate_bankroll(
    win_prob = 0.55,
    odds = 2.1,
    n_bets = 20,
    n_sims = 4,
    plot = FALSE
  )

  expect_equal(first$paths, second$paths)
  expect_equal(dim(first$paths), c(21, 4))
})


test_that("simulate_bankroll handles one-path and zero-edge cases", {
  set.seed(1)
  one_path <- simulate_bankroll(
    win_prob = 0.55,
    odds = 2,
    n_bets = 1,
    n_sims = 1,
    plot = FALSE
  )
  expect_equal(dim(one_path$paths), c(2, 1))

  no_edge <- simulate_bankroll(
    win_prob = 0.5,
    odds = 2,
    n_bets = 5,
    n_sims = 3,
    initial_bankroll = 100,
    plot = FALSE
  )
  expect_equal(no_edge$paths, matrix(100, nrow = 6, ncol = 3))
  expect_equal(no_edge$prob_profit, 0)
})


test_that("simulate_bankroll validates shape and presentation arguments", {
  expect_error(
    simulate_bankroll(0.55, 2, n_bets = 0, plot = FALSE),
    "n_bets must be a positive integer"
  )
  expect_error(
    simulate_bankroll(0.55, 2, n_sims = 1.5, plot = FALSE),
    "n_sims must be a positive integer"
  )
  expect_error(
    simulate_bankroll(0.55, 2, initial_bankroll = 0, plot = FALSE),
    "initial_bankroll"
  )
  expect_error(
    simulate_bankroll(0.55, 2, plot = NA),
    "plot must be TRUE or FALSE"
  )
})
