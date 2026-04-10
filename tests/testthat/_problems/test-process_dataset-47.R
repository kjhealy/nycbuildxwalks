# Extracted from test-process_dataset.R:47

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "nycbuildxwalks", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
gdf <- sf::st_sf(
  other_col = c("a", "b"),
  geometry = sf::st_sfc(
    sf::st_point(c(0, 0)),
    sf::st_point(c(1, 1))
  ),
  crs = 4326
)
expect_message(
  result <- nycbuildxwalks:::standardize_columns(
    gdf,
    "test",
    "missing_col",
    NA
  ),
  "not found"
)
