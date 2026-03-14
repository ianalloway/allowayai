# =============================================================================
# Assignment 9: Three Ways to Plot the Same Data in R
# Ian Alloway | LIS 4805 — Data Mining and Predictive Modeling
# University of South Florida | Spring 2026
#
# This script demonstrates base R graphics, lattice, and ggplot2 using the
# mpg dataset from ggplot2. Six total plots across the three systems.
#
# Blog post: https://allowayai.substack.com/p/three-ways-to-plot-the-same-data
# Portfolio: https://ianalloway.xyz
# =============================================================================

# Load required packages
library(lattice)
library(ggplot2)

# =============================================================================
# Dataset
# =============================================================================

# mpg: 234 observations of fuel economy data from 1999–2008
# Source: ggplot2 package (originally from the EPA)
data("mpg", package = "ggplot2")
head(mpg)
str(mpg)


# =============================================================================
# SECTION 1: Base R Graphics
# =============================================================================
# Base R ships with every R installation — no packages required.
# Imperative style: call a function, it draws; call another to add to it.

# --- Plot 1: Scatter — Engine Displacement vs. Highway MPG ---
# Color-coded by cylinder count to show the efficiency gradient.

cyl_colors <- c("4" = "#1b9e77", "5" = "#d95f02",
                "6" = "#7570b3", "8" = "#e7298a")
point_cols <- cyl_colors[as.character(mpg$cyl)]

plot(mpg$displ, mpg$hwy,
     col  = point_cols,
     pch  = 19,
     cex  = 1.2,
     main = "Base R: Engine Displacement vs. Highway MPG",
     xlab = "Engine Displacement (liters)",
     ylab = "Highway MPG")
legend("topright",
       legend = paste(names(cyl_colors), "cyl"),
       col    = cyl_colors,
       pch    = 19,
       title  = "Cylinders")

# The scatter shows the expected inverse relationship: more displacement,
# less fuel efficiency. 4-cylinder engines cluster top-left (small, efficient);
# 8-cylinders sit bottom-right (big, thirsty).


# --- Plot 2: Boxplot — Highway MPG by Vehicle Class ---
# Breaks out the distribution of highway mpg for each vehicle class.

boxplot(hwy ~ class,
        data = mpg,
        col  = rainbow(length(unique(mpg$class)), alpha = 0.6),
        main = "Base R: Highway MPG by Vehicle Class",
        xlab = "Vehicle Class",
        ylab = "Highway MPG",
        las  = 2)

# Subcompacts and compacts lead in highway mpg. Pickups and SUVs trail.
# The two-seater class has a wide range — sports cars span the spectrum.


# =============================================================================
# SECTION 2: Lattice Graphics
# =============================================================================
# Lattice is built for conditioned plots. The | operator splits data into
# panels automatically — ideal for small multiples without extra code.

# --- Plot 3: Conditioned Scatter — Displacement vs. Highway MPG by Drive Type ---
# Panels by drive type; color by cylinder count.

xyplot(hwy ~ displ | factor(drv, labels = c("4WD", "Front", "Rear")),
       data     = mpg,
       groups   = factor(cyl),
       pch      = 19,
       auto.key = list(space = "right", title = "Cylinders"),
       main     = "Lattice: Highway MPG vs. Displacement by Drive Type",
       xlab     = "Engine Displacement (liters)",
       ylab     = "Highway MPG",
       layout   = c(3, 1))

# Splitting by drive type reveals what the base R plot hid:
# Front-wheel-drive dominates the high-efficiency region.
# Rear-wheel-drive clusters at higher displacements.
# 4WD skews toward lower mpg across the board.


# --- Plot 4: Horizontal Box-and-Whisker — City MPG by Vehicle Class ---
# Classes reordered by median city mpg for immediate visual ranking.

bwplot(reorder(class, cty, median) ~ cty,
       data = mpg,
       main = "Lattice: City MPG by Vehicle Class (sorted by median)",
       xlab = "City MPG",
       fill = "steelblue")

# Reordering by median makes the ranking immediately obvious —
# no back-and-forth scanning to compare box positions.


# =============================================================================
# SECTION 3: ggplot2
# =============================================================================
# ggplot2 uses a grammar-of-graphics approach: declare data and aesthetic
# mappings first, then layer on geoms, scales, and themes with +.

# --- Plot 5: Scatter with Per-Group Linear Trends ---
# geom_smooth(method = "lm") adds regression lines per cylinder group in one call.

ggplot(mpg, aes(x = displ, y = hwy, color = factor(cyl))) +
  geom_point(alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_brewer(palette = "Dark2", name = "Cylinders") +
  labs(
    title = "ggplot2: Highway MPG vs. Displacement with Linear Trends",
    x     = "Engine Displacement (liters)",
    y     = "Highway MPG"
  ) +
  theme_minimal(base_size = 13)

# 4-cylinder engines have a steeper efficiency dropoff as displacement increases.
# 8-cylinders are already so inefficient that more displacement barely moves the needle.


# --- Plot 6: Faceted Density Plot — Highway MPG Distribution by Drive Type ---
# facet_wrap splits into panels; geom_density shows the full distributional shape.

ggplot(mpg, aes(x = hwy, fill = factor(drv))) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ drv, labeller = labeller(drv = c(
    "4" = "4WD", "f" = "Front-Wheel", "r" = "Rear-Wheel"
  ))) +
  scale_fill_brewer(palette = "Set2", name = "Drive Type") +
  labs(
    title = "ggplot2: Highway MPG Distribution by Drive Type",
    x     = "Highway MPG",
    y     = "Density"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

# Front-wheel-drive: wide spread with a long right tail.
# Rear-wheel-drive: bimodal — economy cars vs. sports cars.
# 4WD: tight cluster around 17–20 mpg.


# =============================================================================
# Comparison Summary
# =============================================================================
#
# SYNTAX & WORKFLOW
#   Base R   — Imperative. Call a function, it draws. Add to it with more calls.
#   Lattice  — Formula-driven. The | conditioning operator is powerful but
#              customization gets clunky fast.
#   ggplot2  — Declarative and composable. Build layers with +. Reads cleanly
#              and scales well to complex plots.
#
# PUBLICATION QUALITY WITH MINIMAL CODE
#   ggplot2 wins. theme_minimal() + scale_color_brewer() = 90% of the way to
#   a publication-ready figure in two lines. Base R requires manual legend
#   placement and color vector construction. Lattice sits in the middle.
#
# CHALLENGES & SURPRISES
#   Biggest surprise: lattice's | operator for small multiples felt more direct
#   than facet_wrap() in some cases.
#   Biggest challenge: base R's legend system — matching colors between plot
#   and legend requires building the mapping yourself. ggplot2 handles this
#   automatically through its aesthetic system.
#
# VERDICT
#   ggplot2 for daily use. Base R for quick exploratory plots. Lattice when
#   you need conditioning syntax without the ggplot2 overhead.
# =============================================================================
