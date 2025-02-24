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

  exp <- data.frame(
    start = c(6),
    end = c(10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})

test_that("chop end", {

  y <- data.frame(
    start = c(8),
    end = c(11)
  )

  exp <- data.frame(
    start = c(5),
    end = c(8)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})

test_that("chop middle", {

  y <- data.frame(
    start = c(7),
    end = c(8)
  )

  exp <- data.frame(
    start = c(5, 8),
    end = c(7, 10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})

test_that("chop all", {

  y <- data.frame(
    start = c(5),
    end = c(11)
  )

  exp <- data.frame(
    start = numeric(),
    end = numeric()
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})

test_that("missed chop", {

  y <- data.frame(
    start = c(1,11),
    end = c(4,15)
  )

  exp <- data.frame(simple_x)

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})


## More complex ----

## chop both ends
test_that("chop both ends", {

  y <- data.frame(
    start = c(1,9),
    end = c(6,15)
  )

  exp <- data.frame(
    start = c(6),
    end = c(9)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
})


## chop 2 bits out of the middle - returns 3
test_that("Chop 2 bits out of the middle", {

  y <- data.frame(
    start = c(6,8),
    end = c(7,9)
  )

  exp <- data.frame(
    start = c(5, 7, 9),
    end = c(6, 8, 10)
  )

  act <- trm_ints(simple_x, y, start, end, start, end)

  expect_equal(exp, act, ignore_attr = T)
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

  exp <- data.frame(
    id = c("a", "a", "a", "b", "b", "b"),
    start = c(1, 10, 14, 1, 7, 14),
    end = c(3, 12, 15, 3, 12, 20)
  )

  act <- trm_ints(.a, .b, start, end, start, end, id)

  expect_equal(exp, act, ignore_attr = T)
})



test_that("mutiple ids", {

  pats <- 7

  x <- data.frame(
    id = c(1:pats),
    start = rep(5, pats),
    end = rep(20, pats)
  )

  y <- data.frame(
    id = c(1, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7),
    start = c(10, 4, 4, 19, 4, 10, 19, 4, 9, 14, 19, 7, 9, 11, 13),
    end = c(15, 21, 6, 21, 6, 15, 21, 6, 11, 16, 21, 8, 10, 12, 18)
    )

  exp <- data.frame(
    id = c(1, 1, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 7, 7),
    start = c(5, 15, 6, 5, 6, 15, 6, 11, 16, 5, 8, 10, 12, 18),
    end = c(10, 20, 20, 19, 10, 19, 9, 14, 19, 7, 9, 11, 13, 20)
    )

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp, ignore_attr = T)

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

  y <- data.frame(
    id = c(1, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7),
    start = c(10, 4, 4, 19, 4, 10, 19, 4, 9, 14, 19, 7, 9,  11, 13),
    end = c(15, 21, 6, 21, 6, 15, 21, 6, 11, 16, 21, 8, 10, 12, 18)
  ) |>
    dplyr::mutate(across(c(start, end), as.Date))

  exp <- data.frame(
    id = c(1, 1, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 7, 7),
    start = c(5, 15, 6, 5, 6, 15, 6, 11, 16, 5, 8, 10, 12, 18),
    end = c(10, 20, 20, 19, 10, 19, 9, 14, 19, 7, 9, 11, 13, 20)
    ) |>
    dplyr::mutate(across(c(start, end), as.Date))

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp, ignore_attr = T)

})


test_that("Date Time", {

  pats <- 7

  x <- data.frame(
    id = c(1:pats),
    start = rep(5, pats),
    end = rep(20, pats)
  ) |>
    dplyr::mutate(across(c(start, end), as.POSIXct))

  y <- data.frame(
    id = c(1, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7),
    start = c(10, 4, 4, 19, 4, 10, 19, 4, 9, 14, 19, 7, 9,  11, 13),
    end = c(15, 21, 6, 21, 6, 15, 21, 6, 11, 16, 21, 8, 10, 12, 18)
  ) |>
    dplyr::mutate(across(c(start, end), as.POSIXct))

  exp <- data.frame(
    id = c(1, 1, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 7, 7),
    start = c(5, 15, 6, 5, 6, 15, 6, 11, 16, 5, 8, 10, 12, 18),
    end = c(10, 20, 20, 19, 10, 19, 9, 14, 19, 7, 9, 11, 13, 20)
  ) |>
    dplyr::mutate(across(c(start, end), as.POSIXct))

  act <- trm_ints(x, y, start, end, start, end, id)

  expect_equal(act, exp, ignore_attr = T)

})


