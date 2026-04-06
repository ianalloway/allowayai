# Design Philosophy: Why allowayai Is Built the Way It Is

**Ian Alloway**
**LIS 4805 — Data Mining and Predictive Modeling**
**University of South Florida, Spring 2026**

---

## The Core Principle: Solve a Real Problem

The single most important design decision in this package was made before I wrote a line of code: I decided to build something I would actually use.

Most student R packages are demonstrations — they prove you can create a DESCRIPTION file, export a function, and write a man page. There is nothing wrong with that. But I had a real problem: I was building XGBoost models to predict NFL outcomes, and the gap between "model says this team wins at 58%" and "here is how much money you should risk" was filled with manual Google Sheets calculations, copy-pasted Stack Overflow formulas, and no structured way to track whether any of it was working.

allowayai exists to close that gap. Every function in the package answers a question I was actually asking on a Saturday morning with a model ready to go and games kicking off in three hours.

---

## Why These Eight Functions?

The function set was not designed top-down from an abstract API blueprint. It was designed bottom-up from my workflow. Here is the sequence I follow every week:

1. **What does the market think?** → `implied_prob()`
2. **Where does my model disagree with the market?** → `edge_summary()`
3. **What does the edge distribution look like visually?** → `plot_edge()`
4. **How much should I bet on each game?** → `calc_kelly()`
5. **How is this model performing over time?** → `make_sports_model()`
6. **Can I see everything in one report?** → `model_summary()`
7. **Wait, why is this column a factor?** → `summarize_types()`
8. **What happens to my bankroll over 200 bets?** → `simulate_bankroll()`

Each function is small and does one thing. This is intentional. R packages that try to do everything end up with functions that take 15 arguments, half of which are undocumented edge cases. I wanted the opposite: functions you can read in 30 seconds and use without checking the help page more than once.

The extension function — `simulate_bankroll()` — was added after the initial design because I realized there was a critical gap. `calc_kelly()` tells you the optimal bet size for a single game, but it says nothing about what happens when you apply that strategy over hundreds of bets. The simulation function makes the variance properties of Kelly betting tangible. You can see, visually, that half-Kelly produces smoother growth curves than full Kelly, and you can see that even with a genuine edge, individual paths can dip significantly before recovering. This is the kind of insight that changes how you actually use the math.

---

## Why Two Class Systems?

This is probably the most pedagogically interesting design choice, so let me explain it in detail.

### S3: kelly_bet and edge_summary

S3 is R's informal object-oriented system. You create an S3 object by attaching a class attribute to a list, and you define methods by naming them `generic.class()` — for example, `print.kelly_bet()`. There is no formal class definition, no slot typing, no validation at construction time. The system trusts the programmer.

I chose S3 for `kelly_bet` and `edge_summary` because these objects are structurally simple (flat lists of named values), their contents are produced by functions that already validate inputs, and the primary use case is display — you compute them, print them, and move on. S3's lightweight dispatch is perfect for this. Writing `print.kelly_bet()` and `summary.edge_summary()` gives the user a clean interface without the overhead of formal class definitions.

The key insight is that S3 methods in R use **generic function dispatch** — when you call `print(x)`, R looks at `class(x)` and finds the appropriate `print.classname()` method. This means the user never has to think about which print function to call. They just call `print()` and get the right output. That seamlessness is the entire point.

### S4: SportsModel

S4 is R's formal object-oriented system. You define a class with `setClass()`, declare slot names and types explicitly, write a validity function that runs every time an object is created, and register methods with `setMethod()`. It is more verbose than S3, but it provides compile-time-like guarantees that S3 cannot.

I chose S4 for `SportsModel` because this object tracks model performance across backtests, and bad data here has compounding consequences. If you accidentally log an accuracy of 1.5 (150%) or a negative game count, every downstream analysis that reads that object is corrupted. The S4 validity function catches these errors at construction time:

```r
validity = function(object) {
  errors <- character()
  if (object@accuracy < 0 || object@accuracy > 1)
    errors <- c(errors, "accuracy must be between 0 and 1")
  if (object@n_games <= 0)
    errors <- c(errors, "n_games must be positive")
  if (length(errors) == 0) TRUE else errors
}
```

This is not a toy example. When you are running hundreds of backtests and logging results, you want the type system to enforce correctness. You want the computer to tell you "that accuracy is impossible" before you spend an hour wondering why your performance chart looks wrong.

