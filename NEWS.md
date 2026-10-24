# nycbuildxwalks 0.0.0.9001

* Boundary layers labelled with a geographic CRS but holding coordinates
  outside longitude/latitude ranges are now treated as EPSG:2263 (NY State
  Plane, US feet), with a warning, before reprojection. The NYC Open Data
  Historic Districts GeoJSON (`hd`) currently has State Plane coordinates
  labelled as EPSG:4326, which previously produced near-global polygons and
  made `build_crosswalks()` fail with a GEOS topology error.

* The Business Improvement Districts layer (`bid`) now takes feature names
  from `f_all_bi_2`. NYC Open Data changed the dataset's schema, and the
  previous name column, `f_all_bids`, now holds numeric codes (`0.0` for
  several districts), so distinct districts were merged when dissolving by
  name.

* `process_dataset()` now warns when every value of a layer's name column
  looks like a decimal number, a sign that the source schema has changed.

* Invalid geometries in the combined boundaries are now repaired with GEOS in
  planar coordinates rather than with s2 on the sphere, matching the original
  Python tool. s2 repair could turn a polygon with reversed ring orientation
  into its complement.

# nycbuildxwalks 0.0.0.9000

* Initial package creation. Port of the Python NYC geography crosswalks tool
  by Nathan Storey at MODA-NYC.
* Added `nyc_datasets` tibble with definitions for 15 NYC geographic boundary
  datasets.
* Added `download_all_boundaries()` to download and combine boundary data from
  official NYC sources.
* Added `build_crosswalks()` to generate long-form and wide-format crosswalk
  CSVs from boundary data.
* Added `make_run()` to orchestrate the full pipeline.
