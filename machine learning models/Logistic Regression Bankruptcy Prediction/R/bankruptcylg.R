# No regularization
# clear workspace
rm(list = ls())
path="C:/xxx"
setwd(path)

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

# loading data
data <- read.csv('bankruptcy.csv', header = TRUE)
# y is the response variable; X is the independent variables
y <- data$FAIL
X <- data[, 2:13]
m <- nrow(X)
n <- ncol(X)

X <- sapply(X, normalize)
X <- cbind(rep(1, m), X)
X <- round(X, digits = 4)
# take 60% for training, and use the rest for testing
train <- sample(1:60, 36, replace = FALSE)
Xtrain <- X[train, ]
Xtest <- X[-train, ]
ytrain <- y[train]
ytest <- y[-train]
# optimization using optim
init <- rep(0, n + 1)
theta <- optim(par = init, fn = computeCost, gr = grad, X = Xtrain, y = ytrain,
               method = 'BFGS', control = list(maxit = 100))$par
# prediction and accuracy
pred <- sigmoid(Xtest %*% theta) >= 0.5
cat("Accurary: ",length(ytest[as.numeric(pred) == ytest]) / length(ytest) * 100,"%")

# Use regularization
#######################################################
rm(list = ls())
source('lreg_bankruptcy_lib.R')
data <- read.csv('bankruptcy.csv', header = TRUE)
# y is the response variable; X is the independent variables
y <- data$FAIL
X <- data[, 2:13]

X <- sapply(X, normalize)
# mapping X to higher dimensional space
Xnew <- mapping(X, 2)
# take 60% for training, and use the rest for testing
train <- sample(1:60, 36, replace = FALSE)
Xtrain <- Xnew[train, ]
Xtest <- Xnew[-train, ]
ytrain <- y[train]
ytest <- y[-train]
# restriction lambda = 0.01
lambda <- 0.01
# optimization using optim
init <- rep(0, ncol(Xtrain))
theta <- optim(par = init, fn = computeCost, gr = grad, X = Xtrain, y = ytrain,
               method = 'BFGS', control = list(maxit = 50))$par
# prediction and accuracy
pred <- sigmoid(Xtest %*% theta) >= 0.5
cat("Accurary: ",length(ytest[as.numeric(pred) == ytest]) / length(ytest) * 100,"%")

