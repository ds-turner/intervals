
# Single Intervals --------------------------------------------------------

test_that("Single interval, within bounds ()", {

  dat <- data.frame(
    start = c(3),
    end = c(4),
    lower = c(1),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = numeric(),
    end = numeric()
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(1,5),
    end = c(2,6),
    lower = c(1),
    upper = c(6)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("Single interval, overlap 1 bound", {

  dat <- data.frame(
    start = c(1),
    end = c(4),
    lower = c(1),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = numeric(),
    end = numeric()
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(5),
    end = c(6),
    lower = c(1),
    upper = c(6)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("Single interval, overlap both bounds", {

  dat <- data.frame(
    start = c(1),
    end = c(6),
    lower = c(1),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = numeric(),
    end = numeric()
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = numeric(),
    end = numeric(),
    lower = numeric(),
    upper = numeric()
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})


# Mutiple Ints ------------------------------------------------------------
test_that("2 intervals, within bounds ()", {

  dat <- data.frame(
    start = c(3, 7),
    end = c(4, 8),
    lower = c(1),
    upper = c(10)
  )

  ex_ub <- data.frame(
    start = c(5),
    end = c(6)
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(1,5, 9),
    end = c(2,6, 10),
    lower = c(1),
    upper = c(10)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})


# Intervals outside of bounds ---------------------------------------------
test_that("Single interval, before the bounds", {

  dat <- data.frame(
    start = c(1),
    end = c(2),
    lower = c(4),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = numeric(),
    end = numeric()
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(3),
    end = c(6),
    lower = c(4),
    upper = c(6)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("Single interval, after the bounds", {

  dat <- data.frame(
    start = c(8),
    end = c(9),
    lower = c(4),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = numeric(),
    end = numeric()
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(4),
    end = c(7),
    lower = c(4),
    upper = c(6)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("2 intervals, either side of the bounds", {

  dat <- data.frame(
    start = c(1, 8),
    end = c(2, 9),
    lower = c(4),
    upper = c(6)
  )

  ex_ub <- data.frame(
    start = c(3),
    end = c(7)
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(3),
    end = c(7),
    lower = c(4),
    upper = c(6)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("single before after the bounds, single interval within the bounds", {

  dat <- data.frame(
    start = c(1, 8),
    end = c(2, 9),
    lower = c(4),
    upper = c(12)
  )

  ex_ub <- data.frame(
    start = c(3),
    end = c(7)
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(3, 10),
    end = c(7, 12),
    lower = c(4),
    upper = c(12)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})

test_that("single interval within the bounds, single after after the bounds", {

  dat <- data.frame(
    start = c(3, 9),
    end = c(4, 10),
    lower = c(1),
    upper = c(7)
  )

  ex_ub <- data.frame(
    start = c(5),
    end = c(8)
  )
  act_ub <- neg_ints(dat, start, end)
  expect_equal(act_ub, ex_ub, ignore_attr = TRUE)

  ex_b <- data.frame(
    start = c(1, 5),
    end = c(2, 8),
    lower = c(1),
    upper = c(7)
  )
  act_b <- neg_ints(dat, start, end, .lower = lower, .upper = upper)
  expect_equal(act_b, ex_b, ignore_attr = TRUE)
})


ints <- data.frame(
  id = c("a", "a", "a", "a", "a", "b", "b", "c", "c", "c", "c", "d"),
  start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
  end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15),
  index = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
  study_end = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
)


# Grouped -----------------------------------------------------------------



test_that("bounds", {

  ints <- data.frame(
    id = c("a", "a", "a", "a", "a", "b", "b", "c", "c", "c", "c", "d"),
    start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
    end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15),
    lower = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
    upper = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
  )

  act <- neg_ints(ints, start, end, id, .lower = lower, .upper = upper)

  exp <- data.frame(
    id = c("a", "a", "b", "b", "b", "c", "c", "c",  "d", "d"),
    start = c(8, 16, 5, 10, 17, 4, 10, 17, 5, 16),
    end = c(9, 17, 6, 11, 20, 6, 11, 22, 9, 20),
    lower = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
    upper = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
    )

  expect_equal(act, exp, ignore_attr = TRUE)
})


test_that("no bounds", {

  ints <- data.frame(
    id = c("a", "a", "a", "a", "a", "b", "b", "c", "c", "c", "c", "d"),
    start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
    end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15)
  )

  act <- neg_ints(ints, start, end, id)

  exp <- data.frame(
    id = c("a", "a", "a", "b", "c", "c", "c"),
    start = c( 8, 16, 22, 10,4,10,17),
    end = c( 9, 17, 22, 11, 6,11,22)
    )

  expect_equal(act, exp, ignore_attr = TRUE)
})


# Edge cases --------------------------------------------------------------
# single unit intervals
# overlapping intervals
# test_that("overlapping intervals", {
#
# })


# Gap testing -------------------------------------------------------------


# dates -------------------------------------------------------------------

test_that("dates", {

  ints <- data.frame(
    id = c("a", "a", "a", "a", "a", "b", "b", "c", "c", "c", "c", "d"),
    start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
    end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15),
    lower = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
    upper = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
  )

  ints$start <- as.Date(ints$start)
  ints$end <- as.Date(ints$end)
  ints$lower <- as.Date(ints$lower)
  ints$upper <- as.Date(ints$upper)

  act <- neg_ints(ints, start, end, id, .lower = lower, .upper = upper)

  exp <- data.frame(
    id = c("a", "a", "b", "b", "b", "c", "c", "c",  "d", "d"),
    start = c(8, 16, 5, 10, 17, 4, 10, 17, 5, 16),
    end = c(9, 17, 6, 11, 20, 6, 11, 22, 9, 20),
    lower = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
    upper = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
  )

  exp$start <- as.Date(exp$start)
  exp$end <- as.Date(exp$end)
  exp$lower <- as.Date(exp$lower)
  exp$upper <- as.Date(exp$upper)

  expect_equal(act, exp, ignore_attr = TRUE)
})
