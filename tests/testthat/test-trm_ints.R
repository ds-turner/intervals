# Chopping single intervals -----------------------------------------------
## Simple ----
simple_x <- data.frame(
  start = c(5),
  end = c(10)
)

test_that("chop start", {

  y <- data.frame(
    start = c(3),
    end = c(6)
  )

  exp <- tibble::tibble(
    start = c(6),
    end = c(10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})

test_that("chop end", {

  y <- data.frame(
    start = c(8),
    end = c(11)
  )

  exp <- tibble::tibble(
    start = c(5),
    end = c(8)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})

test_that("chop middle", {

  y <- data.frame(
    start = c(7),
    end = c(8)
  )

  exp <- tibble::tibble(
    start = c(5, 8),
    end = c(7, 10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})

test_that("chop all", {

  y <- data.frame(
    start = c(5),
    end = c(11)
  )

  exp <- tibble::tibble(
    start = numeric(),
    end = numeric()
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})

test_that("missed chop", {

  y <- data.frame(
    start = c(1,11),
    end = c(4,15)
  )

  exp <- tibble::as_tibble(simple_x)

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})


## More complex ----

## chop both ends
test_that("chop both ends", {

  y <- data.frame(
    start = c(1,9),
    end = c(6,15)
  )

  exp <- tibble::tibble(
    start = c(6),
    end = c(9)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})


## chop 2 bits out of the middle - returns 3
test_that("Chop 2 bits out of the middle", {

  y <- data.frame(
    start = c(6,8),
    end = c(7,9)
  )

  exp <- tibble::tibble(
    start = c(5, 7, 9),
    end = c(6, 8, 10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act)
})

# Grouped -----------------------------------------------------------------
test_that("simple grouped", {
  .a <- data.frame(
    id = c("a", "a", "b"),
    start = c(1, 10, 1),
    end = c(5, 15, 20)
  )

  .b <- data.frame(
    id = c("a", "a", "b", "b"),
    start = c(3, 12, 3, 12),
    end = c(7, 14, 7, 14)
  )

  exp <- tibble::tibble(
    id = c("a", "a", "a", "b", "b", "b"),
    start = c(1, 10, 14, 1, 7, 14),
    end = c(3, 12, 15, 3, 12, 20)
  )

  act <- trm_ints(.a, .b, start, end, start, end, id)

  expect_equal(exp, act)
})



test_that("mutiple ids", {

  pats <- 7

  x <- data.frame(
    id = c(1:pats),
    start = rep(5, pats),
    end = rep(20, pats)
  )

  y <- tibble::tribble(
    ~id,  ~start, ~end,
    1,  10, 15, #
    2,  4,  21,
    3,  4,  6,
    4,  19, 21,
    5,  4,  6,
    5,  10, 15,
    5,  19, 21,
    6,  4,  6,
    6,  9,  11,
    6,  14, 16,
    6,  19, 21,
    7,  7,  8,
    7,  9,  10,
    7,  11, 12,
    7,  13, 18,
  )

  exp <- tibble::tribble(
    ~id,  ~start, ~end,
    1,5,10,
    1,15,20,
    3,6,20,
    4,5,19,
    5,6,10,
    5,15,19,
    6,6,9,
    6,11,14,
    6,16,19,
    7,5,7,
    7,8,9,
    7,10,11,
    7,12,13,
    7,18,20,
  )

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp)

})

# more than one grouping var


# Edge cases --------------------------------------------------------------


# really close intervals
# overlapping x
# overlapping y


# Test with dates ---------------------------------------------------------
test_that("Dates", {

  pats <- 7

  x <- data.frame(
    id = c(1:pats),
    start = rep(5, pats),
    end = rep(20, pats)
  ) |>
    dplyr::mutate(across(c(start, end), as.Date))

  y <- tibble::tribble(
    ~id,  ~start, ~end,
    1,  10, 15, #
    2,  4,  21,
    3,  4,  6,
    4,  19, 21,
    5,  4,  6,
    5,  10, 15,
    5,  19, 21,
    6,  4,  6,
    6,  9,  11,
    6,  14, 16,
    6,  19, 21,
    7,  7,  8,
    7,  9,  10,
    7,  11, 12,
    7,  13, 18,
  ) |>
    dplyr::mutate(across(c(start, end), as.Date))

  exp <- tibble::tribble(
    ~id,  ~start, ~end,
    1,5,10,
    1,15,20,
    3,6,20,
    4,5,19,
    5,6,10,
    5,15,19,
    6,6,9,
    6,11,14,
    6,16,19,
    7,5,7,
    7,8,9,
    7,10,11,
    7,12,13,
    7,18,20,
  ) |>
    dplyr::mutate(across(c(start, end), as.Date))

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp)

})


test_that("Date Time", {

  pats <- 7

  x <- data.frame(
    id = c(1:pats),
    start = rep(5, pats),
    end = rep(20, pats)
  ) |>
    dplyr::mutate(across(c(start, end), lubridate::as_datetime))

  y <- tibble::tribble(
    ~id,  ~start, ~end,
    1,  10, 15, #
    2,  4,  21,
    3,  4,  6,
    4,  19, 21,
    5,  4,  6,
    5,  10, 15,
    5,  19, 21,
    6,  4,  6,
    6,  9,  11,
    6,  14, 16,
    6,  19, 21,
    7,  7,  8,
    7,  9,  10,
    7,  11, 12,
    7,  13, 18,
  ) |>
    dplyr::mutate(across(c(start, end), lubridate::as_datetime))

  exp <- tibble::tribble(
    ~id,  ~start, ~end,
    1,5,10,
    1,15,20,
    3,6,20,
    4,5,19,
    5,6,10,
    5,15,19,
    6,6,9,
    6,11,14,
    6,16,19,
    7,5,7,
    7,8,9,
    7,10,11,
    7,12,13,
    7,18,20,
  ) |>
    dplyr::mutate(across(c(start, end), lubridate::as_datetime))

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp)

})


