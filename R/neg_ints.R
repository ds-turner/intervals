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
#'@details
#' If `.data` contains overlapping intervals you may get unexpected results.  Please use `merge_ints` if required.
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
neg_ints <- function(.data, .start, .end, ..., .lower = NULL, .upper = NULL, .gap = 1) {

  # create a data.table if
  if(!data.table::is.data.table(.data)) {
    .data <- data.table::as.data.table(.data)
  }

  eval(substitute(setorder(.data, ..., .start)))

  has_lower <- !rlang::quo_is_null(rlang::enquo(.lower))
  has_upper <- !rlang::quo_is_null(rlang::enquo(.upper))

  neg_ints <- eval(substitute(get_neg_ints_dt(.data, .start, .end, ..., .lower = .lower, .upper = .upper, .gap = .gap)))

  # early return for unbounded
  if(!has_lower & !has_upper) {
    return(neg_ints[.end != Inf & .start != -Inf, env = list(.start = substitute(.start), .end = substitute(.end))])
  }

  neg_ints_bounded <- eval(substitute(apply_bounds_dt(neg_ints, .start, .end, .lower, .upper)))

  return(neg_ints_bounded)

}

# helper functions
get_neg_ints_dt <- function(.data, .start, .end, ..., .lower = NULL, .upper = NULL, .gap = 1) {

  # Calculate prior negative intervals
  grp_vars <- eval(substitute(alist(...)), envir = parent.frame())
  .data[, let(neg_start = shift(.end + .gap, type = "lag", fill = -Inf), neg_end = .start - .gap), by = grp_vars,
        env = list(
          grp_vars = substitute(grp_vars),
          .start = substitute(.start),
          .end = substitute(.end)
        )
  ]

  # Calculate the last interval
  last_int <- .data[, .SD[.N], by=grp_vars, env = list( grp_vars = substitute(grp_vars))]
  last_int[, let(neg_start = .end + 1, neg_end = Inf), by = grp_vars,
           env = list(
             grp_vars = substitute(grp_vars),
             .end = substitute(.end)
           )]

  # Combine the results
  r <- rbindlist(list(.data, last_int), use.names = TRUE, fill = TRUE)

  # Select and arrange the final columns
  r[, let(.start = neg_start, .end = neg_end, neg_start = NULL, neg_end = NULL),
    env = list(
      grp_vars = substitute(grp_vars),
      .start = substitute(.start),
      .end = substitute(.end)
    )]

  r <- r[.end >= .start, final_vars, env = list(
    final_vars = eval(substitute(alist(..., .start, .end, .lower, .upper ))),
    .start = substitute(.start),
    .end = substitute(.end)
  )]

  eval(substitute(setorder(r, ..., .start)))

  return(r[])
}

apply_bounds_dt <- function(ints, .start, .end, .lower, .upper) {

  has_lower <- !rlang::quo_is_null(rlang::enquo(.lower))
  has_upper <- !rlang::quo_is_null(rlang::enquo(.upper))

  if(has_lower) {

    ints <- ints[.end >= .lower,
                 env = list(
                   .lower = substitute(.lower),
                   .end = substitute(.end)
                 )]

    ints[, .start := fifelse(.start == -Inf, .lower, .start),
         env = list(
           .start = substitute(.start),
           .lower = substitute(.lower)
         )]
  }

  if(has_upper) {
    ints <- ints[.start <= .upper,
                 env = list(
                   .start = substitute(.start),
                   .upper = substitute(.upper)
                 )]
    ints[, .end := fifelse(.end == Inf, .upper, .end),
         env = list(
           .end = substitute(.end),
           .upper = substitute(.upper)
         )]
  }

  return(ints[.end != Inf & .start != -Inf,
              env = list(
                .start = substitute(.start),
                .end = substitute(.end)
              )][])
}
