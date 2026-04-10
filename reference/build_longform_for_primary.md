# Build long-form crosswalk for a single primary geography

For each feature of the primary geography, computes the intersection
area with every feature of each target geography. Returns a tibble with
one row per significant pairwise intersection, including area and
percentage overlap.

## Usage

``` r
build_longform_for_primary(
  all_gdf,
  primary_id,
  other_ids,
  buffer_feet = -50,
  min_area = 100,
  epsilon = 1e-06,
  max_primaries = NULL
)
```

## Arguments

- all_gdf:

  An sf object containing all boundaries, projected to EPSG:2263 (NY
  State Plane, feet).

- primary_id:

  The geography ID to use as the primary (e.g., `"cd"`).

- other_ids:

  Character vector of target geography IDs.

- buffer_feet:

  Negative buffer (in feet) applied during intersection to suppress edge
  artifacts. Default `-50`.

- min_area:

  Minimum intersection area in square feet. Default `100`.

- epsilon:

  Tiny area threshold to suppress numerical noise. Default `1e-6`.

- max_primaries:

  Optional integer to limit the number of primary features processed
  (useful for testing).

## Value

A tibble with columns `primary_geo_id`, `primary_geo_name`,
`other_geo_id`, `other_geo_name`, `primary_area_sqft`,
`intersection_area_sqft`, and `pct_overlap`.
