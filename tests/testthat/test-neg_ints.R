ints <- data.frame(
  id = c("a", "a", "a", "a", "a", "b", "b", "c",   "c", "c", "c", "d"),
  start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
  end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15),
  index = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
  study_end = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
)



test_that("bounds", {

  act <- neg_ints(ints, start, end, id, .lower = index, .upper = study_end)

  exp <- data.frame(
    id = c(
      "a",
      "a",
      "a",
      "a",
      "a",
      "b",
      "b",
      "b",
      "b",
      "b",
      "c",
      "c",
      "c",
      "c",
      "c",
      "d",
      "d",
      "d"
    ),
    start = c(4, 8, 10, 16, 18, 5, 7, 10, 12, 17, 4, 7, 10, 12, 17, 5, 10, 16),
    end = c(7, 9, 15, 17, 21, 6, 9, 11, 16, 20, 6, 9, 11, 16, 22, 9, 15, 20),
    index = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
    study_end = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20),
    int_type = c(
      "pos",
      "neg",
      "pos",
      "neg",
      "pos",
      "neg",
      "pos",
      "neg",
      "pos",
      "neg",
      "neg",
      "pos",
      "neg",
      "pos",
      "neg",
      "neg",
      "pos",
      "neg"
    )
  )

  expect_equal(act, exp, ignore_attr = TRUE)
})


test_that("no bounds", {

  act <- neg_ints(ints, start, end, id)

  exp <- data.frame(
    id = c("a", "a", "a", "a", "a", "a", "a", "a", "a", "b", "b", "b", "c", "c", "c", "c", "c", "c", "c", "d"),
    start = c(1, 4, 4, 8, 10, 16, 18, 22, 23, 7, 10, 12, 1, 4, 7, 10, 12, 17, 23, 10),
    end = c(3, 7, 3, 9, 15, 17, 21, 22, 25, 9, 11, 16, 3, 6, 9, 11, 16, 22, 25, 15),
    int_type = c("pos", "pos", "neg", "neg", "pos", "neg", "pos", "neg", "pos", "pos", "neg", "pos", "pos", "neg", "pos", "neg", "pos", "neg", "pos", "pos"))


  expect_equal(act, exp, ignore_attr = TRUE)
})
