#' @keywords internal
#'
#' @details
#' `nycbuildxwalks` downloads official NYC geographic boundary data and
#' generates crosswalk tables showing how administrative boundaries overlap.
#' The main entry point is [make_run()], which orchestrates the full pipeline.
#'
#' This package is an R port of the Python tool by Nathan Storey at MODA-NYC
#' (<https://github.com/MODA-NYC/nyc-geography-crosswalks>), which builds on
#' earlier work by BetaNYC (<https://github.com/BetaNYC/nyc-boundaries>).
#'
#' @importFrom rlang .data %||%
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
