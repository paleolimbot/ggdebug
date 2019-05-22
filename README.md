
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

# use helpers to debug lots of functions
ggdebug(!!!ggmethods(GeomPoint))

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
ggtrace_mdtree(
  !!!ggmethods(FacetWrap),
  combine_vars,
  eval_facets
)

ggplot(mpg, aes(cty, hwy)) + geom_point() + facet_wrap(vars(class))
```

  - [Facet$setup\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L157-L159)
  - [Facet$setup\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L160-L162)
  - [FacetWrap$compute\_layout](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L143-L180)
      - [combine\_vars](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L530-L574)
          - [eval\_facets](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L420-L423)
          - [eval\_facets](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L420-L423)
  - [FacetWrap$map\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L181-L214)
      - [eval\_facets](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L420-L423)
  - [Facet$init\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L91-L100)
  - [Facet$init\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L91-L100)
  - [Facet$train\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L101-L120)
  - [Facet$train\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L101-L120)
  - [Facet$finish\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L163-L165)
  - [Facet$draw\_back](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L121-L123)
  - [Facet$draw\_front](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L124-L126)
  - [FacetWrap$draw\_panels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L215-L386)
  - [Facet$draw\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L130-L156)

<!-- end list -->

``` r
gguntrace_all()
```

## How it all comes together

Or sometimes, you need to debug all of ggplot2.

``` r
ggtrace_mdtree(
  print.ggplot,
  ggplot_build,
  ggplot_gtable,
  !!!ggmethods(GeomPoint),
  !!!ggmethods(StatIdentity),
  !!!ggmethods(Layer),
  !!!ggmethods(Layout),
  !!!ggmethods(CoordCartesian),
  !!!ggmethods(FacetWrap),
  !!!ggmethods(ScaleContinuousPosition),
  !!!ggmethods(ScaleContinuous),
  !!!ggmethods(ScaleDiscrete),
  !!!ggmethods(RangeContinuous),
  !!!ggmethods(RangeDiscrete),
  geom_point,
  ggplot.default,
  aes,
  facet_wrap,
  layer,
  guide_axis,
  guides_build,
  guides_train,
  guides_gengrob
)

ggplot(mpg, aes(cty, hwy, col = class)) +
  geom_point() +
  facet_wrap(vars(drv))
