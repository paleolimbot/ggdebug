
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggdebug

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of ggdebug is to make it easier to debug functions and ggproto
methods in ggplot2.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("paleolimbot/ggdebug")
```

If you can load the package, you’re all set\!

``` r
library(ggdebug)
```

## Debugging

Use `ggdebug()` to debug functions (they can be exported, non-exported,
or `ggproto` methods), use `ggundebug()` to stop debugging specific
functions, and use `ggundebug_all()` to stop debugging altogether.

``` r
# debug ggplot() and GeomPoint$draw_panel()
ggdebug(ggplot, GeomPoint$draw_panel)

# stop debugging functions
ggundebug(ggplot)

# stop debugging all functions
ggundebug_all()
```

You can also use this package to install specific versions of ggplot2
from GitHub that link back to the source:

``` r
# gginstall("cran/ggplot2")
# gginstall("tidyverse/ggplot2@v3.1.1")
(ggbrowse(FacetWrap$map_data))
#> [1] "https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L181-L214"
```

## Tracing

Use `ggtrace()` (and family) to evaluate abitrary code as functions
enter an exit. `ggtrace_tree()` and `ggtrace_stack()` are useful
shortcut
methods.

``` r
ggtrace(FacetWrap$map_data, on_enter = quo(print(data)), on_exit = quo(print(data)))
ggplot(mpg, aes(cty, hwy)) + geom_point() + facet_wrap(vars(class))
#> # A tibble: 234 x 11
#>    manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
#>    <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#>  1 audi         a4      1.8  1999     4 auto… f        18    29 p     comp…
#>  2 audi         a4      1.8  1999     4 manu… f        21    29 p     comp…
#>  3 audi         a4      2    2008     4 manu… f        20    31 p     comp…
#>  4 audi         a4      2    2008     4 auto… f        21    30 p     comp…
#>  5 audi         a4      2.8  1999     6 auto… f        16    26 p     comp…
#>  6 audi         a4      2.8  1999     6 manu… f        18    26 p     comp…
#>  7 audi         a4      3.1  2008     6 auto… f        18    27 p     comp…
#>  8 audi         a4 q…   1.8  1999     4 manu… 4        18    26 p     comp…
#>  9 audi         a4 q…   1.8  1999     4 auto… 4        16    25 p     comp…
#> 10 audi         a4 q…   2    2008     4 manu… 4        20    28 p     comp…
#> # … with 224 more rows
#> # A tibble: 234 x 12
#>    manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
#>    <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#>  1 audi         a4      1.8  1999     4 auto… f        18    29 p     comp…
#>  2 audi         a4      1.8  1999     4 manu… f        21    29 p     comp…
#>  3 audi         a4      2    2008     4 manu… f        20    31 p     comp…
#>  4 audi         a4      2    2008     4 auto… f        21    30 p     comp…
#>  5 audi         a4      2.8  1999     6 auto… f        16    26 p     comp…
#>  6 audi         a4      2.8  1999     6 manu… f        18    26 p     comp…
#>  7 audi         a4      3.1  2008     6 auto… f        18    27 p     comp…
#>  8 audi         a4 q…   1.8  1999     4 manu… 4        18    26 p     comp…
#>  9 audi         a4 q…   1.8  1999     4 auto… 4        16    25 p     comp…
#> 10 audi         a4 q…   2    2008     4 manu… 4        20    28 p     comp…
#> # … with 224 more rows, and 1 more variable: PANEL <fct>
gguntrace(FacetWrap$map_data)
```

``` r
ggtrace_tree(
  FacetWrap$map_data, 
  FacetWrap$compute_layout,
  combine_vars,
  eval_facets
)

ggplot(mpg, aes(cty, hwy)) + geom_point() + facet_wrap(vars(class))
#> -- FacetWrap$compute_layout()
#> ---- combine_vars()
#> ------ eval_facets()
#> ------ eval_facets()
#> -- FacetWrap$map_data()
#> ---- eval_facets()
gguntrace_all()
```

## Helpers

More than likely, you’d like to debug an entire ggproto class. For this
you can use `ggmethods()` and the splice to debug many functions at
once.

``` r
ggtrace_tree(!!!ggmethods(FacetWrap))
ggplot(mpg, aes(cty, hwy)) + geom_point() + facet_wrap(vars(class))
#> -- Facet$setup_params()
#> -- Facet$setup_data()
#> -- FacetWrap$compute_layout()
#> -- FacetWrap$map_data()
#> -- Facet$init_scales()
#> -- Facet$init_scales()
#> -- Facet$train_scales()
#> -- Facet$train_scales()
#> -- Facet$finish_data()
#> -- Facet$draw_back()
#> -- Facet$draw_front()
#> -- FacetWrap$draw_panels()
#> -- Facet$draw_labels()
gguntrace_all()
```
