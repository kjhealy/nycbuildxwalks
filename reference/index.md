# Package index

## Data

Bundled dataset definitions

- [`nyc_datasets`](https://kjhealy.github.io/nycbuildxwalks/reference/nyc_datasets.md)
  : NYC geographic dataset definitions

## Pipeline

Run the full crosswalk generation pipeline

- [`make_run()`](https://kjhealy.github.io/nycbuildxwalks/reference/make_run.md)
  : Run the full crosswalk generation pipeline

## Boundary download

Download and process NYC geographic boundaries

- [`download_all_boundaries()`](https://kjhealy.github.io/nycbuildxwalks/reference/download_all_boundaries.md)
  : Download and combine all NYC boundary datasets
- [`process_dataset()`](https://kjhealy.github.io/nycbuildxwalks/reference/process_dataset.md)
  : Download and standardize a single NYC boundary dataset
- [`resolve_dcp_cycle()`](https://kjhealy.github.io/nycbuildxwalks/reference/resolve_dcp_cycle.md)
  : Resolve the latest available DCP cycle for a URL

## Crosswalk building

Build crosswalk tables from boundary data

- [`build_crosswalks()`](https://kjhealy.github.io/nycbuildxwalks/reference/build_crosswalks.md)
  : Build all crosswalk tables from boundary data
- [`build_longform_for_primary()`](https://kjhealy.github.io/nycbuildxwalks/reference/build_longform_for_primary.md)
  : Build long-form crosswalk for a single primary geography
- [`build_wide_for_primary()`](https://kjhealy.github.io/nycbuildxwalks/reference/build_wide_for_primary.md)
  : Build wide-format crosswalk for a single primary geography

## Spatial helpers

Low-level spatial operations

- [`dissolve_by_name()`](https://kjhealy.github.io/nycbuildxwalks/reference/dissolve_by_name.md)
  : Dissolve features by name column
- [`union_by_name()`](https://kjhealy.github.io/nycbuildxwalks/reference/union_by_name.md)
  : Union features by name column