### The Bridge: model_summary()

The `model_summary()` function takes an S4 `SportsModel` and an optional S3 `edge_summary` and prints a combined report. This function is where the S3/S4 distinction stops being academic and becomes practical. The S4 object gives you validated, trustworthy model metadata. The S3 object gives you a flexible, lightweight snapshot of edge analysis. Together, they form a complete picture that neither could provide alone.

I deliberately designed this interaction to demonstrate that the two systems are not competitors — they are complementary tools for different trust levels.

---

## Why These Dependencies?

The package imports exactly three packages:

- **methods** — Required for the S4 class system (`setClass()`, `setMethod()`, `new()`, `is()`). This is a base R package and adds zero installation overhead.

- **ggplot2** — Used by `plot_edge()` and `simulate_bankroll()` for visualization. I considered base R graphics but rejected them because ggplot2 produces publication-quality plots with sensible defaults, and it is already installed on virtually every R user's machine. The marginal cost is zero; the quality improvement is significant.

- **stats** — Used for `setNames()` in `implied_prob()`, `median()`, `quantile()`, and `runif()` in other functions. Another base package with no installation cost.

Under Suggests (optional, not loaded unless needed):

- **testthat** — The standard R testing framework. Used only when running `devtools::test()`.
- **knitr** and **rmarkdown** — Used only to build the vignette.

I deliberately kept the dependency footprint minimal. Every dependency is a liability — it can break, it can change its API, it can conflict with other packages. Three imports (two of which are base R) is about as lean as a package with visualization capabilities can get.

---

## Why MIT License?

MIT is the simplest permissive open-source license. It allows anyone to use, modify, distribute, and sell the code with one condition: keep the copyright notice. I chose it because:

1. The package is educational — I want classmates and future students to be able to fork it, learn from it, and adapt it without legal friction.
2. It is the most common license on CRAN and GitHub for R packages, which means reviewers and users immediately understand what they can do with the code.
3. The alternative licenses (GPL, Apache, Creative Commons) each add complexity that is not warranted for a project of this scope.

---

## Why a Bundled Dataset?

The `nfl_lines` dataset serves three purposes:

1. **Examples that work** — Every `@examples` block in the documentation uses either inline data or `nfl_lines`. This means `example(edge_summary)` runs without the user having to find or download a dataset.

2. **Vignette that tells a story** — The vignette walks through a complete workflow using `nfl_lines`. Without a bundled dataset, the vignette would need external data sources that might not be available when the reader tries to follow along.

3. **Reproducible tests** — Some unit tests use properties of `nfl_lines` to verify function behavior under realistic conditions.

The dataset is stored as a binary `.rda` file in `data/` with `LazyData: true` in DESCRIPTION, meaning it is available as soon as you type `nfl_lines` without an explicit `data()` call.

---

## What I Would Add Next

If I were developing this into a production package, the next features would be:

1. **Parlay/accumulator calculator** — Extending `calc_kelly()` to handle correlated multi-leg bets.
2. **API integration** — Pulling live odds from the-odds-api.com and running `edge_summary()` in real time.
3. **Shiny dashboard** — A reactive interface where you can adjust model probabilities and watch the edge distribution and Kelly sizing update live.
4. **Model comparison framework** — A function that takes multiple `SportsModel` objects and produces a ranked comparison table.

---

## What I Learned

Building this package changed how I think about three things:

**Code organization.** A script is a conversation with yourself. A package is a conversation with someone who is not in the room. The discipline of writing roxygen2 documentation, structuring functions for export, and building a vignette that tells a story — all of that forced me to think about my code from the user's perspective rather than just my own.

**Type systems.** Before this project, I thought the S3/S4 distinction was a trivia question for exams. After building `model_summary()`, I understand it as a design decision about trust. S3 trusts the programmer; S4 trusts the compiler. Knowing when to use each one is a real skill.

**Testing.** The 19 unit tests in this package are not just a requirement — they are the reason I sleep well when I refactor a function. The S4 validation tests in particular gave me confidence that my model tracker is airtight. When `make_sports_model("Bad", "NFL", 1.5, 100)` throws an error instead of silently creating a corrupt object, that is not a test passing. That is a future bug that never happened.

---

*Ian Alloway — ianalloway@usf.edu*
*LIS 4805 — Spring 2026*