```

  - [layer](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L65-L160)
      - [Geom$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L153-L155)
      - [Geom$parameters](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L138-L151)
      - [Stat$parameters](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L131-L144)
      - [Geom$parameters](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L138-L151)
      - [Stat$parameters](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L131-L144)
      - [Geom$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L153-L155)
      - [Geom$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L153-L155)
      - [Stat$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L146-L148)
  - [ggplot\_build](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/plot-build.r#L23-L25)
      - [Layer$layer\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L201-L213)
      - [Layer$setup\_layer](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L217-L219)
      - [Layout$setup](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L33-L55)
          - [Facet$setup\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L157-L159)
          - [Facet$setup\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L160-L162)
          - [Coord$setup\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L128-L130)
          - [Coord$setup\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L132-L134)
          - [FacetWrap$compute\_layout](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L143-L180)
          - [Coord$setup\_layout](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L136-L138)
          - [FacetWrap$map\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L181-L214)
      - [Layer$compute\_aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L221-L276)
      - [Scale$transform\_df](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L68-L75)
          - [ScaleContinuous$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L210-L218)
      - [Scale$transform\_df](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L68-L75)
          - [ScaleContinuous$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L210-L218)
      - [Scale$transform\_df](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L68-L75)
          - [ScaleDiscrete$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L374-L376)
      - [Layout$train\_position](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L126-L145)
          - [Facet$init\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L91-L100)
              - [ScaleContinuous$clone](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L314-L318)
          - [Facet$init\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L91-L100)
              - [ScaleContinuous$clone](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L314-L318)
          - [Facet$train\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L101-L120)
              - [ScaleContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L205-L208)
                  - [RangeContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L22-L24)
              - [ScaleContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L205-L208)
                  - [RangeContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L22-L24)
      - [Layout$map\_position](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L147-L169)
          - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
          - [ScaleContinuousPosition$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L122-L125)
          - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
          - [ScaleContinuousPosition$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L122-L125)
      - [Layer$compute\_statistic](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L278-L285)
          - [Stat$setup\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L64-L66)
          - [Stat$setup\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L68-L70)
          - [StatIdentity$compute\_layer](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-identity.r#L36-L38)
      - [Layer$map\_statistic](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L287-L329)
          - [Layer$compute\_geom\_1](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L331-L341)
              - [Geom$setup\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L107-L107)
          - [Layer$compute\_position](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L343-L350)
          - [Layout$reset\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L171-L176)
              - [Scale$reset](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L59-L61)
                  - [Range$reset](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L10-L12)
              - [Scale$reset](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L59-L61)
                  - [Range$reset](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L10-L12)
          - [Layout$train\_position](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L126-L145)
              - [Facet$train\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L101-L120)
                  - [ScaleContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L205-L208)
                      - [RangeContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L22-L24)
                  - [ScaleContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L205-L208)
                      - [RangeContinuous$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L22-L24)
          - [Layout$setup\_panel\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L196-L210)
              - [Coord$modify\_scales](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L142-L144)
              - [CoordCartesian$setup\_panel\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L102-L116)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
              - [CoordCartesian$setup\_panel\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L102-L116)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
              - [CoordCartesian$setup\_panel\_params](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L102-L116)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
                  - [ScaleContinuous$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L203-L203)
                  - [ScaleContinuous$dimension](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L230-L232)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleContinuousPosition$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L126-L133)
                      - [ScaleContinuous$break\_info](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L320-L345)
                          - [ScaleContinuous$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L234-L263)
                              - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                          - [ScaleContinuous$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L292-L312)
                          - [ScaleContinuous$get\_breaks\_minor](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L265-L290)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
          - [Layout$map\_position](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L147-L169)
              - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleContinuousPosition$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L122-L125)
              - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleContinuousPosition$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L122-L125)
          - [Scale$train\_df](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L43-L51)
              - [ScaleDiscrete$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L369-L372)
                  - [RangeDiscrete$train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/range.r#L16-L18)
          - [Scale$map\_df](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L82-L94)
              - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleDiscrete$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L378-L401)
          - [Layer$compute\_geom\_2](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L352-L357)
              - [Geom$use\_defaults](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L110-L129)
                  - [Geom$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L153-L155)
          - [Layer$finish\_statistics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L359-L361)
              - [Stat$finish\_layer](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/stat-.r#L124-L126)
          - [Layout$finish\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L178-L185)
              - [Facet$finish\_data](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L163-L165)
      - [ggplot\_gtable](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/plot-build.r#L157-L159)
          - [Layer$draw\_geom](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layer.r#L363-L371)
              - [Geom$handle\_na](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L67-L72)
              - [Geom$draw\_layer](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L74-L90)
                  - [Geom$parameters](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L138-L151)
                  - [GeomPoint$draw\_panel](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-point.r#L116-L135)
                      - [CoordCartesian$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L94-L100)
                  - [GeomPoint$draw\_panel](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-point.r#L116-L135)
                      - [CoordCartesian$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L94-L100)
                  - [GeomPoint$draw\_panel](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-point.r#L116-L135)
                      - [CoordCartesian$transform](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-cartesian-.r#L94-L100)
          - [Layout$render](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L59-L124)
              - [Facet$draw\_back](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L121-L123)
              - [Facet$draw\_front](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L124-L126)
              - [Coord$render\_fg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L64-L64)
              - [Coord$render\_bg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L66-L72)
              - [Coord$render\_fg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L64-L64)
              - [Coord$render\_bg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L66-L72)
              - [Coord$render\_fg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L64-L64)
              - [Coord$render\_bg](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L66-L72)
              - [FacetWrap$draw\_panels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-wrap.r#L215-L386)
                  - [Coord$render\_axis\_h](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L74-L81)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$render\_axis\_h](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L74-L81)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$render\_axis\_h](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L74-L81)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$render\_axis\_v](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L83-L90)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$render\_axis\_v](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L83-L90)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$render\_axis\_v](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L83-L90)
                      - [guide\_axis](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-axis.r#L7-L148)
                  - [Coord$aspect](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L60-L60)
              - [Layout$xlabel](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L212-L223)
                  - [Scale$make\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L170-L172)
                  - [ScaleContinuousPosition$sec\_name](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L134-L140)
                  - [ScaleContinuousPosition$make\_sec\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L141-L147)
                      - [Scale$make\_sec\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L173-L175)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
              - [Layout$ylabel](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L225-L236)
                  - [Scale$make\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L170-L172)
                  - [ScaleContinuousPosition$sec\_name](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L134-L140)
                  - [ScaleContinuousPosition$make\_sec\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-continuous.r#L141-L147)
                      - [Scale$make\_sec\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L173-L175)
                  - [Scale$axis\_order](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L161-L167)
              - [Coord$labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/coord-.r#L62-L62)
              - [Layout$render\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/layout.R#L238-L260)
              - [Facet$draw\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/facet-.r#L130-L156)
          - [guides\_train](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-.r#L163-L201)
              - [Scale$make\_title](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L170-L172)
              - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleDiscrete$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L407-L425)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                      - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleDiscrete$map](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L378-L401)
              - [ScaleDiscrete$get\_labels](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L429-L467)
                  - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                      - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                  - [ScaleDiscrete$get\_breaks](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L407-L425)
                      - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
                      - [Scale$get\_limits](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L113-L124)
                          - [Scale$is\_empty](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L63-L65)
              - [ScaleDiscrete$is\_discrete](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/scale-.r#L367-L367)
          - [Geom$use\_defaults](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L110-L129)
              - [Geom$aesthetics](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/geom-.r#L153-L155)
          - [guides\_gengrob](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-.r#L224-L235)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
              - [GeomPoint$draw\_key](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/legend-draw.r#L26-L42)
          - [guides\_build](https://github.com/tidyverse/ggplot2/blob/1f6f0cb/R/guides-.r#L238-L298)

<!-- end list -->

``` r

gguntrace_all()
```
