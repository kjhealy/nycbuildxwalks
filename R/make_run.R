#' Run the full crosswalk generation pipeline
#'
#' Orchestrates the complete workflow: downloads all NYC boundary datasets
#' via [download_all_boundaries()], then builds crosswalk tables via
#' [build_crosswalks()]. Optionally creates ZIP archives of the outputs.
#'
#' @param output_dir Base directory for outputs. Default `"outputs"`.
#' @param auto_detect_latest Logical. Auto-detect latest DCP cycle. Default
#'   `TRUE`.
#' @param preferred_cycle Optional DCP cycle letter to pin.
#' @param external_data_dir Path to local fallback files. Default
#'   `"data/external"`.
#' @param buffer_feet Negative buffer for intersection de-noising. Default
#'   `-50`.
#' @param min_area_final Minimum intersection area (sq ft). Default `100`.
#' @param epsilon Numerical noise threshold. Default `1e-6`.
#' @param exclude_ids Geography IDs to exclude. Default `"cc_upcoming"`.
#' @param primary_only Optional character vector of primary IDs to build.
#' @param targets Optional character vector of target IDs.
#' @param max_primaries Optional limit on features per primary (for testing).
#' @param zip_artifacts Logical. If `TRUE`, create ZIP archives of the
#'   outputs. Default `FALSE`.
#'
#' @return The path to the timestamped run directory (invisibly).
#'
#' @export
make_run <- function(
  output_dir = "outputs",
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external",
  buffer_feet = -50,
  min_area_final = 100,
  epsilon = 1e-6,
  exclude_ids = "cc_upcoming",
  primary_only = NULL,
  targets = NULL,
  max_primaries = NULL,
  zip_artifacts = FALSE
) {
  run_dir <- download_all_boundaries(
    output_dir = output_dir,
    auto_detect_latest = auto_detect_latest,
    preferred_cycle = preferred_cycle,
    external_data_dir = external_data_dir
  )

  boundaries_path <- file.path(run_dir, "all_boundaries.geojson")
  build_crosswalks(
    boundaries_path = boundaries_path,
    run_dir = run_dir,
    buffer_feet = buffer_feet,
    min_area_final = min_area_final,
    epsilon = epsilon,
    exclude_ids = exclude_ids,
    primary_only = primary_only,
    targets = targets,
    max_primaries = max_primaries
  )

  if (zip_artifacts) {
    zip_run_artifacts(run_dir)
  }

  cli::cli_inform("Pipeline complete: {run_dir}")
  invisible(run_dir)
}


# -- helpers ------------------------------------------------------------------

zip_run_artifacts <- function(run_dir) {
  run_dir <- normalizePath(run_dir)
  run_name <- basename(run_dir)

  # Crosswalks ZIP (longform + wide + crosswalks_meta.json)
  xwalk_zip_name <- paste0("crosswalks__", run_name, ".zip")
  xwalk_files <- c(
    file.path("longform", list.files(file.path(run_dir, "longform"))),
    file.path("wide", list.files(file.path(run_dir, "wide")))
  )
  if (file.exists(file.path(run_dir, "crosswalks_meta.json"))) {
    xwalk_files <- c(xwalk_files, "crosswalks_meta.json")
  }
  if (length(xwalk_files) > 0) {
    withr::with_dir(run_dir, {
      utils::zip(xwalk_zip_name, files = xwalk_files, flags = "-q")
    })
    cli::cli_inform("Wrote {file.path(run_dir, xwalk_zip_name)}")
  }

  # Raw geographies ZIP (individual GeoJSON + all_boundaries + run_meta)
  raw_zip <- file.path(run_dir, paste0("raw_geographies__", run_name, ".zip"))
  raw_files <- c(
    list.files(
      file.path("data", "processed"),
      pattern = "\\.geojson$",
      full.names = TRUE
    ),
    file.path(run_dir, "all_boundaries.geojson"),
    file.path(run_dir, "run_meta.json")
  )
  raw_files <- raw_files[file.exists(raw_files)]
  if (length(raw_files) > 0) {
    utils::zip(raw_zip, files = raw_files, flags = "-q")
    cli::cli_inform("Wrote {raw_zip}")
  }
}
