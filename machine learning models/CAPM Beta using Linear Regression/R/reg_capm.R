# cleaning
rm(list=ls())
path="C:/xxx"
setwd(path)

source("reg_capm_lib.R")

library("plot3D")
library("plotly")

data <- read.csv('../../data/CAPMuniverse.csv')
m = dim(data)[1] # number of observations x number of variables
n = dim(data)[2] # number of observations x number of variables

# y is the return of an individual stock; X is the return of the market
y = data[, 13]-data[, 15] # 13th is YHOO, 15th is the risk-free rate
X = data[, 14]-data[, 15] # 14th is the market return

# ================== Gradient Descent =======================
X = cbind(rep(1,m), X) # now add a column of 1 to X so it becomes [x0,x1]
maxrun = 1e+6 # maximum number of iterations
step = 0.1
theta = rep(0,2) # parameters for x0 and x1 respectively
r <- optimizeCost(X,y,theta,step,maxrun) # matrix form function
pred = X%*%r$theta # predicted y or the hypothesis

# =============== Plot the data and results =================
# plot y against X;
# pch: which symbol (http://www.statmethods.net/advgraphs/parameters.html)
# cex: symbol scaled 
dev.new()
plot(X[,2],y,ylim=range(c(y,pred)),type="p",pch=20,cex=0.1,col="red",ann=FALSE) 
par(new = TRUE) # here to plot multiple series on the same graph, ylim should be the same
# now plot the regression line
plot(X[,2],pred,ylim=range(c(y,pred)),type="p",pch=20,cex=0.1,col="blue",ann=FALSE)
legend(min(X[,2]), max(y), c("Training data", "Predicted regression line"),cex=0.8,col=c("red","blue"),pch=20)
title(xlab="Market return",col.lab="black")
title(ylab="Security return",col.lab="black")
title(main="CAPM Regression",col.main="black")

# plot the cost vs the number of iterations
dev.new()
plot(r$cost_range,ylab="Cost",pch=20,cex=0.1,xlab="Number of interations",col="blue",ann=FALSE)
title(xlab="Iterations",col.lab="black")
title(ylab="Cost",col.lab="black")
title(main="Cost vs iterations",col.main="black")

# See more examples at http://www.harding.edu/fmccown/r/
th0 <- seq(r$theta[1]-10,r$theta[1]+10,length=100)
th1 <- seq(r$theta[2]-10,r$theta[2]+10,length=100)
grid <- mesh(th0,th1)

m <- length(th0)
n <- length(th1)
cost <- matrix(0,m,n)
for (i in (1:m)){
  for (j in (1:n)) {
    cost[i,j] <- computeCost(X,y,matrix(c(th0[i],th1[j])))
  }
}

surf3D(x=grid$x,y=grid$y,z=cost,colkey=FALSE,bty="b2",main="Cost")

