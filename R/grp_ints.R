#' Group Overlapping Intervals
#'
#' This function groups overlapping intervals in a dataset based on start and end columns.
#' It assigns a unique group ID (`int_grp_id`) to each set of overlapping intervals.
#' Intervals are considered overlapping if the start of one interval is within the gap
#' threshold of the end of another interval.
#'
#' @param .data A data frame or tibble containing the interval data.
#' @param .start The column name (unquoted) representing the start of the intervals.
#' @param .end The column name (unquoted) representing the end of the intervals.
#' @param ... Additional columns to group by before identifying overlapping intervals.
#' @param .gap The maximum allowed gap between intervals for them to be considered overlapping.
#'             Intervals are grouped if the start of one interval is less than or equal to
#'             the end of the previous interval plus the gap.
#'
#' @return A tibble with the original data and an additional column `int_grp_id` indicating
#'         the group ID for overlapping intervals.
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' data <- tibble(
#'   id = 1:5,
#'   start = c(1, 2, 5, 10, 12),
#'   end = c(3, 4, 7, 11, 14)
#' )
#'
#' # Group intervals with a gap of 1
#' grp_ints(data, start, end, .gap = 1)
#' }
#'
#' @export
grp_ints <- function(.data, .start, .end, ..., .gap = 0, .group_col = int_grp_id) {

  # Ensure the input is a data frame or tibble
  if (!is.data.frame(.data)) {
    stop("`.data` must be a data frame or tibble.")
  }

  # return data of 1 row or less
  if (nrow(.data) <= 2) {
    return(.data)
  }

  .data |>
    dplyr::arrange({{ .start }}) |>
    dplyr::mutate(
      cum_max_end = cummax(as.numeric({{ .end }})),
      .id = cumsum(as.numeric({{ .start }}) - .gap > dplyr::lag(cum_max_end, default = -Inf)) + 1,
      .by = c(...),
    ) |>
    dplyr::mutate("{{.group_col}}"  := dplyr::cur_group_id(), .by = c(.id, ...)) |>
    dplyr::select(-cum_max_end, -.id)
}
