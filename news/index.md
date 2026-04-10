# Changelog

## nycbuildxwalks (development version)

- Initial package creation. Port of the Python NYC geography crosswalks
  tool by Nathan Storey at MODA-NYC.
- Added `nyc_datasets` tibble with definitions for 15 NYC geographic
  boundary datasets.
- Added
  [`download_all_boundaries()`](https://kjhealy.github.io/nycbuildxwalks/reference/download_all_boundaries.md)
  to download and combine boundary data from official NYC sources.
- Added
  [`build_crosswalks()`](https://kjhealy.github.io/nycbuildxwalks/reference/build_crosswalks.md)
  to generate long-form and wide-format crosswalk CSVs from boundary
  data.
- Added
  [`make_run()`](https://kjhealy.github.io/nycbuildxwalks/reference/make_run.md)
  to orchestrate the full pipeline.
