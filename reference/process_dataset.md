# Download and standardize a single NYC boundary dataset

Downloads a geographic boundary dataset, reads it into an sf object,
reprojects to EPSG:4326, and standardizes the columns to a common schema
(`id`, `name_col`, optionally `name_alt`, and `geometry`).

## Usage

``` r
process_dataset(
  dataset_info,
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external"
)
```

## Arguments

- dataset_info:

  A single-row tibble or list with elements `id`, `dataset_name`, `url`,
  `name_col`, `name_alt`, and `source_type`.

- auto_detect_latest:

  Logical. Passed to
  [`resolve_dcp_cycle()`](https://kjhealy.github.io/nycbuildxwalks/reference/resolve_dcp_cycle.md)
  for DCP zip sources. Default `TRUE`.

- preferred_cycle:

  Optional cycle letter passed to
  [`resolve_dcp_cycle()`](https://kjhealy.github.io/nycbuildxwalks/reference/resolve_dcp_cycle.md).

- external_data_dir:

  Path to a directory containing local fallback files (e.g., `ibz.zip`).
  Default `"data/external"`.

## Value

A list with components:

- `gdf`: An sf object with standardized columns, or `NULL` on failure.

- `meta`: A list with `id`, `original_url`, `resolved_url`, `cycle`,
  `auto_detected`, `status`, and `error`.
