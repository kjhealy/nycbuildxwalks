# Create a simple test geometry: two overlapping squares for two geographies

make_test_boundaries <- function() {
  # Primary: one big square (0,0)-(10,10) = 100 sq units

  # Target: two features, one overlapping half (0,0)-(5,10) and one partial (8,0)-(12,10)
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

test_that("build_longform_for_primary produces expected output", {
  gdf <- make_test_boundaries()

  result <- build_longform_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("primary", "target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) >= 2)
  expect_named(
    result,
    c(
      "primary_geo_id",
      "primary_geo_name",
      "other_geo_id",
      "other_geo_name",
      "primary_area_sqft",
      "intersection_area_sqft",
      "pct_overlap"
    )
  )

  # T1 should overlap 50%
  t1_row <- result[result$other_geo_name == "T1", ]
  expect_equal(nrow(t1_row), 1)
  expect_equal(t1_row$pct_overlap, 50, tolerance = 1)

  # T2 should overlap 20% (2 out of 10 width)
  t2_row <- result[result$other_geo_name == "T2", ]
  expect_equal(nrow(t2_row), 1)
  expect_equal(t2_row$pct_overlap, 20, tolerance = 1)
})

test_that("build_longform_for_primary respects min_area", {
  gdf <- make_test_boundaries()

  result <- build_longform_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 25,
    epsilon = 1e-6
  )

  # T2 overlap is 20 sq units, should be excluded with min_area=25
  expect_equal(nrow(result), 1)
  expect_equal(result$other_geo_name, "T1")
})

test_that("build_longform_for_primary returns empty for missing primary", {
  gdf <- make_test_boundaries()

  result <- build_longform_for_primary(
    all_gdf = gdf,
    primary_id = "nonexistent",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6
  )

  expect_equal(nrow(result), 0)
})

test_that("build_longform_for_primary respects max_primaries", {
  gdf <- sf::st_sf(
    id = c("primary", "primary", "target"),
    name_col = c("P1", "P2", "T1"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 5, 0, 5, 5, 0, 5, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(6, 0, 10, 0, 10, 5, 6, 5, 6, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(0, 0, 10, 0, 10, 5, 0, 5, 0, 0),
        ncol = 2,
        byrow = TRUE
      )))
    ),
    crs = 2263
  )

  result <- build_longform_for_primary(
    all_gdf = gdf,
    primary_id = "primary",
    other_ids = c("target"),
    buffer_feet = 0,
    min_area = 0,
    epsilon = 1e-6,
    max_primaries = 1
  )

  # Should only process first primary feature
  expect_equal(length(unique(result$primary_geo_name)), 1)
})
