#' Merge (pack) Overlapping Intervals
#'
#' This function takes a dataset with intervals (defined by start and end columns) and groups
#' overlapping intervals using `grp_ints`. It then summarizes the intervals by collapsing
#' overlapping intervals into a single interval per group, with the minimum start and maximum end
#' values for each group.
#'
#' @param .data A data frame or tibble containing the interval data.
#' @param .start The column name (unquoted) representing the start of the intervals.
#' @param .end The column name (unquoted) representing the end of the intervals.
#' @param ... Additional columns to group by before identifying and packing intervals.
#' @param .gap The maximum allowed gap between intervals for them to be considered overlapping.
#'             Intervals are grouped if the start of one interval is less than or equal to
#'             the end of the previous interval plus the gap.
#' @param .group_col The name of the column to store the group IDs (default: `int_grp_id`).
#'                   This column is used to group overlapping intervals.
#'
#' @return A tibble with the summarized intervals. Each row represents a packed interval,
#'         with the minimum start value, maximum end value, and the grouping columns.
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
#' # Pack intervals with a gap of 1
#' pac_ints(data, start, end, .gap = 1)
#'
#' # Pack intervals with a custom group column name
#' pac_ints(data, start, end, .gap = 1, .group_col = "group_id")
#' }
#'
#' @export
pac_ints <- function(.data, .start, .end, ..., .gap = 0, .group_col = int_grp_id) {
  res <- grp_ints(.data, {{ .start }}, {{ .end }}, .gap = .gap, .group_col = {{ .group_col }}, ... )

  res |>
    dplyr::summarise(
      "{{.start}}" := min({{ .start }}),
      "{{.end}}" := max({{ .end }}),
      .by = c({{ .group_col }}, ...)
    )
  }
