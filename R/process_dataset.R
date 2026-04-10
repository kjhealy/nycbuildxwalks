#' Download and standardize a single NYC boundary dataset
#'
#' Downloads a geographic boundary dataset, reads it into an sf object,
#' reprojects to EPSG:4326, and standardizes the columns to a common schema
#' (`id`, `name_col`, optionally `name_alt`, and `geometry`).
#'
#' @param dataset_info A single-row tibble or list with elements `id`,
#'   `dataset_name`, `url`, `name_col`, `name_alt`, and `source_type`.
#' @param auto_detect_latest Logical. Passed to [resolve_dcp_cycle()] for
#'   DCP zip sources. Default `TRUE`.
#' @param preferred_cycle Optional cycle letter passed to
#'   [resolve_dcp_cycle()].
#' @param external_data_dir Path to a directory containing local fallback
#'   files (e.g., `ibz.zip`). Default `"data/external"`.
#'
#' @return A list with components:
#'   - `gdf`: An sf object with standardized columns, or `NULL` on failure.
#'   - `meta`: A list with `id`, `original_url`, `resolved_url`, `cycle`,
#'     `auto_detected`, `status`, and `error`.
#'
#' @export
process_dataset <- function(
  dataset_info,
  auto_detect_latest = TRUE,
  preferred_cycle = NULL,
  external_data_dir = "data/external"
) {
  dataset_id <- dataset_info$id
  url <- dataset_info$url
  name_col_key <- dataset_info$name_col
  name_alt_key <- dataset_info$name_alt
  source_type <- dataset_info$source_type

  cli::cli_inform(
    "Processing dataset: {dataset_id} ({dataset_info$dataset_name})"
  )

  meta <- list(
    id = dataset_id,
    original_url = url,
    resolved_url = url,
    cycle = NULL,
    auto_detected = FALSE,
    status = "pending",
    error = NULL
  )

  resolved_url <- url
  if (source_type == "dcp_zip") {
    cycle_result <- resolve_dcp_cycle(
      url,
      auto_detect = auto_detect_latest,
      preferred_cycle = preferred_cycle
    )
    resolved_url <- cycle_result$resolved_url
    meta$resolved_url <- resolved_url
    meta$cycle <- cycle_result$meta$cycle_resolved %||%
      cycle_result$meta$cycle_source
    meta$auto_detected <- cycle_result$meta$auto_detected
  }

  gdf <- read_boundary(
    resolved_url,
    dataset_id,
    source_type,
    external_data_dir
  )

  if (is.null(gdf)) {
    meta$status <- "read_error"
    meta$error <- "Failed to read boundary data"
    return(list(gdf = NULL, meta = meta))
  }

  gdf <- reproject_to_4326(gdf, dataset_id, url)
  if (is.null(gdf)) {
    meta$status <- "reproject_error"
    meta$error <- "Failed to reproject to EPSG:4326"
    return(list(gdf = NULL, meta = meta))
  }

  gdf <- standardize_columns(gdf, dataset_id, name_col_key, name_alt_key)
  if (is.null(gdf)) {
    meta$status <- "standardize_error"
    meta$error <- "Failed to standardize columns"
    return(list(gdf = NULL, meta = meta))
  }

  meta$status <- "ok"
  list(gdf = gdf, meta = meta)
}


# -- helpers ------------------------------------------------------------------

read_boundary <- function(url, dataset_id, source_type, external_data_dir) {
  if (source_type %in% c("opendata_geojson")) {
    tryCatch(
      {
        cli::cli_inform("  Reading GeoJSON directly from URL")
        sf::st_read(url, quiet = TRUE)
      },
      error = function(e) {
        cli::cli_warn(
          "  Failed to read GeoJSON for {dataset_id}: {conditionMessage(e)}"
        )
        NULL
      }
    )
  } else {
    read_shapefile_zip(url, dataset_id, source_type, external_data_dir)
  }
}

read_shapefile_zip <- function(
  url,
  dataset_id,
  source_type,
  external_data_dir
) {
  zip_path <- download_zip(url, dataset_id, external_data_dir)
  if (is.null(zip_path)) {
    return(NULL)
  }

  # Validate that the downloaded file is actually a zip
  if (!is_valid_zip(zip_path)) {
    cli::cli_warn(
      "  Downloaded file for {dataset_id} is not a valid zip (possibly HTML redirect or error page)"
    )
    return(NULL)
  }

  tryCatch(
    {
      temp_dir <- withr::local_tempdir()
      utils::unzip(zip_path, exdir = temp_dir)
      shp_files <- list.files(
        temp_dir,
        pattern = "\\.shp$",
        recursive = TRUE,
        full.names = TRUE
      )
      if (length(shp_files) == 0) {
        cli::cli_warn("  No .shp file found in zip for {dataset_id}")
        return(NULL)
      }
      cli::cli_inform("  Reading shapefile: {basename(shp_files[[1]])}")
      sf::st_read(shp_files[[1]], quiet = TRUE)
    },
    error = function(e) {
      cli::cli_warn(
        "  Failed to read shapefile for {dataset_id}: {conditionMessage(e)}"
      )
      NULL
    }
  )
}

