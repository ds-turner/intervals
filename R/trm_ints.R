#' Trim Intervals Based on Overlaps
#'
#' The `trm_ints` function trims intervals in dataset `x` based on overlaps with intervals in dataset `y`.
#' It splits intervals in `x` at the boundaries of overlaps with `y`, removes unwanted intervals, and
#' returns the resulting intervals. Optionally, the output can be ordered by start and end points.
#'
#' @param x A data frame containing the primary intervals to be trimmed.
#' @param y A data frame containing the intervals used to trim `x`.
#' @param .x_start The column name in `x` representing the start of the intervals.
#' @param .x_end The column name in `x` representing the end of the intervals.
#' @param .y_start The column name in `y` representing the start of the intervals.
#' @param .y_end The column name in `y` representing the end of the intervals.
#' @param ... Additional columns to group by when calculating overlaps and trimming intervals.
#' @param .gap The gaps left when intervals are trimmed. Default is 0.
#' @param order A logical value indicating whether to order the resulting intervals by start and end points.
#'   Default is `TRUE`.
#'
#' @return A `data.table` containing the trimmed intervals from `x`, with columns for start, end,
#'   and any grouping variables.
#'
#' @details
#' If `x` and `y` contains overlapping intervals you may get unexpected results.  Please use `merge_ints` if required.
#'
#' @examples
#' x <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   start = c(1, 5, 2, 6),
#'   end = c(4, 8, 5, 9)
#' )
#'
#' y <- data.frame(
#'   id = c(1, 2),
#'   start = c(2, 4),
#'   end = c(6, 7)
#' )
#'
#' result <- trm_ints(x, y, start, end, start, end, id)
#' print(result)
#'
#' @export
trm_ints <- function(x, y, .x_start, .x_end, .y_start, .y_end, ..., .gap = 0, order = TRUE) {

  # create a data.table if
  if(!data.table::is.data.table(x)) {
    x <- data.table::as.data.table(x)
  }

  # create a data.table if
  if(!data.table::is.data.table(y)) {
    y <- data.table::as.data.table(y)
  }

  # split up the ints into the smallest possible parts
  i <- eval(substitute(split_ints_dt(x, y, .x_start, .x_end, .y_start, .y_end, ..., .gap = .gap)))

  # remove the parts thqt we dont want
  i <- eval(substitute(rm_ints_dt(i, x, y, .x_start, .x_end, .y_start, .y_end, ...)))

  if(order) {
    eval(substitute(setorder(i, ..., .x_start, .x_end)))
  }

  return(i)
}

# Helper functions --------------------------------------------------------

split_ints_dt <- function(x, y, .x_start, .x_end, .y_start, .y_end, ..., .gap) {
  # get all the split points
  points <- rbindlist(
    list(
      x[, stx, env = list(stx = eval(substitute(alist(..., point = .x_start))))],
      x[, enx, env = list(enx = eval(substitute(alist(..., point = .x_end))))],
      y[, sty, env = list(sty = eval(substitute(alist(..., point = .y_start))))],
      y[, eny, env = list(eny = eval(substitute(alist(..., point = .y_end))))]
    )
  )

  # create new intervals
  eval(substitute(setorder(points, point)))
  points[, let(.x_end = shift(point, type = "lead") - .gap, .x_start = point + .gap), by = grp_vars,
         env = list(
           .x_end = substitute(.x_end),
           .x_start = substitute(.x_start),
           grp_vars = eval(substitute(alist(...)))
         )]

  # drop incomplete intervals and select cols
  points[!is.na(.x_end), vars,
         env = list(
           .x_end = substitute(.x_end),
           vars = eval(substitute(alist(..., .x_start, .x_end)))
         )]
}

get_withins <- function(x, y, .x_start, .x_end, .y_start, .y_end, ..., which = F) {

  ids <- names(rlang::enquos(..., .named = TRUE))
  .x_start <- deparse(substitute(.x_start))
  .x_end <- deparse(substitute(.x_end))
  .y_start <- deparse(substitute(.y_start))
  .y_end <- deparse(substitute(.y_end))

  join_spec = c(ids, paste(.x_start, ">=", .y_start), paste(.x_end,"<=",.y_end))

  x[y, on = join_spec, which = which]

}

rm_ints_dt <- function(i, x, y, .x_start, .x_end, .y_start, .y_end, ...) {

  ids <- names(rlang::enquos(..., .named = TRUE))
  .x_start <- deparse(substitute(.x_start))
  .x_end <- deparse(substitute(.x_end))
  .y_start <- deparse(substitute(.y_start))
  .y_end <- deparse(substitute(.y_end))

  join_spec = c(ids, paste(.x_start, "<=", .x_start), paste(.x_end,">=",.x_end))
  i <- x[i, on = join_spec, nomatch = NULL]

  join_spec = c(ids, paste(.x_start, ">=", .y_start), paste(.x_end,"<=",.y_end))
  i[!y, on = join_spec]

}
