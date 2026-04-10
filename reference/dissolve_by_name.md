# Dissolve features by name column

Groups features by `name_col` and unions their geometries, producing one
feature per unique name. This prevents duplicate rows for multipart
features (e.g., some MODZCTAs).

## Usage

``` r
dissolve_by_name(gdf)
```

## Arguments

- gdf:

  An sf object with columns `id`, `name_col`, and `geometry`.

## Value

An sf object with one row per unique `name_col` value, with columns
`id`, `name_col`, and dissolved `geometry`.
