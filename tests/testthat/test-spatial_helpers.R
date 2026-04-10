test_that("dissolve_by_name unions multipart features", {
  gdf <- sf::st_sf(
    id = c("cd", "cd"),
    name_col = c("101", "101"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(2, 0, 3, 0, 3, 1, 2, 1, 2, 0),
        ncol = 2,
        byrow = TRUE
      )))
    ),
    crs = 2263
  )

  result <- dissolve_by_name(gdf)
  expect_equal(nrow(result), 1)
  expect_equal(result$name_col, "101")
  expect_equal(result$id, "cd")
})

test_that("dissolve_by_name keeps distinct features separate", {
  gdf <- sf::st_sf(
    id = c("cd", "cd"),
    name_col = c("101", "102"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(2, 0, 3, 0, 3, 1, 2, 1, 2, 0),
        ncol = 2,
        byrow = TRUE
      )))
    ),
    crs = 2263
  )

  result <- dissolve_by_name(gdf)
  expect_equal(nrow(result), 2)
})

test_that("dissolve_by_name handles empty sf", {
  gdf <- sf::st_sf(
    id = character(),
    name_col = character(),
    geometry = sf::st_sfc(crs = 2263)
  )

  result <- dissolve_by_name(gdf)
  expect_equal(nrow(result), 0)
})

test_that("union_by_name returns name-geometry pairs", {
  gdf <- sf::st_sf(
    name_col = c("A", "A", "B"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(1, 0, 2, 0, 2, 1, 1, 1, 1, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(3, 0, 4, 0, 4, 1, 3, 1, 3, 0),
        ncol = 2,
        byrow = TRUE
      )))
    ),
    crs = 2263
  )

  result <- union_by_name(gdf)
  expect_equal(nrow(result), 2)
  expect_named(result, c("name", "geometry"))
  expect_setequal(result$name, c("A", "B"))
})

test_that("union_by_name handles empty sf", {
  gdf <- sf::st_sf(
    name_col = character(),
    geometry = sf::st_sfc(crs = 2263)
  )

  result <- union_by_name(gdf)
  expect_equal(nrow(result), 0)
})
