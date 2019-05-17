
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

## Example

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
