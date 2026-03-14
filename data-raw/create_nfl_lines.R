## Script to generate the nfl_lines sample dataset
## Run this script to regenerate the data

set.seed(2026)

teams <- c("Chiefs", "Eagles", "49ers", "Cowboys", "Bills", "Ravens",
           "Dolphins", "Bengals", "Lions", "Packers", "Rams", "Chargers",
           "Seahawks", "Vikings", "Broncos", "Steelers")

n <- 100

nfl_lines <- data.frame(
  game_id     = 1:n,
  team        = sample(teams, n, replace = TRUE),
  model_prob  = round(runif(n, 0.45, 0.72), 4),
  closing_odds = round(runif(n, 1.65, 2.35), 2),
  outcome     = rbinom(n, 1, 0.55),
  stringsAsFactors = FALSE
)

usethis::use_data(nfl_lines, overwrite = TRUE)
