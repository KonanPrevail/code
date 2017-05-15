# No regularization
# clear workspace
rm(list = ls())
path="C:/xxx"
setwd(path)
# source in self-defined functions
source('lreg_bankruptcy_lib.R')
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

