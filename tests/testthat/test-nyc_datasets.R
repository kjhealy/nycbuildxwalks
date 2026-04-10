test_that("nyc_datasets has expected structure", {
  expect_s3_class(nyc_datasets, "tbl_df")
  expect_equal(nrow(nyc_datasets), 15)
  expect_named(
    nyc_datasets,
    c("id", "dataset_name", "url", "name_col", "name_alt", "source_type")
  )
})

test_that("nyc_datasets IDs are unique", {
  expect_equal(length(unique(nyc_datasets$id)), nrow(nyc_datasets))
})

test_that("nyc_datasets source_type values are valid", {
  valid_types <- c(
    "dcp_zip",
    "opendata_shapefile",
    "opendata_geojson",
    "edc_zip"
  )
  expect_true(all(nyc_datasets$source_type %in% valid_types))
})

test_that("nyc_datasets URLs are non-empty", {
  expect_true(all(nchar(nyc_datasets$url) > 0))
})

test_that("nyc_datasets contains expected geographies", {
  expected_ids <- c(
    "bid",
    "cc",
    "cd",
    "dsny",
    "fb",
    "hc",
    "hd",
    "ibz",
    "nta",
    "nycongress",
    "pp",
    "sa",
    "sd",
    "ss",
    "zipcode"
  )

  expect_setequal(nyc_datasets$id, expected_ids)
})
