# nycbuildxwalks ![](reference/figures/nycbuildxwalks.png)

nycbuildxwalks downloads official New York City geographic boundary data
and generates comprehensive crosswalk tables showing how administrative
and spatial boundaries overlap. It produces both wide-format and
long-format CSV crosswalks with intersection area and percentage
calculations.

This is an R port of the [Python NYC geography crosswalks
tool](https://github.com/MODA-NYC/nyc-geography-crosswalks) by Nathan
Storey at [MODA-NYC](https://github.com/MODA-NYC), which builds on
earlier work by [BetaNYC](https://github.com/BetaNYC/nyc-boundaries).

## Supported geographies

| id         | dataset_name                       |
|:-----------|:-----------------------------------|
| cd         | Community Districts                |
| pp         | Police Precincts                   |
| dsny       | Sanitation Districts               |
| fb         | Fire Battalions                    |
| sd         | School Districts                   |
| hc         | Health Center Districts            |
| cc         | City Council Districts             |
| nycongress | Congressional Districts            |
| sa         | State Assembly Districts           |
| ss         | State Senate Districts             |
| bid        | Business Improvement Districts     |
| nta        | Neighborhood Tabulation Areas      |
| zipcode    | Modified ZIP Code Tabulation Areas |
| hd         | Historic Districts                 |
| ibz        | Industrial Business Zones          |

## Installation

You can install the development version of nycbuildxwalks from GitHub
with:

``` r
# install.packages("pak")
pak::pak("kjhealy/nycbuildxwalks")
```

## Usage

The main entry point is
[`make_run()`](https://kjhealy.github.io/nycbuildxwalks/reference/make_run.md),
which orchestrates the full pipeline:

``` r
library(nycbuildxwalks)

# Full run: download boundaries and build all crosswalks
run_dir <- make_run()

# With ZIP archives
run_dir <- make_run(zip_artifacts = TRUE)

# Test with limited features
run_dir <- make_run(max_primaries = 2, primary_only = c("cd", "pp"))
```

You can also run individual steps:

``` r
# Step 1: Download and combine boundaries
run_dir <- download_all_boundaries()

# Step 2: Build crosswalks from existing boundaries
build_crosswalks(
  boundaries_path = file.path(run_dir, "all_boundaries.geojson"),
  run_dir = run_dir
)
```

## Methodology

- **ZIP codes are MODZCTAs**: The `zipcode` layer uses DOHMH MODZCTA
  polygons. Results may differ from USPS ZIP definitions.

- **Geometry validity**: After combining inputs, invalid geometries are
  repaired with
  [`sf::st_make_valid()`](https://r-spatial.github.io/sf/reference/valid.html).

- **Intersection de-noising**: A small negative buffer (-50 ft by
  default) is applied during intersection to reduce line-touching
  artifacts. Candidates are not filtered by this buffer. After
  intersection, a minimum area threshold (100 sq ft) suppresses noise.

- **Multipart primaries**: Primary features are dissolved by name so
  multipart geometries are treated as a single unit.

- **Area calculations**: All spatial operations use EPSG:2263 (NY State
  Plane, feet) for accurate area computation.

## Outputs

Each run produces a timestamped directory under `outputs/` containing:

- `all_boundaries.geojson` — combined boundary file
- `run_meta.json` — source URLs, cycle resolutions, git SHA
- `longform/` — one CSV per primary geography with pairwise intersection
  details
- `wide/` — one CSV per primary geography with semicolon-separated
  overlapping feature names
- `crosswalks_meta.json` — buffer, thresholds, and IDs used

## Acknowledgements

This package is based on the Python tool by [Nathan
Storey](https://github.com/npstorey) at
[MODA-NYC](https://github.com/MODA-NYC/nyc-geography-crosswalks), which
builds on the concepts and data aggregation methods originally
implemented in the [BetaNYC NYC Boundaries Map
repository](https://github.com/BetaNYC/nyc-boundaries).

Hexlogo Photo: Detail from “Brooklyn Paving 5-25-16”, NYC DOT.
