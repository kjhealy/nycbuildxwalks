test_that("build_crosswalks writes CSV files and metadata", {
  # Create a small test GeoJSON
  gdf <- sf::st_sf(
    id = c("geo_a", "geo_a", "geo_b"),
    name_col = c("A1", "A2", "B1"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 5, 0, 5, 5, 0, 5, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      sf::st_polygon(list(matrix(
        c(5, 0, 10, 0, 10, 5, 5, 5, 5, 0),
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

  withr::with_tempdir({
    geojson_path <- "test_boundaries.geojson"
    sf::st_write(gdf, geojson_path, driver = "GeoJSON", quiet = TRUE)

    run_dir <- "test_run"

    build_crosswalks(
      boundaries_path = geojson_path,
      run_dir = run_dir,
      buffer_feet = 0,
      min_area_final = 0,
      epsilon = 1e-6,
      exclude_ids = character()
    )

    # Check directory structure
    expect_true(dir.exists(file.path(run_dir, "longform")))
    expect_true(dir.exists(file.path(run_dir, "wide")))

    # Check metadata
    expect_true(file.exists(file.path(run_dir, "crosswalks_meta.json")))
    meta <- jsonlite::read_json(file.path(run_dir, "crosswalks_meta.json"))
    expect_equal(meta$buffer_feet, 0)

    # Check CSVs exist
    long_files <- list.files(
      file.path(run_dir, "longform"),
      pattern = "\\.csv$"
    )
    wide_files <- list.files(file.path(run_dir, "wide"), pattern = "\\.csv$")
    expect_true(length(long_files) > 0)
    expect_true(length(wide_files) > 0)
  })
})
