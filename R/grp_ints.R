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
#' @param .group_col The name of the column that will indicate the group ID for overlapping intervals.  Defualt is int_grp_id.
#'
#' @return A tibble with the original data and an additional column indicating
#'         the group ID for overlapping intervals.
#'
#' @examples
#' \dontrun{
#' data <- data.frame(
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

  # create a data.table if
  if(!data.table::is.data.table(.data)) {
    .data <- data.table::as.data.table(.data)
  }

  .data <- .data[order(..., .start),env = list(
    .start = substitute(.start)
  )]

  # Step 2: Calculate cumulative max of 'end' and create id for overlapping intergers
  grp_vars <- eval(substitute(alist(...)), envir = parent.frame())
  .data[ , .group_col := cumsum(cummax(shift(as.numeric(.end), fill = as.numeric(.end)[1])) < as.numeric(.start) - .gap), by = grp_vars,
       env = list(
         .group_col =  substitute(.group_col),
         grp_vars = substitute(grp_vars),
         .start = substitute(.start),
         .end = substitute(.end)
       )
  ]

  grp_vars2 <- eval(substitute(alist(..., .group_col)), envir = parent.frame())

  # Step 3: Create 'int_grp_id' based on '.id' and 'id'
  .data[, .group_col := .GRP, by = grp_vars2,
      env = list(
        grp_vars2 =  substitute(grp_vars2),
        .group_col =  substitute(.group_col)
      )
  ]

  return(.data[])
}
