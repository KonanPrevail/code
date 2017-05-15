rm(list=ls())
library("quadprog")
path="C://xxx"
setwd(path)

normalize <- function(X){
   m <- nrow(X)
   n <- ncol(X)
   maxval <- t(as.matrix(apply(X, 2, max)))
   minval <- t(as.matrix(apply(X, 2, min)))
   Xnorm <- (X - matrix(minval, m, n, byrow=T))/matrix((maxval - minval), m, n, byrow=T)
   return(Xnorm)
}

kernel <- function(XTest,XTrain,sigma,type){
# Linear and Gaussian kernel
# type=0  linear
# type=1  polynomial
# type else  gaussian
   m1 <- nrow(XTest)
   m2 <- nrow(XTrain)
   K <- matrix(0, m1, m2) 
   if (type==0){ 
       K <- XTest %*% t(XTrain)  
   }else if(type==1){
       d <- 4
       K <- ((XTest) %*% t(XTrain) + matrix(1, m1, m2))^d
   } else{ 
       for(i in 1:m1){
          for(j in 1:m2){
            xny <- as.matrix(XTest[i, ] - XTrain[j, ])
            Normxny <- t(xny) %*% xny
            K[i, j] <- exp(-Normxny/(2*sigma^2))
          }
        }
   }  
   return(K)
}


data <- read.csv("insurance.csv", sep=",", header=T)
y <- as.matrix(as.numeric(data[, 31]))
y[y==1]=-1
y[y==2]=1


X <- as.matrix(data[, c(8:14, 16:29)])
X <- normalize(X)
m <- nrow(X)


set.seed(999)
l1 <- length(y[y==-1])
l2 <- length(y[y==1])
sel1 <- sample(l1, replace = FALSE)
sel2 <- sample(l2, replace = FALSE)+l1 

seln1 <- c(sel1[1: round(0.6*l1)], sel2[1: round(0.6*l2)]) 
seln2 <- c(sel1[(round(0.6*l1)+1): l1], sel2[(round(0.6*l2)+1):l2])  

#training data
XTrain <- X[seln1,]
yTrain <- as.matrix(y[seln1,])
#test data
XTest <- X[seln2, ]
yTest <- as.matrix(y[seln2, ])

sigma <- 0.1
K <- kernel(XTrain, XTrain, sigma, 1)
a0 <- runif(nrow(XTrain), 0, 1)

m1 <- nrow(XTrain)

Dmat <- diag(c(yTrain)) %*% K %*% diag(c(yTrain)) + 0.5*diag(m1)
#
dvec <-  matrix(1, m1, 1)
Amat <- cbind(yTrain, diag(m1))
bvec <- c(0, rep(0, m1))
alpha <- as.matrix(solve.QP(Dmat, dvec, Amat, bvec, meq=0)$solution)

index <- which(alpha >= 0.0)
b <- mean(as.matrix(yTrain[index])-K[index,] %*% (alpha*yTrain))
pred <- sign((matrix(1, (m-m1), m1)+(kernel(XTest,XTrain,sigma,1))^2)%*%(alpha*yTrain)+ matrix(b, (m-m1), 1))
message("Test Accuracy: ", mean(pred==yTest)*100)

pred <- sign(((matrix(1, m1, m1)+kernel(XTrain,XTrain,sigma,1))^2)%*%(alpha*yTrain)+matrix(b, m1, 1))
message("Train Accuracy: ", mean(pred==yTrain)*100)


