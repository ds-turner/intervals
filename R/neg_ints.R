#' Generate Negative Intervals Between Positive Intervals
#'
#' The `neg_ints` function calculates negative intervals (gaps) between positive intervals in a dataset.
#' It is useful for identifying gaps in time-based or sequential data where intervals are defined by
#' start and end points. The function allows for the specification of lower and upper bounds, as well
#' as a gap size between intervals.
#'
#' @param .data A data frame or tibble containing the interval data.
#' @param .start The column name in `.data` representing the start of the intervals.
#' @param .end The column name in `.data` representing the end of the intervals.
#' @param ... Additional columns to group by when calculating negative intervals.
#' @param .lower (Optional) The column name or value representing the lower bound for the intervals.
#'   If `NULL`, no lower bound is applied.
#' @param .upper (Optional) The column name or value representing the upper bound for the intervals.
#'   If `NULL`, no upper bound is applied.
#' @param .gap (Optional) The size of the gap between intervals. Default is `1`.
#' @param pac_ints (Optional) A logical value indicating whether to use `pac_ints` for interval calculation.
#'   If `FALSE`, the function uses `dplyr::select` to extract relevant columns. Default is `FALSE`.
#'
#' @return A data frame or tibble containing both positive and negative intervals, with columns for
#'   start, end, lower bound, upper bound, and interval type (`int_type`).
#'
#' @details
#' - The function calculates negative intervals by identifying gaps between positive intervals in the dataset.
#' - If `.lower` is provided, the function ensures that the negative intervals do not fall below the
#'   specified lower bound.
#' - If `.upper` is provided, the function ensures that the negative intervals do not exceed the
#'   specified upper bound.
#' - The function groups the data by the columns specified in `...` to calculate intervals within each group.
#' - The `int_type` column is added to the output to distinguish between positive (`"pos"`) and
#'   negative (`"neg"`) intervals.
#'
#' @examples
#'
#' data <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   start = c(1, 5, 2, 6),
#'   end = c(3, 7, 4, 8)
#' )
#'
#' result <- neg_ints(data, start, end, id, .gap = 1)
#' print(result)
#'
#' @export
neg_ints <- function(.data, .start, .end, ..., .lower = NULL, .upper = NULL, .gap = 1, pac_ints = FALSE) {

  has_lower <- !rlang::quo_is_null(rlang::enquo(.lower))
  has_upper <- !rlang::quo_is_null(rlang::enquo(.upper))

  # .lower and .upper must be the same per ID

  if (pac_ints) {
    ints <- pac_ints(.data, ..., {{ .start }}, {{ .end }}, {{ .lower }}, {{ .upper }})
  } else {
    ints <- dplyr::select(.data, ..., {{ .start }}, {{ .end }}, {{ .lower }}, {{ .upper }})
  }

  ints <- ints |>
    dplyr::mutate(
      int_type = "pos"
    )

  neg_ints <- get_neg_ints(.data, {{ .start }}, {{ .end }}, ..., .lower = {{ .lower }}, .upper = {{ .upper }}, .gap = .gap)

  all_ints <- rbind(ints, neg_ints) |>
    apply_bounds({{ .start }}, {{ .end }}, {{ .lower }}, {{ .upper }}, ...)

  all_ints |>
    dplyr::arrange(..., {{ .start }}, dplyr::desc({{ .end }}))
}


# Helper functions --------------------------------------------------------

get_neg_ints <- function(.data, .start, .end, ..., .lower = NULL, .upper = NULL, .gap = 1) {

  has_lower <- !rlang::quo_is_null(rlang::enquo(.lower))

  neg_ints <- .data |>
    dplyr::mutate(
      neg_start = {{ .end }} + .gap,
      neg_end = dplyr::lead({{ .start }} - .gap, default = Inf),
      int_type = "neg",
      .by = c(...)
    )

  if (has_lower) {

    prior_neg_ints <- .data |>
      dplyr::mutate(
        neg_start = dplyr::lag({{ .end }} + .gap, default = -Inf),
        neg_end = {{ .start }} - .gap,
        int_type = "neg",
        .by = c(...)
      )

    neg_ints <- rbind(neg_ints, prior_neg_ints) |>
      dplyr::select(-{{ .start }}, -{{ .end }}) |>
      dplyr::distinct()
  }

  neg_ints <- neg_ints |>
    dplyr::select(
      ...,
      "{{.start}}" := neg_start,
      "{{.end}}" := neg_end,
      {{ .lower }},
      {{ .upper }},
      int_type
    )

  return(neg_ints)
}


apply_bounds <- function(ints, .start, .end, .lower, .upper, ...) {

  has_lower <- !rlang::quo_is_null(rlang::enquo(.lower))
  has_upper <- !rlang::quo_is_null(rlang::enquo(.upper))

  ints <- dplyr::group_by(ints, ...)

  if (has_lower) {
    ints <- ints |>
      dplyr::filter({{ .end }} >= {{ .lower }}) |>
      dplyr::mutate(
        "{{.start}}" := ifelse({{ .start }} == -Inf, {{ .lower }}, {{ .start }})
      )
  }

  if (has_upper) {
    ints <- ints |>
      dplyr::filter({{ .start }} <= {{ .upper }}) |>
      dplyr::mutate(
        "{{.end}}" := ifelse({{ .end }} == Inf, {{ .upper }}, {{ .end }})
      )

  }

  ints |>
    dplyr::filter(
      {{ .start }} != -Inf,
      {{ .end }} != Inf,
      ) |>
    dplyr::ungroup()
}
