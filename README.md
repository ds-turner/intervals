
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ints

<!-- badges: start -->
<!-- badges: end -->

[`{ints}`](ds-turner.github.io/ints/) helps users tidy up messy
intervals. It can group and merge overlapping intervals as well as
remove parts of one set of intervals, based on another set of intervals.
In this context an interval is defined as having a start and a stop. It
can be numeric or date type.

`{ints}` uses [`{data.table}`](https://rdatatable.gitlab.io/data.table/)
for memory efficiency and speed, it will always return a `data.table`
object.

## Installation

You can install the development version of `{ints}` from
[GitHub](https://github.com/) with:

``` r
pak::pak("ds-turner/ints")
```

## Useage

``` r
library(ints)
```

### Grouping and Merging Intervals

``` r
 ints <- data.frame(
    id = c("A", "A", "A", "B", "B", "B"),
    st = c(1, 2, 5, 10, 12, 14),
    end = c(3, 4, 7, 11, 14, 16)
  )
 ints
#>   id st end
#> 1  A  1   3
#> 2  A  2   4
#> 3  A  5   7
#> 4  B 10  11
#> 5  B 12  14
#> 6  B 14  16
```

`ints` is a set of overlapping intervals. We can identify the
overlapping intervals and add an ID column `int_grp_id` for overlapping
groups.

``` r
grp_ints(ints, st, end, id)
#>        id    st   end int_grp_id
#>    <char> <num> <num>      <int>
#> 1:      A     1     3          1
#> 2:      A     2     4          1
#> 3:      A     5     7          1
#> 4:      B    10    11          2
#> 5:      B    12    14          2
#> 6:      B    14    16          2
```

We can also merge the overlapping intervals into single intervals

``` r
merge_ints(ints, st, end, id)
#>        id int_grp_id    st   end
#>    <char>      <int> <num> <num>
#> 1:      A          1     1     4
#> 2:      A          2     5     7
#> 3:      B          3    10    11
#> 4:      B          4    12    16
```

### Triming Intervals

Below is an example of some treatment data. Each patient has a period
monthly treatment for the duration of 2023. For our analysis we will
consider the different dose frequencies as mutually exclusive and
hierarchical, i.e. a patient will not be considered as being dosed
weekly if there is a record of daily dosing and a patient will not be
considered as being dosed monthly if there is a record of weekly dosing.

``` r
trt <- data.frame(
  pat_id = c(1, 1, 1,
             2, 2, 2
             ),
  trt_start_date = as.Date(c(
    "2023-07-13", "2023-06-05", "2023-01-01",
    "2023-03-02", "2023-03-05", "2023-01-01"
  )),
  trt_end_date = as.Date(c(
    "2023-07-20", "2023-08-15", "2023-12-31",
    "2023-03-10", "2023-03-15", "2023-12-31"
  )),
  dose_freq = c(
    "daily", "weekly",  "monthly",
    "daily", "weekly", "monthly"
  )
)

trt
#>   pat_id trt_start_date trt_end_date dose_freq
#> 1      1     2023-07-13   2023-07-20     daily
#> 2      1     2023-06-05   2023-08-15    weekly
#> 3      1     2023-01-01   2023-12-31   monthly
#> 4      2     2023-03-02   2023-03-10     daily
#> 5      2     2023-03-05   2023-03-15    weekly
#> 6      2     2023-01-01   2023-12-31   monthly
```

Here we split up the intervals to make sure everything is mutually
exclusive.

``` r
# create a list contaiing each dose level
trt_list <- split(trt, trt$dose_freq)

# remove the parts of the week dosing periods that overlap with the daily dosing intervals
trt_list$weekly <- trm_ints(
  trt_list$weekly,
  trt_list$daily,
  trt_start_date,
  trt_end_date,
  trt_start_date,
  trt_end_date,
  pat_id,
  .gap = 1
  )
# remove the parts of the monthly dosing periods that overlap with the daily and weekly dosing intervals
trt_list$monthly <- trm_ints(
  trt_list$monthly,
  rbind(trt_list$daily, trt_list$weekly),
  trt_start_date,
  trt_end_date,
  trt_start_date,
  trt_end_date,
  pat_id,
  .gap = 1
  )

trt2 <- data.table::rbindlist(
  trt_list
)
data.table::setorder(trt2, pat_id, trt_start_date)

trt2
#>    pat_id trt_start_date trt_end_date dose_freq
#>     <num>         <Date>       <Date>    <char>
#> 1:      1     2023-01-02   2023-06-05   monthly
#> 2:      1     2023-06-06   2023-07-12    weekly
#> 3:      1     2023-07-13   2023-07-20     daily
#> 4:      1     2023-07-21   2023-08-14    weekly
#> 5:      1     2023-08-15   2023-12-30   monthly
#> 6:      2     2023-01-02   2023-03-01   monthly
#> 7:      2     2023-03-02   2023-03-10     daily
#> 8:      2     2023-03-11   2023-03-14    weekly
#> 9:      2     2023-03-15   2023-12-30   monthly
```

You can remove parts of intervals based on another set of intervals

``` r
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
```

Here we will remove the parts of the intervals in x that overlap with
the intervals in y.

``` r
trm_ints(x, y, start, end, start, end, id)
#>        id start   end
#>     <int> <num> <num>
#>  1:     1     5    10
#>  2:     1    15    20
#>  3:     3     6    20
#>  4:     4     5    19
#>  5:     5     6    10
#>  6:     5    15    19
#>  7:     6     6     9
#>  8:     6    11    14
#>  9:     6    16    19
#> 10:     7     5     7
#> 11:     7     8     9
#> 12:     7    10    11
#> 13:     7    12    13
#> 14:     7    18    20
```

### Negative Intervals

``` r
ints <- data.frame(
  id = c("a", "a", "a", "a", "a", "b", "b", "c",   "c", "c", "c", "d"),
  start = c(1, 4, 10, 18, 23, 7, 12, 1, 7, 12, 23, 10),
  end = c(3, 7, 15, 21, 25, 9, 16, 3, 9, 16, 25, 15),
  index = c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
  study_end = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
)
ints
#>    id start end index study_end
#> 1   a     1   3     5        20
#> 2   a     4   7     5        20
#> 3   a    10  15     5        20
#> 4   a    18  21     5        20
#> 5   a    23  25     5        20
#> 6   b     7   9     5        20
#> 7   b    12  16     5        20
#> 8   c     1   3     5        20
#> 9   c     7   9     5        20
#> 10  c    12  16     5        20
#> 11  c    23  25     5        20
#> 12  d    10  15     5        20
```

We can also create a set of intervals that represent the gaps between
the given intervals

``` r
neg_ints(ints, start, end, id)
#>        id start   end
#>    <char> <num> <num>
#> 1:      a     8     9
#> 2:      a    16    17
#> 3:      a    22    22
#> 4:      b    10    11
#> 5:      c     4     6
#> 6:      c    10    11
#> 7:      c    17    22
```

These intervals can have an upper and lower bounds if required

``` r
neg_ints(ints, start, end, id, .lower = index, .upper = study_end)
#>         id start   end index study_end
#>     <char> <num> <num> <num>     <num>
#>  1:      a     8     9     5        20
#>  2:      a    16    17     5        20
#>  3:      b     5     6     5        20
#>  4:      b    10    11     5        20
#>  5:      b    17    20     5        20
#>  6:      c     4     6     5        20
#>  7:      c    10    11     5        20
#>  8:      c    17    22     5        20
#>  9:      d     5     9     5        20
#> 10:      d    16    20     5        20
```

#### Keywords

interval packing; interval merging; interval cutting;
