% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rhat.R
\name{rhat.mcmc}
\alias{rhat.mcmc}
\title{R-hat}
\usage{
\method{rhat}{mcmc}(x, by = "all", as_df = FALSE, na_rm = FALSE, ...)
}
\arguments{
\item{x}{An object.}

\item{by}{A string indicating whether to determine by
"term", "parameter" or "all".}

\item{as_df}{A flag indicating whether to return the values as a
data frame versus a named list.}

\item{na_rm}{A flag specifying whether to ignore missing values.}

\item{...}{Other arguments passed to methods.}
}
\value{
A number >= 1 indicating the rhat value.
}
\description{
Calculates an R-hat (potential scale reduction factor) value.
}
\details{
By default the uncorrected, unfolded, univariate,
split R-hat value.
}
\references{
Gelman, A., and Rubin, D.B. 1992.
Inference from Iterative Simulation Using Multiple Sequences.
Statistical Science 7(4): 457–472.
}
\seealso{
Other convergence: 
\code{\link[universals]{converged_pars}()},
\code{\link[universals]{converged_terms}()},
\code{\link[universals]{converged}()},
\code{\link[universals]{esr_pars}()},
\code{\link[universals]{esr_terms}()},
\code{\link[universals]{esr}()},
\code{\link[universals]{rhat_pars}()},
\code{\link[universals]{rhat_terms}()}
}
