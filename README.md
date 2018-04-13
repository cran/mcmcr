
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis-CI Build
Status](https://travis-ci.org/poissonconsulting/mcmcr.svg?branch=master)](https://travis-ci.org/poissonconsulting/mcmcr)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/mcmcr?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/mcmcr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/poissonconsulting/mcmcr/master.svg)](https://codecov.io/github/poissonconsulting/mcmcr?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# mcmcr

## Introduction

`mcmcr` is an R package to manipulate Monte Carlo Markov Chain (MCMC)
samples.

For the purposes of this discussion, an MCMC *sample* represents the
value of a *term* from a single *iteration* of a single *chain*. While a
simple *parameter* such as an intercept corresponds to a single term,
more complex parameters such as an interaction between two factors
consists of multiple terms with their own inherent dimensionality - in
this case a matrix. A set of MCMC samples can be stored in different
ways.

### Existing Classes

The three most common S3 classes store MCMC samples as follows:

  - `coda::mcmc` stores the MCMC samples from a single chain as a matrix
    where each each row represents an iteration and each column
    represents a variable
  - `coda::mcmc.list` stores multiple `mcmc` objects (with identical
    dimensions) as a list where each object represents a parallel chain
  - `rjags::mcarray` stores the samples from a single parameter where
    the initial dimensions are the parameter dimensions, the second to
    last dimension is iterations and the last dimension is chains.

In the first two cases the terms/parameters are represented by a single
dimension which means that the dimensionality inherent in the parameters
is stored in the labelling of the variables, ie, `"bIntercept",
"bInteraction[1,2]", "bInteraction[2,1]", ...`. The structure of the
`mcmc` and `mcmc.list` objects emphasizes the time-series nature of MCMC
samples and is optimized for thining. In contrast `mcarray` objects
preserve the dimensionality of the parameters.

### New Classes

The `mcmcr` package defines three related S3 classes which also preserve
the dimensionality of the parameters:

  - `mcmcr::mcmcarray` is very similar to `rjags::mcarray` except that
    the first dimension is the chains, the second dimension is
    iterations and the subsequent dimensions represent the
    dimensionality of the parameter (it is called `mcmcarray` to
    emphasize that the MCMC dimensions ie the chains and iterations come
    first);
  - `mcmcr::mcmcr` stores multiple uniquely named `mcmcarray` objects
    with the same number of chains and iterations.
  - `mcmcr::mcmcrs` stores multiple `mcmcr` objects with the same
    parameters, chains and iterations.

## Why mcmcr?

`mcmcarray` objects were developed to facilitate manipulation of the
MCMC samples (although they are just one `aperm` away from `mcarray`
objects they are more intuitive to program with - at least for this
programmer\!). `mcmcr` objects were developed to allow a set of
dimensionality preserving parameters from a single analysis to be
manipulated as a whole. `mcmcrs` objects were developed to allow the
results of multiple analyses using the same model to be manipulated
together.

In addition the `mcmcr` package defines the `term` vector to store and
manipulate the term labels, ie, `"bIntercept", "bInteraction[1,2]",
"bInteraction[2,1]"`, when the MCMC samples are summarised in tabular
form.

The `mcmcr` package also introduces a variety of (often) generic
functions to manipulate and query `mcmcarray`, `mcmcr` and `mcmcrs`
objects. In particular it provides functions to

  - coerce from and to `mcarray`, `mcmc` and `mcmc.list` objects;
  - extract an objects `coef` table (as a tibble);
  - query an object’s `nchains`, `niters`, `npars`, `nterms`, `nsims`
    and `nsams` as well as it’s parameter dimensions (`pdims`) and term
    dimensions (`tdims`);
  - `subset` objects by chains, iterations and/or parameters;
  - `bind_xx` a pair of objects by their `xx_chains`, `_iterations`,
    `xx_parameters` or (parameter) `xx_dimensions`;
  - combine the samples of two (or more) MCMC objects using
    `combine_samples` (or `combine_samples_n`) or combine the samples of
    a single MCMC object by reducing its dimensions using
    `combine_dimensions`;
  - `collapse_chains` or `split_chains` an object’s chains;
  - `mcmc_map` over an objects values;
  - assess if an object has `converged` using `rhat` and `esr`
    (effectively sampling rate);
  - and of course `thin`, `rhat`, `ess` (effective sample size),
    `print`, `plot` etc said objects.

The code is opinionated which has the advantage of providing a small set
of stream-lined functions. For example the only ‘convergence’ metric is
the uncorrected, untransformed, univariate split R-hat (potential scale
reduction factor). If you can convince me that additional features are
important I will add them or accept a pull request (see below).
Alternatively you might want to use the `mcmcr` package to manipulate
your samples before coercing them to an `mcmc.list` to take advantage of
all the summary functions in packages such as `coda`.

## Demonstration

``` r
library(mcmcr)

mcmcr_example
#> $alpha
#> [1] 3.718025 4.718025
#> 
#> nchains:  2 
#> niters:  400 
#> 
#> $beta
#>           [,1]     [,2]
#> [1,] 0.9716535 1.971654
#> [2,] 1.9716535 2.971654
#> 
#> nchains:  2 
#> niters:  400 
#> 
#> $sigma
#> [1] 0.7911975
#> 
#> nchains:  2 
#> niters:  400

coef(mcmcr_example)
#> # A tibble: 7 x 7
#>   term       estimate    sd zscore lower upper  pvalue
#>   <S3: term>    <dbl> <dbl>  <dbl> <dbl> <dbl>   <dbl>
#> 1 alpha[1]      3.72  0.901   4.15 2.21   5.23 0.00120
#> 2 alpha[2]      4.72  0.901   5.26 3.21   6.23 0.00120
#> 3 beta[1,1]     0.972 0.375   2.57 0.251  1.71 0.0225 
#> 4 beta[2,1]     1.97  0.375   5.24 1.25   2.71 0.00500
#> 5 beta[1,2]     1.97  0.375   5.24 1.25   2.71 0.00500
#> 6 beta[2,2]     2.97  0.375   7.91 2.25   3.71 0.00120
#> 7 sigma         0.791 0.741   1.31 0.425  2.56 0.00120
rhat(mcmcr_example, by = "term")
#> $alpha
#> [1] 2.002 2.002
#> 
#> $beta
#>       [,1]  [,2]
#> [1,] 1.147 1.147
#> [2,] 1.147 1.147
#> 
#> $sigma
#> [1] 0.998
plot(mcmcr_example[["alpha"]])
```

![](tools/README-unnamed-chunk-2-1.png)<!-- -->

## Installation

To install the latest development version from
[GitHub](https://github.com/poissonconsulting/mcmcr)

    # install.packages("devtools")
    devtools::install_github("poissonconsulting/mcmcr")

Alternatively install the latest development version from the Poisson
drat [repository](https://github.com/poissonconsulting/drat) using

    # install.packages("drat")
    drat::addRepo("poissonconsulting")
    install.packages("mcmcr")

## Citation

    Warning in citation(package = "mcmcr"): no date field in DESCRIPTION file
    of package 'mcmcr'
    Warning in citation(package = "mcmcr"): could not determine year for
    'mcmcr' from package DESCRIPTION file
    
    To cite package 'mcmcr' in publications use:
    
      Joe Thorley (NA). mcmcr: Manipulate MCMC Samples. R package
      version 0.0.1.
    
    A BibTeX entry for LaTeX users is
    
      @Manual{,
        title = {mcmcr: Manipulate MCMC Samples},
        author = {Joe Thorley},
        note = {R package version 0.0.1},
      }

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/mcmcr/issues).

[Pull requests](https://github.com/poissonconsulting/mcmcr/pulls) are
always welcome.

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

## Inspiration

[coda](https://github.com/cran/coda) and
[rjags](https://github.com/cran/rjags)