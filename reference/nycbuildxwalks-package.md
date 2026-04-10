# nycbuildxwalks: Build Geographic Crosswalk Tables for New York City Boundaries

Downloads official New York City geographic boundary data from NYC Open
Data, the Department of City Planning, and other sources, then generates
comprehensive crosswalk tables showing how administrative and spatial
boundaries overlap. Produces wide-format and long-format CSV crosswalks
with intersection area and percentage calculations. Based on the Python
tool by Nathan Storey at MODA-NYC
(<https://github.com/MODA-NYC/nyc-geography-crosswalks>), which builds
on earlier work by BetaNYC
(<https://github.com/BetaNYC/nyc-boundaries>).

## Details

`nycbuildxwalks` downloads official NYC geographic boundary data and
generates crosswalk tables showing how administrative boundaries
overlap. The main entry point is
[`make_run()`](https://kjhealy.github.io/nycbuildxwalks/reference/make_run.md),
which orchestrates the full pipeline.

This package is an R port of the Python tool by Nathan Storey at
MODA-NYC (<https://github.com/MODA-NYC/nyc-geography-crosswalks>), which
builds on earlier work by BetaNYC
(<https://github.com/BetaNYC/nyc-boundaries>).

## See also

Useful links:

- <https://kjhealy.github.io/nycbuildxwalks/>

- <https://github.com/kjhealy/nycbuildxwalks>

- Report bugs at <https://github.com/kjhealy/nycbuildxwalks/issues>

## Author

**Maintainer**: Kieran Healy <kjhealy@gmail.com>
([ORCID](https://orcid.org/0000-0001-9114-981X))

Authors:

- Nathan Storey (Author of the original Python implementation)
