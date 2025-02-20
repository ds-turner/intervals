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
