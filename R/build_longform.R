#' Build long-form crosswalk for a single primary geography
#'
#' For each feature of the primary geography, computes the intersection area
#' with every feature of each target geography. Returns a tibble with one
#' row per significant pairwise intersection, including area and percentage
#' overlap.
#'
#' @param all_gdf An sf object containing all boundaries, projected to
#'   EPSG:2263 (NY State Plane, feet).
#' @param primary_id The geography ID to use as the primary (e.g., `"cd"`).
#' @param other_ids Character vector of target geography IDs.
#' @param buffer_feet Negative buffer (in feet) applied during intersection
#'   to suppress edge artifacts. Default `-50`.
#' @param min_area Minimum intersection area in square feet. Default `100`.
#' @param epsilon Tiny area threshold to suppress numerical noise. Default
#'   `1e-6`.
#' @param max_primaries Optional integer to limit the number of primary
#'   features processed (useful for testing).
#'
#' @return A tibble with columns `primary_geo_id`, `primary_geo_name`,
#'   `other_geo_id`, `other_geo_name`, `primary_area_sqft`,
#'   `intersection_area_sqft`, and `pct_overlap`.
#'
#' @export
build_longform_for_primary <- function(
  all_gdf,
  primary_id,
  other_ids,
  buffer_feet = -50,
  min_area = 100,
  epsilon = 1e-6,
  max_primaries = NULL
) {
  primary_src <- all_gdf[all_gdf$id == primary_id, ]
  if (nrow(primary_src) == 0) {
    cli::cli_warn("No features for primary id={primary_id}")
    return(empty_longform())
  }

  primary_dissolved <- dissolve_by_name(primary_src)
  if (!is.null(max_primaries) && max_primaries > 0) {
    primary_dissolved <- utils::head(primary_dissolved, max_primaries)
  }

  other_ids <- setdiff(other_ids, primary_id)
  records <- vector("list", nrow(primary_dissolved) * length(other_ids))
  idx <- 0L

  for (i in seq_len(nrow(primary_dissolved))) {
    p_row <- primary_dissolved[i, ]
    p_name <- as.character(p_row$name_col)
    p_geom <- sf::st_geometry(p_row)[[1]]
    if (is.null(p_geom) || sf::st_is_empty(p_geom)) {
      next
    }

    p_area <- as.numeric(sf::st_area(p_row))
    if (p_area <= epsilon) {
      next
    }

    p_geom_buffered <- if (buffer_feet != 0) {
      sf::st_buffer(
        sf::st_sfc(p_geom, crs = sf::st_crs(all_gdf)),
        buffer_feet
      )[[1]]
    } else {
      p_geom
    }

    candidates <- all_gdf[
      sf::st_intersects(p_row, all_gdf, sparse = FALSE)[1, ],
    ]

    for (other_id in other_ids) {
      subset <- candidates[candidates$id == other_id, ]
      if (nrow(subset) == 0) {
        next
      }

      target_unions <- union_by_name(subset)
      for (j in seq_len(nrow(target_unions))) {
        t_name <- target_unions$name[j]
        t_geom <- sf::st_geometry(target_unions[j, ])[[1]]
        if (is.null(t_geom) || sf::st_is_empty(t_geom)) {
          next
        }

        inter_geom <- sf::st_intersection(
          sf::st_sfc(p_geom_buffered, crs = sf::st_crs(all_gdf)),
          sf::st_sfc(t_geom, crs = sf::st_crs(all_gdf))
        )
        if (length(inter_geom) == 0 || sf::st_is_empty(inter_geom[[1]])) {
          next
        }

        inter_area <- as.numeric(sf::st_area(inter_geom))
        if (inter_area <= max(min_area, epsilon)) {
          next
        }

        pct <- (inter_area / p_area) * 100
        idx <- idx + 1L
        records[[idx]] <- list(
          primary_geo_id = primary_id,
          primary_geo_name = p_name,
          other_geo_id = other_id,
          other_geo_name = t_name,
          primary_area_sqft = p_area,
          intersection_area_sqft = inter_area,
          pct_overlap = pct
        )
      }
    }
  }

  if (idx == 0L) {
    return(empty_longform())
  }

  dplyr::bind_rows(records[seq_len(idx)]) |>
    dplyr::arrange(
      .data$primary_geo_name,
      .data$other_geo_id,
      dplyr::desc(.data$pct_overlap)
    )
}


# -- helpers ------------------------------------------------------------------

empty_longform <- function() {
  dplyr::tibble(
    primary_geo_id = character(),
    primary_geo_name = character(),
    other_geo_id = character(),
    other_geo_name = character(),
    primary_area_sqft = double(),
    intersection_area_sqft = double(),
    pct_overlap = double()
  )
}
