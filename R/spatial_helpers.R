#' Dissolve features by name column
#'
#' Groups features by `name_col` and unions their geometries, producing one
#' feature per unique name. This prevents duplicate rows for multipart
#' features (e.g., some MODZCTAs).
#'
#' @param gdf An sf object with columns `id`, `name_col`, and `geometry`.
#'
#' @return An sf object with one row per unique `name_col` value, with
#'   columns `id`, `name_col`, and dissolved `geometry`.
#'
#' @export
dissolve_by_name <- function(gdf) {
  if (nrow(gdf) == 0) {
    return(gdf)
  }
  gdf |>
    dplyr::group_by(.data$name_col) |>
    dplyr::summarise(
      id = dplyr::first(.data$id),
      geometry = sf::st_union(.data$geometry),
      .groups = "drop"
    ) |>
    dplyr::select("id", "name_col", "geometry")
}

#' Union features by name column
#'
#' Groups features by `name_col` and unions each group's geometry into a
#' single geometry. Returns a tibble of name-geometry pairs rather than an
#' sf object, for use in intersection calculations.
#'
#' @param gdf An sf object with a `name_col` column.
#'
#' @return A tibble with columns `name` (character) and `geometry`
#'   (sfc_GEOMETRY).
#'
#' @export
union_by_name <- function(gdf) {
  if (nrow(gdf) == 0) {
    return(dplyr::tibble(name = character(), geometry = sf::st_sfc()))
  }
  gdf |>
    dplyr::group_by(.data$name_col) |>
    dplyr::summarise(
      geometry = sf::st_union(.data$geometry),
      .groups = "drop"
    ) |>
    dplyr::transmute(
      name = as.character(.data$name_col),
      geometry = .data$geometry
    )
}
