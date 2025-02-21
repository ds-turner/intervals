#' Trim Intervals Based on Overlaps
#'
#' The `trm_ints` function trims intervals in dataset `x` based on overlaps with intervals in dataset `y`.
#' It splits intervals in `x` at the boundaries of overlaps with `y`, removes unwanted intervals, and
#' returns the resulting intervals. Optionally, the output can be ordered by start and end points.
#'
#' @param x A data frame or tibble containing the primary intervals to be trimmed.
#' @param y A data frame or tibble containing the intervals used to trim `x`.
#' @param .x_start The column name in `x` representing the start of the intervals.
#' @param .x_end The column name in `x` representing the end of the intervals.
#' @param .y_start The column name in `y` representing the start of the intervals.
#' @param .y_end The column name in `y` representing the end of the intervals.
#' @param ... Additional columns to group by when calculating overlaps and trimming intervals.
#' @param order A logical value indicating whether to order the resulting intervals by start and end points.
#'   Default is `TRUE`.
#'
#' @return A data frame or tibble containing the trimmed intervals from `x`, with columns for start, end,
#'   and any grouping variables.
#'
#' @details
#' - The function identifies overlaps between intervals in `x` and `y` using the `get_overlaps` helper function.
#' - It calculates split points at the boundaries of overlapping intervals using the `get_split_points` helper function.
#' - The intervals in `x` are split at these points using the `split_ints` helper function.
#' - Unwanted intervals (those overlapping with `y`) are removed using the `rm_ints` helper function.
#' - If `order = TRUE`, the resulting intervals are ordered by start and end points.
#'
#' @examples
#' library(dplyr)
#'
#' x <- tibble(
#'   id = c(1, 1, 2, 2),
#'   start = c(1, 5, 2, 6),
#'   end = c(4, 8, 5, 9)
#' )
#'
#' y <- tibble(
#'   id = c(1, 2),
#'   start = c(2, 4),
#'   end = c(6, 7)
#' )
#'
#' result <- trm_ints(x, y, start, end, start, end, id)
#' print(result)
#'
#' @export
trm_ints <- function(x, y, .x_start, .x_end, .y_start, .y_end, ..., order = TRUE) {

  overlaps <- get_overlaps(x, y, {{ .x_start }}, {{ .x_end }}, {{ .y_start }}, {{ .y_end }}, ...)

  split_points <- get_split_points(overlaps, ...)

  # split up the ints
  ints <- split_ints(x, split_points, {{ .x_start }}, {{ .x_end }}, ...)

  # remove the new intervals that we don't want
  ints <- rm_ints(x, y, ints, {{ .x_start }}, {{ .x_end }}, {{ .y_start }}, {{ .y_end }}, ..., order = order)

  return(ints)

}


# Helper functions --------------------------------------------------------

get_overlaps <- function(x, y, .x_start, .x_end, .y_start, .y_end, ...) {
  dplyr::full_join(
    dplyr::select(x, ..., {{ .x_start }}, {{ .x_end }}),
    dplyr::select(y, ..., {{ .y_start }}, {{ .y_end }}),
    by = dplyr::join_by(..., overlaps({{ .x_start }}, {{ .x_end }}, {{ .y_start }}, {{ .y_end }}))
  )
}

get_split_points <- function(.data, ...) {

  grp_cols <- names(rlang::enquos(..., .named = TRUE))

  .data |>
    tidyr::pivot_longer(
      cols = !all_of(grp_cols),
      values_to = "point"
    ) |>
    dplyr::distinct(..., point) |>
    dplyr::arrange(..., point)

}

split_ints <- function(x, split_points, .x_start, .x_end, ..., split_point = point, gap = 0) {
  # gap is a place holder
  ints <- dplyr::full_join(
    split_points,
    x,
    by = dplyr::join_by(..., between({{ split_point }}, {{ .x_start }}, {{ .x_end }}))
  )

  ints <- ints |>
    dplyr::mutate(# work out the new splits
      next_split = dplyr::lead({{ split_point }}),
      .by = c(...)
    ) |>
    dplyr::filter(!is.na(next_split)) |>
    dplyr::mutate(
      "{{.x_start}}" := {{ split_point }},
      "{{.x_end}}" := next_split
    ) |>
    dplyr::select(..., {{ .x_start }}, {{ .x_end }})

  return(ints)
}

rm_ints <- function(x, y, ints, .x_start, .x_end, .y_start, .y_end, ..., order = TRUE) {

  # keep the intervals that overlap with x
  ints <- ints |>
    dplyr::semi_join(
      x,
      by = dplyr::join_by(..., within({{ .x_start }}, {{ .x_end }}, {{ .x_start }}, {{ .x_end }}))
    )

  # remove the intervals that overlap with y
  ints <- ints |>
    dplyr::anti_join(
      y,
      by = dplyr::join_by(..., within({{ .x_start }}, {{ .x_end }}, {{ .y_start }}, {{ .y_end }}))
    )

  # return
  if(order) { # ordered
    return(dplyr::arrange(ints, ..., {{ .x_start }}, {{ .x_end }}))
  } else {
    return(ints)
  }
}
