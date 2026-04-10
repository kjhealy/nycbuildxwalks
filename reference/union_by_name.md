# Union features by name column

Groups features by `name_col` and unions each group's geometry into a
single geometry. Returns a tibble of name-geometry pairs rather than an
sf object, for use in intersection calculations.

## Usage

``` r
union_by_name(gdf)
```

## Arguments

- gdf:

  An sf object with a `name_col` column.

## Value

A tibble with columns `name` (character) and `geometry` (sfc_GEOMETRY).
