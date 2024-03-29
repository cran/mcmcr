#' Term coefficients
#'
#' Gets coefficients for all the terms in an MCMC object.
#'
#' @inheritParams params
#' @return An data frame of the coefficients with the columns indicating the
#' `term`, `estimate`,
#' `lower` and `upper` credible intervals and `svalue`
#' @export
#' @seealso [stats::coef]
#' @examples
#' coef(mcmcr_example)
#' @name coef
NULL

# .simplify is a necessary hack to stop apply using simplify argument!
coef_numeric_impl <- function(object, conf_level, estimate, .simplify) {
  simplify <- .simplify
  chk_number(conf_level)
  chk_range(conf_level)
  chk_function(estimate)
  chk_flag(simplify)

  if(!simplify) {
    lifecycle::deprecate_warn("0.4.1", "coef(simplify = 'must be TRUE')")
  }

  lower <- (1 - conf_level) / 2
  upper <- conf_level + lower

  quantiles <- stats::quantile(object, c(lower, upper), na.rm = TRUE, names = FALSE)

  if (anyNA(object) || identical(length(object), 1L)) quantiles[c(1, 2)] <- NA

  estimate <- estimate(object)
  if (!identical(length(estimate), 1L)) abort_chk("`estimate` must return a scalar")

  if(simplify) {
    return(tibble(
      estimate = estimate, lower = quantiles[1], upper = quantiles[2],
      svalue = extras::svalue(object)
    ))
  }
  sd <- stats::sd(object)
  zscore <- mean(object) / sd

  tibble(
    estimate = estimate, sd = sd, zscore = zscore,
    lower = quantiles[1], upper = quantiles[2], pvalue = extras::pvalue(object)
  )
}

#' @export
coef.numeric <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  coef_numeric_impl(object, conf_level = conf_level, estimate = estimate, .simplify = simplify)
}

#' @export
coef.mcarray <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  coef(as.mcmc.list(object), conf_level = conf_level, estimate = estimate, simplify = simplify)
}

#' @describeIn coef Get coefficients for terms in mcmc object
#' @export
coef.mcmc <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  term <- as_term(object)
  object <- t(object)
  object <- apply(object, MARGIN = 1, FUN = coef_numeric_impl,
                  conf_level = conf_level, estimate = estimate,
                  .simplify = simplify)
  object <- do.call(rbind, object)
  object$term <- term
  colnames <- c("term", "estimate", "sd", "zscore", "lower", "upper", "pvalue")
  if(simplify)
    colnames <- c("term", "estimate", "lower", "upper", "svalue")
  object <- object[colnames]
  object <- object[order(object$term), ]
  object
}

#' @export
coef.mcmc.list <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  object <- as.mcmc(collapse_chains(object))
  coef(object, conf_level = conf_level, estimate = estimate, simplify = simplify)
}

#' @export
coef.mcmcarray <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  coef(as.mcmc.list(object), conf_level = conf_level, estimate = estimate, simplify = simplify)
}

#' @export
coef.mcmcr <- function(object, conf_level = 0.95, estimate = median, simplify = TRUE, ...) {
  coef(as.mcmc.list(object), conf_level = conf_level, estimate = estimate, simplify = simplify)
}
