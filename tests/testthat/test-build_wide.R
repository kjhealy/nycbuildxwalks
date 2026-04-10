make_test_boundaries <- function() {
  sf::st_sf(
    id = c("primary", "target", "target"),
    name_col = c("P1", "T1", "T2"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(0, 0, 5, 0, 5, 10, 0, 10, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(8, 0, 12, 0, 12, 10, 8, 10, 8, 0),
        ncol = 2,
        byrow = TRUE
      )))
    ),
    crs = 2263
  )
}

test_that("build_wide_for_primary produces expected structure", {
  gdf <- make_test_boundaries()

  result <- build_wide_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("primary", "target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_true("primary" %in% names(result))
  expect_true("target" %in% names(result))
  expect_equal(result$primary, "P1")
})

test_that("build_wide_for_primary uses semicolon separator", {
  gdf <- make_test_boundaries()

  result <- build_wide_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6
  )

  # Both T1 and T2 overlap, so should be semicolon-separated
  expect_true(grepl(";", result$target))
  expect_true(grepl("T1", result$target))
  expect_true(grepl("T2", result$target))
})

test_that("build_wide_for_primary respects min_area", {
  gdf <- make_test_boundaries()

  result <- build_wide_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 25,
    epsilon = 1e-6
  )

  # T2 overlap is 20 sq units, excluded; only T1 remains
  expect_equal(result$target, "T1")
})

test_that("build_wide_for_primary returns empty for missing primary", {
  gdf <- make_test_boundaries()

  result <- build_wide_for_primary(
    all_gdf = gdf,
    primary_id = "nonexistent",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6
  )

  expect_equal(nrow(result), 0)
})
