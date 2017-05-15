computeCost <- function(theta,input_num,hidden_num,label_num,X,y,lambda) {
  # making Theta1 and Theta2 matrices from the vector theta 
  # http://ufldl.stanford.edu/wiki/index.php/Backpropagation_Algorithm
  Theta1 <- matrix(theta[1:hidden_num*(input_num+1)],hidden_num,(input_num+1))
  Theta2 <- matrix(theta[-1:-(hidden_num*(input_num+1))],label_num,(hidden_num+1))
  m <- dim(X)[1]
  
  # convert the labels,1 to 10,2 to 01
  I <- diag(label_num)
  Y <- matrix(0,m,label_num)
  for (i in (1:m)) {
    Y[i,] = I[y[i],]
  }
  
  A1 <- cbind(rep(1,m),X) # A1: m x (input_num+1)
  Z2 <- A1%*%t(Theta1) # Z2: m x hidden_num; Theta1: hidden_num x (input_num+1)
  A2 <- cbind(rep(1,m),sigmoid(Z2)) # A2: m x (hidden_num+1)
  Z3 <- A2%*%t(Theta2)# Z3: m x number of output nodes; Theta2: number of output nodes x (number of hidden nodes+1)
  H <- sigmoid(Z3) # A3 and H: m x number of output nodes
  A3 <- H
  
  # Feedforward & cost function
  J = (1/m)*sum((-Y)*log(H)-(1-Y)*log(1-H))
  
  # Regularization 
  reg = (lambda/(2))*(sum(Theta1[,-1]^2)+sum(Theta2[,-1]^2))
  J = J+reg
  
  return(J)
}

computeGradient <- function(theta,input_num,hidden_num,label_num,X,y,lambda) {
  # making Theta1 and Theta2 matrices from the vector theta 
  # http://ufldl.stanford.edu/wiki/index.php/Backpropagation_Algorithm
  Theta1 <- matrix(theta[1:hidden_num*(input_num+1)],hidden_num,(input_num+1))
  Theta2 <- matrix(theta[-1:-(hidden_num*(input_num+1))],label_num,(hidden_num+1))
  m <- dim(X)[1]
  
  # convert the labels,1 to 10,2 to 01
  I <- diag(label_num)
  Y <- matrix(0,m,label_num)
  for (i in (1:m)) {
    Y[i,] = I[y[i],]
  }
  
  A1 <- cbind(rep(1,m),X) # A1: m x (input_num+1)
  Z2 <- A1%*%t(Theta1) # Z2: m x hidden_num; Theta1: hidden_num x (input_num+1)
  A2 <- cbind(rep(1,m),sigmoid(Z2)) # A2: m x (hidden_num+1)
  Z3 <- A2%*%t(Theta2)# Z3: m x number of output nodes; Theta2: number of output nodes x (number of hidden nodes+1)
  H <- sigmoid(Z3) # A3 and H: m x number of output nodes
  A3 <- H
  
  # Feedforward & cost function
  J = (1/m)*sum((-Y)*log(H)-(1-Y)*log(1-H))
  
  # Regularization 
  reg = (lambda/(2))*(sum(Theta1[,-1]^2)+sum(Theta2[,-1]^2))
  J = J+reg
  # Backpropagation & Big deltas
  delta3 = A3-Y # m x label_num
  
  delta2 = (delta3%*%Theta2)*gradient(Z2) 
  # delta3: m x label_num, Theta2: label_num x (hidden_num+1), gradient(Z2): a2 * (1-a2): m x (hidden_num+1)
  # delta2: m x (hidden_num+1)
  delta2 = delta2[,-1] # now delta2: m x hidden_num
  BigDelta1 = t(delta2)%*%A1 # ((hidden_num) x m) x (m x (input_num+1)) = ((hidden_num) x (input_num+1))
  BigDelta2 = t(delta3)%*%A2 # ((label_num) x m) x (m x (hidden_num+1)) = (label_num) x (hidden_num+1)
  
  # Regularized Gradient
  Theta1_grad = BigDelta1/m+lambda*cbind(rep(0,hidden_num),Theta1[,-1]) # Theta1: hidden_num x (input_num+1)
  Theta2_grad = BigDelta2/m+lambda*cbind(rep(0,label_num),Theta2[,-1]) # Theta2: label_num x (hidden_num+1)
  
  # Making vector theta from Theta1 and Theta2 to return
  grad = c(c(Theta1_grad),c(Theta2_grad))
  
  return(grad)
}

gradient<-function (z) {
  p <- dim(z)[1]
  a <- cbind(rep(p,1),sigmoid(z))
  g <- a * (1-a)
}

normalize <- function(X) {
  m <- dim(X)[1]
  n <- dim(X)[2]
  maxval <- apply(X,2,max)
  minval <- apply(X,2,min)
  
  # example here: How to divide each row of a matrix by elements of a vector in R
  # http://stackoverflow.com/questions/20596433/how-to-divide-each-row-of-a-matrix-by-elements-of-a-vector-in-rhttp://stackoverflow.com/questions/20596433/how-to-divide-each-row-of-a-matrix-by-elements-of-a-vector-in-rhttp://stackoverflow.com/questions/20596433/how-to-divide-each-row-of-a-matrix-by-elements-of-a-vector-in-r
  # mat<-matrix(1,ncol=2,nrow=2,TRUE)
  # dev<-c(5,10)
  # mat/dev or mat-dev would apply dev on mat column-wise, to be row-wise do:
  # t(t(mat) / dev)
  
  Xnumerator <- t(t(X)-minval)
  Xnorm <- t(t(Xnumerator)/(maxval-minval))
}

predict <- function(Theta1,Theta2,X) {
  m <- dim(X)[1]
  n <- dim(X)[2]
  h1 <- sigmoid(cbind(rep(1,m),X)%*%t(Theta1))
  h2 <- sigmoid(cbind(rep(1,m),h1)%*%t(Theta2))
  pred <- apply(h2,1,function(x) which(x==max(x)))
}

sigmoid <- function(z) {
  g = 1/(1+exp(-z))
}

