#' @export
print.mcmcarray <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

#' @export
print.mcmcr <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

#' @export
print.summary.mcmcarray <- function(x, ...) {
  print(x$estimates)
  cat("\nnchains: ", x$nchains, "\n")
  cat("niters: ", x$niters, "\n")
  invisible(x)
}

#' @export
print.summary.mcmcr <- function(x, ...) {
  lapply(x$arrays, print)
  invisible(x)
}
