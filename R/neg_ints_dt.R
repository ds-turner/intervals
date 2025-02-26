neg_ints_dt <- function(.data, .start, .end, ..., .lower = NULL, .upper = NULL, .gap = 1, pac_ints = FALSE) {

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

