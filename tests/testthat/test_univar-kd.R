

y <- rnorm(10)
bw <- bw.nrd0(y)
n <- length(y)
w <- rep(1/n, n)
kernel <- "optcosine"
a <- 1

expect_silent(ruvk(10, y))

shrink <- TRUE
expect_silent(ruvk(10, y, bw, kernel, w, a, shrink))

shrink <- FALSE
expect_silent(ruvk(10, y, bw, kernel, w, a, shrink))

bw <- 1:10
expect_message(ruvk(10, y, bw, kernel, w, a, shrink))

bw <- -1
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

bw <- NA
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

bw <- Inf
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

bw <- 1
kernel <- "fluffy cat"
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- 1
kernel <- "gaussian"
expect_silent(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(-1, n)
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(Inf, n)
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(NA, n)
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(1/n, n-1)
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(1/n, n+1)
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(1/n, n)
a <- -1
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(1/n, n)
a <- NA
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))

w <- rep(1/n, n)
a <- Inf
expect_error(ruvk(10, y, bw, kernel, w, a, shrink))


