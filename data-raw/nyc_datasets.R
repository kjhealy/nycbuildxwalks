## code to prepare `nyc_datasets` dataset goes here

nyc_datasets <- readr::read_csv(
  "data-raw/nyc_datasets.csv",
  col_types = readr::cols(.default = readr::col_character()),
  na = ""
)

usethis::use_data(nyc_datasets, overwrite = TRUE)
