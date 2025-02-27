#' Merge Overlapping Intervals
#'
#' This function takes a dataset with ints (defined by start and end columns) and groups
#' overlapping ints using `grp_ints`. It then summarizes the ints by collapsing
#' overlapping ints into a single interval per group, with the minimum start and maximum end
#' values for each group.
#'
#' @param .data A data frame containing the interval data.
#' @param .start The column name (unquoted) representing the start of the ints.
#' @param .end The column name (unquoted) representing the end of the ints.
#' @param ... Additional columns to group by before identifying and merging ints.
#' @param .gap The maximum allowed gap between ints for them to be considered overlapping.
#'             Intervals are grouped if the start of one interval is less than or equal to
#'             the end of the previous interval plus the gap.
#' @param .group_col The name of the column to store the group IDs (default: `int_grp_id`).
#'                   This column is used to group overlapping ints.
#'
#' @return A `data.table` with the summarized ints. Each row represents a packed interval,
#'         with the minimum start value, maximum end value, the grouping columns and the `.group_id` column.
#'
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   id = 1:5,
#'   start = c(1, 2, 5, 10, 12),
#'   end = c(3, 4, 7, 11, 14)
#' )
#'
#' # Merge ints with a gap of 1
#' merge_ints(data, start, end, .gap = 1)
#'
#' # Merge ints with a custom group column name
#' merge_ints(data, start, end, .gap = 1, .group_col = "group_id")
#' }
#'
#' @export
merge_ints <- function(.data, .start, .end, ..., .gap = 0, .group_col = int_grp_id) {

  x <- .data

  dt <- eval(substitute(grp_ints(x, .start, .end, ..., .gap = .gap, .group_col = .group_col)))


  grp_vars2 <- eval(substitute(alist(..., .group_col)), envir = parent.frame())

  dt <- dt[, list(.start = min(.start), .end = max(.end)), by = grp_vars2,
           env = list(
             grp_vars2 =  substitute(grp_vars2),
             .start = substitute(.start),
             .end = substitute(.end)
           )
  ]

  return(dt)
}


