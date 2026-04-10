#' Build wide-format crosswalk for a single primary geography
#'
#' For each feature of the primary geography, finds overlapping features
#' from all target geographies and returns a tibble with one row per primary
#' feature and one column per target geography (values are semicolon-separated
#' names of overlapping features).
#'
#' @inheritParams build_longform_for_primary
#'
#' @return A tibble with one row per primary feature. The first column is
#'   named after `primary_id` and contains the primary feature names.
#'   Remaining columns are named after each target geography ID and contain
#'   semicolon-separated overlapping feature names.
#'
#' @export
build_wide_for_primary <- function(
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
    return(dplyr::tibble())
  }

  primary_dissolved <- dissolve_by_name(primary_src)
  if (!is.null(max_primaries) && max_primaries > 0) {
    primary_dissolved <- utils::head(primary_dissolved, max_primaries)
  }

  other_ids <- setdiff(other_ids, primary_id)
  sorted_others <- sort(other_ids)
  rows <- vector("list", nrow(primary_dissolved))

  for (i in seq_len(nrow(primary_dissolved))) {
    p_row <- primary_dissolved[i, ]
    p_name <- as.character(p_row$name_col)
    p_geom <- sf::st_geometry(p_row)[[1]]
    if (is.null(p_geom) || sf::st_is_empty(p_geom)) {
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

    record <- stats::setNames(
      vector("list", length(sorted_others) + 1L),
      c(primary_id, sorted_others)
    )
    record[[primary_id]] <- p_name

    for (other_id in sorted_others) {
      subset <- candidates[candidates$id == other_id, ]
      keep_names <- character()

      if (nrow(subset) > 0) {
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
          if (inter_area > max(min_area, epsilon)) {
            keep_names <- c(keep_names, t_name)
          }
        }
      }
      record[[other_id]] <- paste(sort(unique(keep_names)), collapse = ";")
    }

    rows[[i]] <- dplyr::as_tibble(record)
  }

  rows <- purrr::compact(rows)
  if (length(rows) == 0) {
    return(dplyr::tibble())
  }

  dplyr::bind_rows(rows)
}
