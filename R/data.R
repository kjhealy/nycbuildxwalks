#' NYC geographic dataset definitions
#'
#' A tibble containing metadata for the 15 NYC geographic boundary datasets
#' used to build crosswalk tables. Each row defines a dataset's source URL,
#' the column used for feature names, and the source type.
#'
#' @format ## `nyc_datasets`
#' A tibble with 15 rows and 6 columns:
#' \describe{
#'   \item{id}{Short identifier for the geography (e.g., "cd", "pp", "nta")}
#'   \item{dataset_name}{Human-readable name of the geography}
#'   \item{url}{Source URL for downloading the boundary data}
#'   \item{name_col}{Name of the column in the source data that contains
#'     feature names}
#'   \item{name_alt}{Optional alternate name column, or `NA` if none}
#'   \item{source_type}{One of "dcp_zip" (DCP shapefile zip with cycle
#'     detection), "opendata_shapefile" (NYC Open Data shapefile export),
#'     "opendata_geojson" (NYC Open Data GeoJSON), or "edc_zip" (EDC
#'     shapefile zip)}
#' }
#' @source
#'
#' NYC Department of City Planning (DCP), NYC Open Data, and the NYC Economic
#' Development Corporation (EDC). Dataset definitions adapted from the Python
#' tool by Nathan Storey at MODA-NYC
#' (<https://github.com/MODA-NYC/nyc-geography-crosswalks>).
"nyc_datasets"
