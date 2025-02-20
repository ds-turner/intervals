ints <- tibble::tribble(
  ~id,  ~start, ~end, ~index, ~study_end,
  "a",    1,      3,    5,      20, # will be dropped when not packed gap = 1
  "a",    4,      7,   5,      20, # will be kept
  "a",   10,      15,   5,      20,
  "a",   18,      21,   5,      20,
  "a",   23,      25,   5,      20, # dropped

  "b",    7,      9,    5,      20,
  "b",    12,     16,    5,      20,

  "c",    1,      3,    5,      20,
  "c",    7,      9,    5,      20,
  "c",    12,     16,    5,      20,
  "c",   23,      25,   5,      20,

  "d",   10,      15,   5,      20, # wont have any with no bounds
)


test_that("bounds", {

  act <- neg_ints(ints, start, end, id, .lower = index, .upper = study_end)

  exp <- tibble::tribble(
    ~id,    ~start,   ~end, ~index, ~study_end, ~int_type,
 "a",         4,     7,     5,        20, "pos",
 "a",         8,     9,     5,        20, "neg",
 "a",        10,    15,     5,        20, "pos",
 "a",        16,    17,     5,        20, "neg",
 "a",        18,    21,     5,        20, "pos",
 "b",         5,     6,     5,        20, "neg",
 "b",         7,     9,     5,        20, "pos",
 "b",        10,    11,     5,        20, "neg",
 "b",        12,    16,     5,        20, "pos",
 "b",        17,    20,     5,        20, "neg",
 "c",         4,     6,     5,        20, "neg",
 "c",         7,     9,     5,        20, "pos",
 "c",        10,    11,     5,        20, "neg",
 "c",        12,    16,     5,        20, "pos",
 "c",        17,    22,     5,        20, "neg",
 "d",         5,     9,     5,        20, "neg",
 "d",        10,    15,     5,        20, "pos",
 "d",        16,    20,     5,        20, "neg",
  )
  neg_ints(ints, start, end, id, .lower = NULL, .upper = NULL)

  expect_equal(act, exp)
})


test_that("no bounds", {

  act <- neg_ints(ints, start, end, id)

  exp <- tibble::tribble(


    ~id,    ~start,   ~end, ~int_type,

    "a",         1,     3, "pos",
    "a",         4,     7, "pos",
    "a",         4,     3, "neg",
    "a",         8,     9, "neg",
    "a",        10,    15, "pos",
    "a",        16,    17, "neg",
    "a",        18,    21, "pos",
    "a",        22,    22, "neg",
    "a",        23,    25, "pos",
    "b",         7,     9, "pos",
    "b",        10,    11, "neg",
    "b",        12,    16, "pos",
    "c",         1,     3, "pos",
    "c",         4,     6, "neg",
    "c",         7,     9, "pos",
    "c",        10,    11, "neg",
    "c",        12,    16, "pos",
    "c",        17,    22, "neg",
    "c",        23,    25, "pos",
    "d",        10,    15, "pos",
  )
  neg_ints(ints, start, end, id, .lower = NULL, .upper = NULL)

  expect_equal(act, exp)
})
