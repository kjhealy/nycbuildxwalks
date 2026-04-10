# Run the full crosswalk generation pipeline

Orchestrates the complete workflow: downloads all NYC boundary datasets
via
[`download_all_boundaries()`](https://kjhealy.github.io/nycbuildxwalks/reference/download_all_boundaries.md),
then builds crosswalk tables via
[`build_crosswalks()`](https://kjhealy.github.io/nycbuildxwalks/reference/build_crosswalks.md).
Optionally creates ZIP archives of the outputs.

## Usage

``` r
make_run(
  output_dir = "outputs",
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external",
  buffer_feet = -50,
  min_area_final = 100,
  epsilon = 1e-06,
  exclude_ids = "cc_upcoming",
  primary_only = NULL,
  targets = NULL,
  max_primaries = NULL,
  zip_artifacts = FALSE
)
```

## Arguments

- output_dir:

  Base directory for outputs. Default `"outputs"`.

- auto_detect_latest:

  Logical. Auto-detect latest DCP cycle. Default `TRUE`.

- preferred_cycle:

  Optional DCP cycle letter to pin.

- external_data_dir:

  Path to local fallback files. Default `"data/external"`.

- buffer_feet:

  Negative buffer for intersection de-noising. Default `-50`.

- min_area_final:

  Minimum intersection area (sq ft). Default `100`.

- epsilon:

  Numerical noise threshold. Default `1e-6`.

- exclude_ids:

  Geography IDs to exclude. Default `"cc_upcoming"`.

- primary_only:

  Optional character vector of primary IDs to build.

- targets:

  Optional character vector of target IDs.

- max_primaries:

  Optional limit on features per primary (for testing).

- zip_artifacts:

  Logical. If `TRUE`, create ZIP archives of the outputs. Default
  `FALSE`.

## Value

The path to the timestamped run directory (invisibly).
