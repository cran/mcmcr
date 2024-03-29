test_that("rhat.matrix", {
  matrix <- matrix(1, nrow = 2, ncol = 100)
  expect_identical(.rhat(matrix, na_rm = FALSE), 1)
  matrix[1, 1] <- NA
  expect_true(is.na(.rhat(matrix, na_rm = FALSE)))
  expect_identical(.rhat(matrix, na_rm = TRUE), 1)
  matrix[1, ] <- 2
  expect_true(is.infinite(.rhat(matrix, na_rm = FALSE)))

  matrix <- matrix(rep(1, 50), rep(2, 50), nrow = 1, ncol = 100)
  expect_true(is.na(.rhat(matrix, na_rm = FALSE)))
  matrix[1, 1] <- 1.1
  matrix[1, 100] <- 2.1
  expect_true(is.na(.rhat(matrix, na_rm = FALSE)))

  matrix <- matrix(NA_real_, nrow = 2, ncol = 100)
  expect_true(is.na(.rhat(matrix, na_rm = FALSE)))
  expect_true(is.na(.rhat(matrix, na_rm = TRUE)))
})

test_that("rhat.mcarry", {
  expect_identical(rhat(as.mcarray(mcmcr_example$beta)), 1.147)
})

test_that("rhat.mcmc", {
  expect_identical(rhat(coda::as.mcmc(collapse_chains(mcmcr_example$beta))), 1)
})

test_that("rhat.mcmc.list", {
  expect_identical(rhat(coda::as.mcmc.list(mcmcr_example)), 2.002)
})

test_that("rhat.mcmcmarray", {
  expect_identical(rhat(mcmcr_example[[1]], by = "term"), c(2.002, 2.002))

  expect_identical(
    rhat(mcmcr_example[[1]], as_df = TRUE, by = "all"),
    structure(list(parameter = "parameter", rhat = 2.002),
      class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -1L)
    )
  )

  expect_equal(rhat(mcmcr_example[[2]], by = "term"), matrix(c(1.147, 1.147, 1.147, 1.147), nrow = 2, ncol = 2))

  expect_identical(rhat(mcmcr_example[[2]]), 1.147)
  expect_equal(rhat(mcmcr_example[[2]], by = "term", as_df = TRUE)$term, as_term(c("parameter[1,1]", "parameter[2,1]", "parameter[1,2]", "parameter[2,2]")))
  expect_equal(rhat(mcmcr_example[[2]], by = "term", as_df = TRUE)$rhat, c(1.147, 1.147, 1.147, 1.147))

  expect_identical(rhat(subset(mcmcr_example[[2]], iters = 1L), by = "term", as_df = TRUE)$rhat, rep(NA_real_, 4))
  expect_identical(rhat(mcmcr_example[[1]], "parameter"), rhat(mcmcr_example[[1]], "all"))
})

test_that("rhat.mcmcr", {
  expect_identical(rhat(mcmcr_example2), 2.002)
  expect_identical(
    rhat(mcmcr_example, as_df = TRUE),
    structure(list(all = "all", rhat = 2.002),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )

  expect_identical(rhat(mcmcr_example), 2.002)
  expect_identical(rhat(mcmcr_example, by = "parameter"), list(alpha = 2.002, beta = 1.147, sigma = 1))
  expect_equal(rhat(mcmcr_example, by = "parameter", as_df = TRUE), tibble(parameter = c("alpha", "beta", "sigma"), rhat = c(2.002, 1.147, 1)), ignore_attr = FALSE)
  expect_equal(rhat(mcmcr_example, by = "term"), list(alpha = c(2.002, 2.002), beta = matrix(c(1.147, 1.147, 1.147, 1.147), nrow = 2.002, ncol = 2), sigma = 1))
  expect_equal(rhat(mcmcr_example, by = "term", as_df = TRUE), tibble(term = as_term(c("alpha[1]", "alpha[2]", "beta[1,1]", "beta[2,1]", "beta[1,2]", "beta[2,2]", "sigma")), rhat = c(2.002, 2.002, 1.147, 1.147, 1.147, 1.147, 1)))
})

test_that("rhat.mcmcr NA", {
  x <- mcmcr:::mcmcr_example2
  x$alpha[1, 1, 1, 1, 1] <- NA_real_
  expect_identical(rhat(x), NA_real_)
  expect_identical(rhat(x, na_rm = TRUE), 2.085)
  expect_identical(rhat(x, by = "parameter"), list(alpha = NA_real_, beta = 1.147, sigma = 1))
  expect_identical(rhat(x, by = "parameter", na_rm = TRUE), list(alpha = 2.085, beta = 1.147, sigma = 1))
})

test_that("rhat.mcmcrs", {
  expect_identical(rhat(mcmcrs(mcmcr_example, mcmcr_example)), list(mcmcr1 = 2.002, mcmcr2 = 2.002))
  expect_identical(rhat(mcmcrs(mcmcr_example, mcmcr_example), bound = TRUE), 1.891)
  expect_identical(
    rhat(mcmcrs(mcmcr_example, mcmcr_example), by = "parameter"),
    list(
      mcmcr1 = list(alpha = 2.002, beta = 1.147, sigma = 1),
      mcmcr2 = list(alpha = 2.002, beta = 1.147, sigma = 1)
    )
  )
  expect_identical(
    rhat(mcmcrs(mcmcr_example, mcmcr_example), bound = TRUE, by = "parameter"),
    list(alpha = 1.891, beta = 1.127, sigma = 1)
  )
})
