#' Download and combine all NYC boundary datasets
#'
#' Iterates over the datasets defined in [nyc_datasets], downloads each one
#' via [process_dataset()], combines them into a single sf object, fixes
#' invalid geometries, and writes the results to a timestamped output
#' directory.
#'
#' @param output_dir Base directory for timestamped run outputs. Default
#'   `"outputs"`.
#' @param auto_detect_latest Logical. Attempt to auto-detect the latest DCP
#'   cycle letter. Default `TRUE`.
#' @param preferred_cycle Optional single letter to pin a DCP cycle.
#' @param external_data_dir Path to local fallback files. Default
#'   `"data/external"`.
#' @param datasets A tibble of dataset definitions. Defaults to
#'   [nyc_datasets].
#'
#' @return The path to the timestamped run directory (invisibly).
#'
#' @export
download_all_boundaries <- function(
  output_dir = "outputs",
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external",
  datasets = NULL
) {
  if (is.null(datasets)) {
    datasets <- nycbuildxwalks::nyc_datasets
  }

  run_id <- format(Sys.time(), "%Y-%m-%d_%H%M%S_UTC", tz = "UTC")
  run_dir <- file.path(output_dir, run_id)
  processed_dir <- file.path("data", "processed")
  dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)

  run_meta <- list(
    run_id = run_id,
    git_sha = tryCatch(
      system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
      error = function(e) NULL,
      warning = function(w) NULL
    ),
    config = list(
      auto_detect_latest = auto_detect_latest,
      preferred_cycle = preferred_cycle,
      target_crs = "EPSG:4326"
    ),
    datasets = list()
  )

  all_gdfs <- list()

  for (i in seq_len(nrow(datasets))) {
    ds <- as.list(datasets[i, ])
    result <- process_dataset(
      ds,
      auto_detect_latest = auto_detect_latest,
      preferred_cycle = preferred_cycle,
      external_data_dir = external_data_dir
    )

    run_meta$datasets <- c(
      run_meta$datasets,
      list(list(
        id = result$meta$id,
        original_url = result$meta$original_url,
        resolved_url = result$meta$resolved_url,
        cycle = result$meta$cycle,
        auto_detected = result$meta$auto_detected,
        status = result$meta$status,
        error = result$meta$error
      ))
    )

    if (!is.null(result$gdf)) {
      all_gdfs <- c(all_gdfs, list(result$gdf))
      save_individual_geojson(result$gdf, ds$id, processed_dir)
    }
  }

  if (length(all_gdfs) == 0) {
    cli::cli_abort("No datasets were processed successfully.")
  }

  combined <- combine_and_validate(all_gdfs)
  save_combined_output(combined, run_dir, processed_dir)
  save_run_meta(run_meta, run_dir)

  cli::cli_inform("Run complete: {run_dir}")
  invisible(run_dir)
}


# -- helpers ------------------------------------------------------------------

save_individual_geojson <- function(gdf, dataset_id, processed_dir) {
  path <- file.path(processed_dir, paste0(dataset_id, ".geojson"))
  tryCatch(
    {
      sf::st_write(
        gdf,
        path,
        driver = "GeoJSON",
        delete_dsn = TRUE,
        quiet = TRUE
      )
      cli::cli_inform("  Saved {dataset_id} to {path}")
    },
    error = function(e) {
      cli::cli_warn("  Failed to save {dataset_id}: {conditionMessage(e)}")
    }
  )
}

combine_and_validate <- function(gdfs) {
  cli::cli_inform("Combining all datasets")

  # Ensure all sf objects have the same columns before binding.
  # Some datasets have name_alt, others don't.
  all_cols <- unique(unlist(lapply(gdfs, function(x) {
    setdiff(names(x), "geometry")
  })))
  gdfs <- lapply(gdfs, function(x) {
    missing <- setdiff(all_cols, names(x))
    for (col in missing) {
      x[[col]] <- NA_character_
    }
    x
  })

  combined <- do.call(rbind, gdfs)

  invalid <- !sf::st_is_valid(combined)
  if (any(invalid, na.rm = TRUE)) {
    n_invalid <- sum(invalid, na.rm = TRUE)
    cli::cli_inform(
      "Fixing {n_invalid} invalid geometr{?y/ies} with st_make_valid()"
    )
    combined <- sf::st_make_valid(combined)
  }

  combined
}

save_combined_output <- function(combined, run_dir, processed_dir) {
  run_path <- file.path(run_dir, "all_boundaries.geojson")
  sf::st_write(
    combined,
    run_path,
    driver = "GeoJSON",
    delete_dsn = TRUE,
    quiet = TRUE
  )
  cli::cli_inform("Saved combined boundaries to {run_path}")

  convenience_path <- file.path(processed_dir, "all_boundaries.geojson")
  sf::st_write(
    combined,
    convenience_path,
    driver = "GeoJSON",
    delete_dsn = TRUE,
    quiet = TRUE
  )
  cli::cli_inform("Saved convenience copy to {convenience_path}")
}

save_run_meta <- function(run_meta, run_dir) {
  meta_path <- file.path(run_dir, "run_meta.json")
  jsonlite::write_json(run_meta, meta_path, pretty = TRUE, auto_unbox = TRUE)
  cli::cli_inform("Saved run metadata to {meta_path}")
}
