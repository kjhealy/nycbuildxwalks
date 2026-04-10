# Build all crosswalk tables from boundary data

Reads a combined boundaries GeoJSON file, reprojects to EPSG:2263 (NY
State Plane, feet) for accurate area calculations, and builds both
long-form and wide-format crosswalk CSVs for each primary geography.

## Usage

``` r
build_crosswalks(
  boundaries_path,
  run_dir,
  buffer_feet = -50,
  min_area_final = 100,
  epsilon = 1e-06,
  exclude_ids = "cc_upcoming",
  primary_only = NULL,
  targets = NULL,
  max_primaries = NULL
)
```

## Arguments

- boundaries_path:

  Path to `all_boundaries.geojson`.

- run_dir:

  Output directory for crosswalk CSVs and metadata.

- buffer_feet:

  Negative buffer in feet for intersection de-noising. Default `-50`.

- min_area_final:

  Minimum intersection area in square feet. Default `100`.

- epsilon:

  Tiny area to suppress numerical noise. Default `1e-6`.

- exclude_ids:

  Character vector of geography IDs to exclude. Default `"cc_upcoming"`.

- primary_only:

  Optional character vector to restrict which primary geography IDs are
  processed.

- targets:

  Optional character vector to restrict target geography IDs.

- max_primaries:

  Optional integer to limit features per primary (for testing).

## Value

The path to `run_dir` (invisibly).
