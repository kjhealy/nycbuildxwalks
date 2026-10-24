test_that("make_valid_planar repairs without producing near-global polygons", {
  # A self-intersecting ("bowtie") polygon in lower Manhattan.
  bowtie <- sf::st_polygon(list(rbind(
    c(-74.01, 40.70),
    c(-74.00, 40.71),
    c(-74.00, 40.70),
    c(-74.01, 40.71),
    c(-74.01, 40.70)
  )))
  gdf <- sf::st_sf(id = "x", geometry = sf::st_sfc(bowtie, crs = 4326))

  expect_message(
    result <- nycbuildxwalks:::make_valid_planar(gdf),
    "invalid"
  )
  bbox <- sf::st_bbox(result)
  expect_true(all(sf::st_is_valid(result)))
  expect_lt(bbox[["xmax"]] - bbox[["xmin"]], 0.1)
  expect_lt(bbox[["ymax"]] - bbox[["ymin"]], 0.1)
})

test_that("make_valid_planar restores the s2 setting", {
  before <- sf::sf_use_s2()
  gdf <- sf::st_sf(
    id = "x",
    geometry = sf::st_sfc(sf::st_point(c(-74, 40.7)), crs = 4326)
  )
  nycbuildxwalks:::make_valid_planar(gdf)
  expect_identical(sf::sf_use_s2(), before)
})
