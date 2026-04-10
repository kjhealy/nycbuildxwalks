test_that("resolve_dcp_cycle returns original URL for non-DCP URLs", {
  url <- "https://example.com/data.geojson"
  result <- resolve_dcp_cycle(url, auto_detect = FALSE)
  expect_equal(result$resolved_url, url)
  expect_null(result$meta$cycle_source)
})

test_that("resolve_dcp_cycle extracts cycle from DCP URL", {
  url <- "https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/community-districts/nycd_25a.zip"
  result <- resolve_dcp_cycle(url, auto_detect = FALSE)
  expect_equal(result$resolved_url, url)
  expect_equal(result$meta$cycle_source, "25a")
  expect_equal(result$meta$cycle_resolved, "25a")
  expect_false(result$meta$auto_detected)
})

test_that("sub_cycle replaces cycle letter correctly", {
  url <- "https://example.com/nycd_25a.zip"
  result <- nycbuildxwalks:::sub_cycle(url, "25", "d")
  expect_equal(result, "https://example.com/nycd_25d.zip")
})
