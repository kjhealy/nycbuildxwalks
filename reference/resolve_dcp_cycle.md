# Resolve the latest available DCP cycle for a URL

DCP boundary files are versioned with a cycle suffix (e.g., `_25a.zip`).
This function probes for newer cycles by sending HTTP HEAD requests with
ascending letters (b, c, d, ...) and returns the URL for the highest
available cycle.

## Usage

``` r
resolve_dcp_cycle(url, auto_detect = TRUE, preferred_cycle = NULL)
```

## Arguments

- url:

  A DCP boundary URL containing a cycle suffix like `_25a.zip`.

- auto_detect:

  Logical. If `TRUE` (default), probe for newer cycles.

- preferred_cycle:

  Optional single lowercase letter to pin a specific cycle (e.g.,
  `"d"`). If set and available, overrides auto-detection.

## Value

A list with components:

- `resolved_url`: The URL with the best available cycle.

- `meta`: A list with `cycle_source`, `cycle_resolved`, `auto_detected`,
  and `probes`.