is_valid_zip <- function(path) {
  if (!file.exists(path)) {
    return(FALSE)
  }
  # ZIP files start with "PK" (bytes 0x50, 0x4B)
  tryCatch(
    {
      con <- file(path, "rb")
      on.exit(close(con))
      magic <- readBin(con, "raw", n = 2)
      length(magic) == 2 && magic[1] == as.raw(0x50) && magic[2] == as.raw(0x4B)
    },
    error = function(e) FALSE
  )
}

download_zip <- function(url, dataset_id, external_data_dir) {
  tryCatch(
    {
      cli::cli_inform("  Downloading zip for {dataset_id}")
      temp_file <- tempfile(fileext = ".zip")
      resp <- httr2::request(url) |>
        httr2::req_timeout(60) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform(path = temp_file)

      status <- httr2::resp_status(resp)
      if (status != 200L) {
        cli::cli_warn(
          "  HTTP {status} for {dataset_id}, trying fallback"
        )
        return(try_local_fallback(dataset_id, external_data_dir))
      }

      # Check that the response is actually a zip, not HTML
      if (!is_valid_zip(temp_file)) {
        cli::cli_warn(
          "  Response for {dataset_id} is not a valid zip file, trying fallback"
        )
        return(try_local_fallback(dataset_id, external_data_dir))
      }

      temp_file
    },
    error = function(e) {
      cli::cli_warn(
        "  Download failed for {dataset_id}: {conditionMessage(e)}"
      )
      try_local_fallback(dataset_id, external_data_dir)
    }
  )
}

try_local_fallback <- function(dataset_id, external_data_dir) {
  candidates <- c(
    file.path(external_data_dir, paste0(dataset_id, ".zip")),
    file.path(external_data_dir, paste0(dataset_id, ".ZIP")),
    system.file(
      "extdata",
      paste0(dataset_id, ".zip"),
      package = "nycbuildxwalks"
    )
  )
  # system.file returns "" if not found, so filter those out
  candidates <- candidates[nchar(candidates) > 0]
  for (path in candidates) {
    if (file.exists(path)) {
      cli::cli_inform("  Using local fallback: {path}")
      return(path)
    }
  }
  cli::cli_warn("  No local fallback found for {dataset_id}")
  NULL
}

reproject_to_4326 <- function(gdf, dataset_id, url) {
  tryCatch(
    {
      if (is.na(sf::st_crs(gdf))) {
        default_crs <- if (grepl("\\.geojson$", url, ignore.case = TRUE)) {
          4326L
        } else {
          2263L
        }
        cli::cli_inform(
          "  CRS missing for {dataset_id}, assuming EPSG:{default_crs}"
        )
        sf::st_crs(gdf) <- default_crs
      }
      if (sf::st_crs(gdf) != sf::st_crs(4326)) {
        cli::cli_inform("  Reprojecting {dataset_id} to EPSG:4326")
        gdf <- sf::st_transform(gdf, 4326)
      }
      gdf
    },
    error = function(e) {
      cli::cli_warn(
        "  Reprojection failed for {dataset_id}: {conditionMessage(e)}"
      )
      NULL
    }
  )
}

standardize_columns <- function(gdf, dataset_id, name_col_key, name_alt_key) {
  tryCatch(
    {
      result <- sf::st_sf(
        id = dataset_id,
        name_col = if (name_col_key %in% names(gdf)) {
          as.character(gdf[[name_col_key]])
        } else {
          cli::cli_warn("  Column '{name_col_key}' not found in {dataset_id}")
          NA_character_
        },
        geometry = sf::st_geometry(gdf)
      )

      if (!is.na(name_alt_key) && name_alt_key %in% names(gdf)) {
        result$name_alt <- as.character(gdf[[name_alt_key]])
      }

      result
    },
    error = function(e) {
      cli::cli_warn(
        "  Standardization failed for {dataset_id}: {conditionMessage(e)}"
      )
      NULL
    }
  )
}
