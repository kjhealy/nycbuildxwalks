# Download and combine all NYC boundary datasets

Iterates over the datasets defined in
[nyc_datasets](https://kjhealy.github.io/nycbuildxwalks/reference/nyc_datasets.md),
downloads each one via
[`process_dataset()`](https://kjhealy.github.io/nycbuildxwalks/reference/process_dataset.md),
combines them into a single sf object, fixes invalid geometries, and
writes the results to a timestamped output directory.

## Usage

``` r
download_all_boundaries(
  output_dir = "outputs",
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external",
  datasets = NULL
)
```

## Arguments

- output_dir:

  Base directory for timestamped run outputs. Default `"outputs"`.

- auto_detect_latest:

  Logical. Attempt to auto-detect the latest DCP cycle letter. Default
  `TRUE`.

- preferred_cycle:

  Optional single letter to pin a DCP cycle.

- external_data_dir:

  Path to local fallback files. Default `"data/external"`.

- datasets:

  A tibble of dataset definitions. Defaults to
  [nyc_datasets](https://kjhealy.github.io/nycbuildxwalks/reference/nyc_datasets.md).

## Value

The path to the timestamped run directory (invisibly).
