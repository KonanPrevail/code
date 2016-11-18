optimizeCost <- function(X,y,theta,step,maxrun) {
  m <- dim(X)[1]
  cost_range <- rep(0,length=maxrun) 
  
  for (iter in 1:maxrun) {        
    h = X%*%theta
    grad = 1/m * t(h-y) %*% X # grad is 1 x d
    theta = theta - step * t(grad)#
    cost_range[iter] = 1/2/m*sum((h-y)**2)
  }
  # return multiple variables using a list
  return(list(theta=theta,cost_range=cost_range)) 
}
computeCost <- function(X,y,theta) {
  h <- X%*%theta
  cost <- 1/(2*length(y))*sum((h-y)**2)
  return(cost)
}