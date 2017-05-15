rm(list=ls())

wd <-"" #set directory here
setwd(wd)

require(pracma)

classify <- function(tree, X){
  n = nrow(X)
  pred = zeros(n,1)

  for (i in 1:n){
    node = 1 # start with the root node
    while (TRUE) { # for each test instance, go through the trained tree until the leaf
      if (!tree[[node]]$isLeaf){
        var = tree[[node]]$variable
        if (X[i, var] == 1){
          node = tree[[node]]$rightchild
        }
        else{
          node = tree[[node]]$leftchild
        }
      }
      else{
        if (tree[[node]]$label1 == tree[[node]]$label2){
          pred[i] = randi(2) - 1 # if the counts are ties just randomly assign classes
        }
        else{
          pred[i] = tree[[node]]$label2 > tree[[node]]$label1
        }
        break
      }
    }
  }
  return(pred)
}

printtree <- function(tree){
  # Depth First Search
  traverse(tree, 1, '')
}

traverse <- function(tree, node, s){
  if (!tree[[node]]$isLeaf){
    if (length(s) > 0){
      print(s)
    }
    traverse(tree, tree[[node]]$leftchild, paste(s,'V',toString(tree[[node]]$variable),'=0'))
    traverse(tree, tree[[node]]$rightchild, paste(s,'V',toString(tree[[node]]$variable),'=1'))
  }
  else{
    s = paste(s,' => classify y=', toString(as.numeric(tree[[node]]$label2>tree[[node]]$label1)), ' distribution=[',toString(tree[[node]]$label1),', ', toString(tree[[node]]$label2),']')
    print(s)
  }  
}

leafcat <- function (tree, node, X, Y){
  # return the counts of classes and from there to classify instances
  
  variables = varpath(tree, node)[[1]]
  values = varpath(tree, node)[[2]]# get the variables from the node up to the root
  n = nrow(X)
  mask = matrix(T,n,1)
  for (i in 1:nrow(variables)){ # iterate through variables/columns
    mask = mask & (X[, variables[i]] == values[i]) # mark instances that were split on each node/variable. Finally mask would have instances onto the current leaf node
  }
  num_y1 = sum(Y[mask]) # only good for binary
  num_y0 = n - num_y1 # only good for binary
  l <- list(num_y0, num_y1)
  return(l)
}

infogain <- function(x,y){
  
  info_gains = matrix(0,1, ncol(x))

  # calculate information i(N)
  classes = t(unique(y))
  iN = 0
  for (c in classes){
    py = sum(y==c)/length(y)
    iN = iN - py*log2(py)
  }

  # iterate over all variables on columns
  for (col in 1:ncol(x)){
    values = t(unique(x[,col]))
    # entropy
    iNx = 0
    for (f in values){ # only binary 0/1 for now
      pf = sum(x[,col]==f)/nrow(x)
      yf = y[which(x[,col]==f)]

      classes = t(unique(yf))
      iNk = 0
      for (c in classes){
        pyf = sum(yf==c)/length(yf)
        iNk = iNk - pyf*log2(pyf)
      }
      iNx = iNx + pf * iNk
    }
    info_gains[col] = iN - iNx
  }
  gain = max(info_gains) 
  max_gain_feature = which.max(info_gains[1,])
  l = list(gain, max_gain_feature)
  return(l)
}

varpath <-function (tree, node){
  curdepth = tree[[node]]$depth # get the depth of the node
  vars = matrix(data=0,nrow=tree[[node]]$depth,ncol=1)
  vals = vars
  while (curdepth>0){
    current = tree[[node]] # current node
    parent = tree[[tree[[node]]$parent]] # parent node
    vars[curdepth] = parent$variable # which variable was the parent node split on?
    vals[curdepth] = parent$rightchild==node   # if the node is the right child, the value=1, if it is the left, the value = 0
    node = current$parent # move up to the parent
    curdepth = curdepth - 1 # and reduce the depth correspondingly
  }
  l = list(vars,vals)
  return (l)
}

buildtree <- function(X, Y, maxdepth){

    if (nrow(X) < maxdepth){
    maxdepth = dim(X)[2]
  }

  tree = vector("list",2^dim(X)[2] + 1)
  .GlobalEnv$index = 1
  curnode = 1
  parent = -1
  tree = build(tree, parent, curnode, X, Y, maxdepth)
}

build <- function(tree, parent, curnode, X, Y, maxdepth){
  if  (.GlobalEnv$index == 1){  
    tree[[curnode]]$parent = parent
    tree[[curnode]]$depth = 0
  }
  else{
    tree[[curnode]]$parent = parent
    tree[[curnode]]$depth = tree[[parent]]$depth + 1
  }
  isLeaf = !(tree[[curnode]]$depth < maxdepth)
  tree[[curnode]]$isLeaf = isLeaf
  if (!isLeaf){
    # Choose split var
    used_vars = varpath(tree, curnode)[1]
  
    availVars = setdiff(1:dim(X)[2], used_vars)
    # select a variable to split
    bestIndex = infogain(X[,availVars], Y)[[2]]
  
    tree[[curnode]]$variable = availVars[bestIndex]
  
    # Add child nodes
    leftchild = .GlobalEnv$index + 1
    rightchild= .GlobalEnv$index + 2
    .GlobalEnv$index = .GlobalEnv$index + 2
  
    tree[[curnode]]$leftchild = leftchild
    tree[[curnode]]$rightchild = rightchild
  
    # Depth first search (DFS)
    v = availVars[bestIndex]
    tree = build(tree, curnode, leftchild, X[X[,v]==0,], Y[X[,v]==0], maxdepth) # to create a left child with the current node as the parent
    tree = build(tree, curnode, rightchild, X[X[,v]==1,], Y[X[,v]==1], maxdepth) # to create a right child with the current node as the parent
  }
  else{     
    li = leafcat(tree, curnode, X, Y)
    y0 <- li[[1]]
    y1 <- li[[2]]
    tree[[curnode]]$label1 <- y0
    tree[[curnode]]$label2 <- y1
  }
  return(tree)
}

datPath <- paste("..", "data", "bankruptcy.csv", sep = .Platform$file.sep)
data<-read.csv(datPath)
valnum <- 2
train_pc = 0.7
depth = 4

x = data.frame(data[,2:13])
y = data.frame(data[,14]==1)

i =3
for (i in 1:ncol(x)){
  if (length(unique(x[,i]))>valnum){
    binEdges = seq(min(x[,i],na.rm = T), 
                   max(x[,i],na.rm = T),
                   length.out = valnum + 1)
    binIdx <- histc(x[,i],c(binEdges[1:length(binEdges)-1],Inf))$bin
    x[,i] <- binIdx - 1
    
  }
}

m = dim(x)[1]
n = dim(x)[2]


train_ind <- c(sample(which(y == 0), floor(train_pc * sum(y == 0))),sample(which(y == 1), floor(train_pc * sum(y == 1))))

yTrain = y[1:m%in%train_ind,]
xTrain = x[1:m%in%train_ind,]
tree = buildtree(xTrain, yTrain, depth) # create a tree recursively
tree = tree[!sapply(tree, isempty)] # remove unnessary cells which are empty 

printtree(tree)

trainpred = classify(tree, xTrain)
print('Training Accuracy:')
print(mean(trainpred==yTrain))

yTest = y[!1:m%in%train_ind,]
xTest = x[!1:m%in%train_ind,]
testpred = classify(tree, xTest)
print('Test Accuracy:')
print(mean(testpred==yTest))
