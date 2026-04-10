#' Build all crosswalk tables from boundary data
#'
#' Reads a combined boundaries GeoJSON file, reprojects to EPSG:2263
#' (NY State Plane, feet) for accurate area calculations, and builds
#' both long-form and wide-format crosswalk CSVs for each primary
#' geography.
#'
#' @param boundaries_path Path to `all_boundaries.geojson`.
#' @param run_dir Output directory for crosswalk CSVs and metadata.
#' @param buffer_feet Negative buffer in feet for intersection de-noising.
#'   Default `-50`.
#' @param min_area_final Minimum intersection area in square feet. Default
#'   `100`.
#' @param epsilon Tiny area to suppress numerical noise. Default `1e-6`.
#' @param exclude_ids Character vector of geography IDs to exclude. Default
#'   `"cc_upcoming"`.
#' @param primary_only Optional character vector to restrict which primary
#'   geography IDs are processed.
#' @param targets Optional character vector to restrict target geography
#'   IDs.
#' @param max_primaries Optional integer to limit features per primary
#'   (for testing).
#'
#' @return The path to `run_dir` (invisibly).
#'
#' @export
build_crosswalks <- function(
  boundaries_path,
  run_dir,
  buffer_feet = -50,
  min_area_final = 100,
  epsilon = 1e-6,
  exclude_ids = "cc_upcoming",
  primary_only = NULL,
  targets = NULL,
  max_primaries = NULL
) {
  cli::cli_inform("Loading boundaries from {boundaries_path}")
  gdf <- sf::st_read(boundaries_path, quiet = TRUE)

  if (is.na(sf::st_crs(gdf)) || sf::st_crs(gdf) != sf::st_crs(2263)) {
    cli::cli_inform("Reprojecting to EPSG:2263 for area computations")
    gdf <- sf::st_transform(gdf, 2263)
  }

  all_ids <- sort(unique(as.character(gdf$id)))
  ids <- setdiff(all_ids, exclude_ids)

  primary_ids <- if (!is.null(primary_only)) {
    intersect(primary_only, ids)
  } else {
    ids
  }

  target_ids <- if (!is.null(targets)) {
    intersect(targets, ids)
  } else {
    ids
  }

  long_dir <- file.path(run_dir, "longform")
  wide_dir <- file.path(run_dir, "wide")
  dir.create(long_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(wide_dir, recursive = TRUE, showWarnings = FALSE)

  for (pid in primary_ids) {
    cli::cli_inform("Building crosswalks for primary={pid}")

    lf <- build_longform_for_primary(
      all_gdf = gdf,
      primary_id = pid,
      other_ids = target_ids,
      buffer_feet = buffer_feet,
      min_area = min_area_final,
      epsilon = epsilon,
      max_primaries = max_primaries
    )
    if (nrow(lf) > 0) {
      lf_path <- file.path(long_dir, paste0("longform_", pid, "_crosswalk.csv"))
      readr::write_csv(lf, lf_path)
      cli::cli_inform("  Saved longform: {basename(lf_path)} ({nrow(lf)} rows)")
    }

    wf <- build_wide_for_primary(
      all_gdf = gdf,
      primary_id = pid,
      other_ids = target_ids,
      buffer_feet = buffer_feet,
      min_area = min_area_final,
      epsilon = epsilon,
      max_primaries = max_primaries
    )
    if (nrow(wf) > 0) {
      wf_path <- file.path(wide_dir, paste0("wide_", pid, "_crosswalk.csv"))
      readr::write_csv(wf, wf_path)
      cli::cli_inform("  Saved wide: {basename(wf_path)} ({nrow(wf)} rows)")
    }
  }

  meta <- list(
    buffer_feet = buffer_feet,
    min_intersection_area_final = min_area_final,
    epsilon = epsilon,
    exclude_ids = exclude_ids,
    primary_ids = primary_ids,
    target_ids = target_ids
  )
  meta_path <- file.path(run_dir, "crosswalks_meta.json")
  jsonlite::write_json(meta, meta_path, pretty = TRUE, auto_unbox = TRUE)
  cli::cli_inform("Saved crosswalks metadata to {meta_path}")

  invisible(run_dir)
}
