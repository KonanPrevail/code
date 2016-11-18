# normalize X
normalize <- function(cl) {
  means <- mean(cl)
  sds <- sd(cl)
  return((cl - means) / sds)
}

mapping <- function(X, degree){
  m <- nrow(X)
  n <- ncol(X)
  power <- selectk(0:degree, n)
  ind <- (rowSums(power) <= degree)
  power <- power[ind, ]
  p <- nrow(power)
  Xmap <- matrix(0, m, p)
  for (i in 1:p){
    aterm <- rep(1, m)
    for (j in 1:n){
      aterm <- aterm * X[, j]^power[i, j]
    }
    Xmap[, i]  <- aterm
  }
  return(Xmap)
}

selectk <- function(v, k) {
  matList <- rep(list(v), k)
  res <- expand.grid(matList)
  res[, seq(k, 1, - 1)]
}

sigmoid <- function(x){
  sigm <- 1 / (1 + exp(-x))
  return(sigm)
}

grad <- function(theta, X, y, lambda = 0){
  m <- length(y)
  theta <- matrix(theta, ncol(X), 1)
  z <- X %*% theta
  h <- sigmoid(z)
  grad <- (1 / m) * t(h - y) %*% X
  + lambda * t(c(0, theta[2:length(theta)])) / m
  return(grad)
}

computeCost <- function(theta, X, y, lambda = 0){
  m <- length(y)
  theta <- matrix(theta, ncol(X), 1)
  z <- X %*% theta
  h <- sigmoid(z)
  cost <- (1 / m) * sum(- y * log(h) - (1 - y) * log(1 - h)) +
    (lambda / (2 * m)) * sum(theta[2:length(theta)]^2)
  return(cost)
}
