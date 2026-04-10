#' Resolve the latest available DCP cycle for a URL
#'
#' DCP boundary files are versioned with a cycle suffix (e.g., `_25a.zip`).
#' This function probes for newer cycles by sending HTTP HEAD requests with
#' ascending letters (b, c, d, ...) and returns the URL for the highest
#' available cycle.
#'
#' @param url A DCP boundary URL containing a cycle suffix like `_25a.zip`.
#' @param auto_detect Logical. If `TRUE` (default), probe for newer cycles.
#' @param preferred_cycle Optional single lowercase letter to pin a specific
#'   cycle (e.g., `"d"`). If set and available, overrides auto-detection.
#'
#' @return A list with components:
#'   - `resolved_url`: The URL with the best available cycle.
#'   - `meta`: A list with `cycle_source`, `cycle_resolved`, `auto_detected`,
#'     and `probes`.
#'
#' @export
resolve_dcp_cycle <- function(url, auto_detect = TRUE, preferred_cycle = NULL) {
  meta <- list(
    cycle_source = NULL,
    cycle_resolved = NULL,
    auto_detected = FALSE,
    probes = list()
  )

  m <- stringr::str_match(url, "_(\\d{2})([a-z])\\.zip$")
  if (is.na(m[1, 1])) {
    return(list(resolved_url = url, meta = meta))
  }

  cycle_num <- m[1, 2]
  cycle_letter <- m[1, 3]
  meta$cycle_source <- paste0(cycle_num, cycle_letter)

  if (!is.null(preferred_cycle) && grepl("^[a-z]$", preferred_cycle)) {
    candidate <- sub_cycle(url, cycle_num, preferred_cycle)
    meta$probes <- c(
      meta$probes,
      list(list(url = candidate, type = "preferred"))
    )
    if (url_exists(candidate)) {
      meta$cycle_resolved <- paste0(cycle_num, preferred_cycle)
      meta$auto_detected <- FALSE
      return(list(resolved_url = candidate, meta = meta))
    }
  }

  if (!auto_detect) {
    meta$cycle_resolved <- meta$cycle_source
    return(list(resolved_url = url, meta = meta))
  }

  best_url <- url
  best_letter <- cycle_letter
  start_ord <- utf8ToInt(cycle_letter) + 1L
  end_ord <- utf8ToInt("z")

  for (ord in seq(start_ord, end_ord)) {
    letter <- intToUtf8(ord)
    candidate <- sub_cycle(url, cycle_num, letter)
    meta$probes <- c(
      meta$probes,
      list(list(url = candidate, type = "autodetect"))
    )
    if (url_exists(candidate)) {
      best_url <- candidate
      best_letter <- letter
    }
  }

  meta$cycle_resolved <- paste0(cycle_num, best_letter)
  meta$auto_detected <- best_letter != cycle_letter
  list(resolved_url = best_url, meta = meta)
}


# -- helpers ------------------------------------------------------------------

sub_cycle <- function(url, cycle_num, letter) {
  stringr::str_replace(
    url,
    "_\\d{2}[a-z]\\.zip$",
    paste0("_", cycle_num, letter, ".zip")
  )
}

url_exists <- function(url) {
  tryCatch(
    {
      resp <- httr2::request(url) |>
        httr2::req_method("HEAD") |>
        httr2::req_timeout(10) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
      httr2::resp_status(resp) == 200L
    },
    error = function(e) FALSE
  )
}
