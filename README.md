
<!-- README.md is generated from README.Rmd. Please edit that file -->

# intervals

<!-- badges: start -->
<!-- badges: end -->

{intervals} helps users tidy up messy intervals. It can group and merge
overlapping intervals as well as remove parts of one set of intervals,
based on another set of intervals.

## Installation

You can install the development version of intervals from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ds-turner/intervals")
```

## Useage

``` r
library(intervals)
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

``` r
grp_ints(ints, st, end, id)
#>        id    st   end int_grp_id
#>    <char> <num> <num>      <int>
#> 1:      A     1     3          1
#> 2:      A     2     4          1
#> 3:      A     5     7          2
#> 4:      B    10    11          3
#> 5:      B    12    14          4
#> 6:      B    14    16          4
```

``` r
pac_ints(ints, st, end, id)
#>        id int_grp_id    st   end
#>    <char>      <int> <num> <num>
#> 1:      A          1     1     4
#> 2:      A          2     5     7
#> 3:      B          3    10    11
#> 4:      B          4    12    16
```
