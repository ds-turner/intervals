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

  neg_ints <- ints |>
    dplyr::mutate(
      neg_start = {{ .end }}  + .gap,
      neg_end = dplyr::lead({{ .start }}, default = Inf) - .gap,
      int_type = "neg",
      .by = c(...)
    )

  if(has_lower) {
    prior_neg_ints <- ints |>
      dplyr::mutate(
        neg_start = dplyr::lag({{ .end }}, default = -Inf) + .gap,
        neg_end = {{ .start }} - .gap,
        int_type = "neg",
        .by = c(...)
      )

    neg_ints <- rbind(neg_ints, prior_neg_ints) |>
      dplyr::select(
        ...,
        neg_start,
        neg_end,
        {{ .lower }},
        {{ .upper }},
        int_type
      ) |>
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
      ) |>
      dplyr::filter(!is.na(end))

  # return(neg_ints)

  all_ints <- rbind(ints, neg_ints) |>
    dplyr::group_by(...)

  if(has_lower) {
    # drop ints that end before the lower bounds
    all_ints <- all_ints |>
      dplyr::filter({{ .end }} >= {{ .lower }}) |>
      dplyr::mutate(
        "{{.start}}" := dplyr::case_when(
          {{ .start }} == -Inf ~ {{ .lower }},
          .default = {{ .start }}
        )
      )
  } else {
    all_ints <- dplyr::filter(all_ints, {{ .start }} != -Inf)
    }

  if(has_upper) {
    # drop ints that start after the upper bounds
    all_ints <- all_ints |>
      dplyr::filter({{ .start }} <= {{ .upper }}) |>
      dplyr::mutate(
        "{{.end}}" := dplyr::case_when(
          {{ .end }} == Inf ~ {{ .upper }},
          .default = {{ .end }}
        )
      )
  }  else {
    all_ints <- dplyr::filter(all_ints, {{ .end }} != Inf)
  }

  all_ints |>
    dplyr::ungroup() |>
    dplyr::arrange(..., {{ .start }}, desc({{ .end }}))

}

