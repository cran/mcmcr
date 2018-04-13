#' R-hat
#'
#' Calculates the uncorrected, untransformed, univariate
#' split R-hat (potential scale reduction factor) values.
#'
#' @param x An MCMC object.
#' @param ... Unused.
#' @param by A string indicating whether to determine by
#' "term", "parameter" or "all".
#' @param as_df A flag indicating whether to return the values as a
#' tibble versus a named list.
#' @return The rhat value(s).
#' @references
#' Gelman, A., and Rubin, D.B. 1992. Inference from Iterative Simulation Using Multiple Sequences. Statistical Science 7(4): 457–472.
#' @export
#' @examples
#' rhat(mcmcr_example)
#' rhat(mcmcr_example, by = "parameter")
#' rhat(mcmcr_example, by = "term")
#' rhat(mcmcr_example, by = "term", as_df = TRUE)
rhat <- function(x, ...) {
  UseMethod("rhat")
}

#' @describeIn rhat R-hat for an mcarray object
#' @export
rhat.mcarray <- function(x, by = "all", as_df = FALSE, ...)
  rhat(as.mcmcarray(x), by = by, as_df = as_df)

#' @describeIn rhat R-hat for an mcmc object
#' @export
rhat.mcmc <- function(x, by = "all", as_df = FALSE, ...)
  rhat(as.mcmcr(x), by = by, as_df = as_df)

#' @describeIn rhat R-hat for an mcmc.list object
#' @export
rhat.mcmc.list <- function(x, by = "all", as_df = FALSE, ...)
  rhat(as.mcmcr(x), by = by, as_df = as_df)

#' @describeIn rhat R-hat for an mcmcarray object
#' @export
rhat.mcmcarray <- function(x, by = "all", as_df = FALSE, ...) {
  check_vector(by, c("all", "parameter", "term"), length = 1)
  check_flag(as_df)

  if(niters(x) < 4) {
    if(!as_df) {
      if(by == "term") return(utils::relist(NA_real_, estimates(x)))
      return(NA_real_)
    }
    if(by == "term")
      return(tibble::tibble(term = terms(x), rhat = NA_real_))
    return(tibble::tibble(parameter = "parameter", rhat = NA_real_))
  }

  x <- split_chains(x)
  x <- apply(x, 3:ndims(x), FUN = .rhat)

  if(!as_df) {
    if(by == "term") return(x)
    return(max(x))
  }
  if(by != "term")
    return(tibble::tibble(parameter = "parameter", rhat = max(x)))
  x <- estimates(as.mcmcarray(x), as_df = TRUE)
  colnames(x) <- c("term", "rhat")
  x
}

#' @describeIn rhat R-hat for an mcmcr object
#' @export
rhat.mcmcr <- function(x, by = "all", as_df = FALSE, ...) {
  parameters <- parameters(x)
  x <- lapply(x, rhat, by = by, as_df = as_df)
  if(!as_df) {
    if (by != "all") return(x)
    return(max(unlist(x)))
  }
  x <- Map(x, parameters, f = function(x, p) {parameters(x[[1]]) <- p; x})
  x <- do.call(rbind, x)
  if(by == "all")
    return(tibble::tibble(all = "all", rhat = max(x$rhat)))
  x
}

#' @describeIn rhat R-hat for an mcmcrs object
#' @export
rhat.mcmcrs <- function(x, by = "all", as_df = FALSE, ...) {
  lapply(x, rhat, by = by, as_df = as_df)
}