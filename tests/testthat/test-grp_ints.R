# Test data
test_data <- data.frame(
  id = 1:5,
  start = c(1, 2, 5, 10, 12),
  end = c(3, 4, 7, 11, 14)
)

# Test 1: Basic functionality
test_that("Basic functionality with a gap of 1", {
  result <- grp_ints(test_data, start, end, .gap = 1)
  expected <- data.table::data.table(
    id = 1:5,
    start = c(1, 2, 5, 10, 12),
    end = c(3, 4, 7, 11, 14),
    int_grp_id = c(1, 1, 1, 2, 2)
  )
  expect_equal(result, expected)
})

# Test 2: Custom group column name
test_that("Custom group column name", {
  result <- grp_ints(test_data, start, end, .gap = 1, .group_col = group_id)
  expect_true("group_id" %in% colnames(result))
  expect_false("int_grp_id" %in% colnames(result))
})


# Test 4: Empty dataset
test_that("Empty dataset", {
  empty_data <- data.frame(id = integer(), start = integer(), end = integer())
  result <- grp_ints(empty_data, start, end, .gap = 1)
  expect_equal(nrow(result), 0)
})

# Test 6: Grouping by additional columns
test_that("Grouping by additional columns", {
  multi_group_data <- data.frame(
    id = 1:6,
    group = c("A", "A", "A", "B", "B", "B"),
    st = c(1, 2, 5, 10, 12, 14),
    end = c(3, 4, 7, 11, 14, 16)
  )
  result <- grp_ints(multi_group_data, st, end, group, .gap = 0)
  expected <- data.table::data.table(
    id = 1:6,
    group = c("A", "A", "A", "B", "B", "B"),
    st = c(1, 2, 5, 10, 12, 14),
    end = c(3, 4, 7, 11, 14, 16),
    int_grp_id = c(1, 1, 2, 3, 4, 4)
  )
  expect_equal(result, expected)
})

# Test 7: Large gap value
test_that("Large gap value", {
  result <- grp_ints(test_data, start, end, .gap = 10)
  expected <- data.table::data.table(
    id = 1:5,
    start = c(1, 2, 5, 10, 12),
    end = c(3, 4, 7, 11, 14),
    int_grp_id = c(1, 1, 1, 1, 1)
  )
  expect_equal(result, expected)
})

# Test 8: Negative gap value
test_that("Negative gap value", {
  test_data <- data.frame(
    id = 1:5,
    start = c(1, 2, 4, 10, 12),
    end = c(3, 4, 7, 11, 14)
  )
  result <- grp_ints(test_data, start, end, .gap = -1)
  expected <- data.table::data.table(
    id = 1:5,
    start = c(1, 2, 4, 10, 12),
    end = c(3, 4, 7, 11, 14),
    int_grp_id = c(1, 1, 2, 3, 4)
  )
  expect_equal(result, expected)
})

