# cleaning
rm(list=ls())
path="C:/xxx"
setwd(path)

source("nn_insurance_lib.R")

hidden_num <- 100
label_num <- 2 # 10 and 01       
train_pc <- .66

data <- read.csv('insurance.csv')

y <- (data[,31]=="Yes")+1 # 1 and 2
X <- data.matrix(cbind(data[,8:14],data[,16:29])) # only numeric fields, converted to matrix
X <- normalize(X) # binary fields are not affected from min-max normalization

input_num <- dim(X)[2]

max_instance <- max(sum(y==1),sum(y==2))

train_ind <- c(sample(which(y==1),floor(train_pc*sum(y==1)),replace = FALSE),sample(which(y==2),floor(train_pc*sum(y==2)),replace = FALSE))
yTrain <- y[train_ind]
yTest <- y[-train_ind]
xTrain <- X[train_ind,]
xTest <- X[-train_ind,]

lambda <- 0.05
epsilon <- 0.1
Theta1 <- matrix(runif(hidden_num*(1+input_num)),hidden_num,1+input_num)*2*epsilon-epsilon # random beween -epsilon and epsilon
Theta2 <- matrix(runif(label_num*(1+hidden_num)),label_num,1+hidden_num)*2*epsilon-epsilon # random beween -epsilon and epsilon

theta <- c(c(Theta1),c(Theta2))

# result <- optim(theta, fn=computeCost, gr=computeGradient, input_num = input_num,hidden_num = hidden_num,label_num = label_num,X = X,y = y,lambda = lambda,method="BFGS",hessian = TRUE, control=list(trace=TRUE))

result <- optim(theta, fn=computeCost, gr=computeGradient, input_num = input_num,hidden_num = hidden_num,label_num = label_num,X = X,y = y,lambda = lambda,method="BFGS",control=list(trace=TRUE,maxit=1000000))

theta <- result$par
  
Theta1 <- matrix(theta[1:hidden_num*(input_num+1)],hidden_num,(input_num+1))
Theta2 <- matrix(theta[-1:-(hidden_num*(input_num+1))],label_num,(hidden_num+1))

predTrain = predict(Theta1,Theta2,xTrain)
cat('Training Set Accuracy:',mean(predTrain == yTrain)*100)

predTest = predict(Theta1,Theta2,xTest)
cat('Test Set Accuracy:',mean(predTest == yTest)*100)

             