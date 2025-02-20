
test_data <- tibble::tibble(
  id = 1:5,
  start = c(1, 2, 5, 10, 12),
  end = c(3, 4, 7, 11, 14)
)

# Test 1: Basic functionality
test_that("Basic functionality with a gap of 1", {
  result <- pac_ints(test_data, start, end, .gap = 1)
  expected <- tibble::tibble(
    int_grp_id = c(1, 2),
    start = c(1, 10),
    end = c(7, 14),
  )
  expect_equal(result, expected)
})

# Test 2: Custom group column name
test_that("Custom group column name", {
  result <- pac_ints(test_data, start, end, .gap = 1, .group_col = group_id)
  expect_true("group_id" %in% colnames(result))
  expect_false("int_grp_id" %in% colnames(result))
})

# Test 3: No overlapping intervals
test_that("overlapping intervals with a gap of 0", {
  result <- pac_ints(test_data, start, end, .gap = 0)
  expected <- tibble::tibble(
    int_grp_id = c(1:4),
    start = c(1, 5, 10, 12),
    end = c(4, 7, 11, 14),
  )
  expect_equal(result, expected)
})

# Test 4: Grouping by additional columns
test_that("Grouping by additional columns", {
  multi_group_data <- tibble::tibble(
    id = 1:6,
    group = c("A", "A", "A", "B", "B", "B"),
    start = c(1, 2, 5, 10, 12, 14),
    end = c(3, 4, 7, 11, 14, 16)
  )
  result <- pac_ints(multi_group_data, start, end, group, .gap = 0)
  expected <- tibble::tibble(
    int_grp_id = c(1, 2, 3, 4),
    group = c("A", "A", "B", "B"),
    start = c(1, 5, 10, 12),
    end = c(4, 7, 11, 16),
  )
  expect_equal(result, expected)
})
