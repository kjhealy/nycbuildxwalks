test_that("standardize_columns produces correct schema", {
  gdf <- sf::st_sf(
    BoroCD = c("101", "102"),
    geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      sf::st_point(c(1, 1))
    ),
    crs = 4326
  )

  result <- nycbuildxwalks:::standardize_columns(gdf, "cd", "BoroCD", NA)
  expect_s3_class(result, "sf")
  expect_named(result, c("id", "name_col", "geometry"))
  expect_equal(result$id, c("cd", "cd"))
  expect_equal(result$name_col, c("101", "102"))
})

test_that("standardize_columns handles name_alt", {
  gdf <- sf::st_sf(
    NTAName = c("Midtown", "Harlem"),
    NTA2020 = c("MN01", "MN02"),
    geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      sf::st_point(c(1, 1))
    ),
    crs = 4326
  )

  result <- nycbuildxwalks:::standardize_columns(
    gdf,
    "nta",
    "NTAName",
    "NTA2020"
  )
  expect_true("name_alt" %in% names(result))
  expect_equal(result$name_alt, c("MN01", "MN02"))
})

test_that("standardize_columns warns on missing column", {
  gdf <- sf::st_sf(
    other_col = c("a", "b"),
    geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      sf::st_point(c(1, 1))
    ),
    crs = 4326
  )

  expect_warning(
    result <- nycbuildxwalks:::standardize_columns(
      gdf,
      "test",
      "missing_col",
      NA
    ),
    "not found"
  )
  expect_true(all(is.na(result$name_col)))
})

test_that("reproject_to_4326 transforms from 2263", {
  gdf <- sf::st_sf(
    x = 1,
    geometry = sf::st_sfc(sf::st_point(c(981219, 200000)), crs = 2263)
  )

  result <- nycbuildxwalks:::reproject_to_4326(gdf, "test", "test.zip")
  expect_equal(sf::st_crs(result)$epsg, 4326L)
})

test_that("try_local_fallback returns NULL when no fallback exists", {
  result <- nycbuildxwalks:::try_local_fallback("nonexistent", tempdir())
  expect_null(result)
})
