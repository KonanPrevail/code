library(linprog)

I = matrix(c(150,60,800,30,70,20,140,15,5,3,20,1), nrow = 4, ncol = 3)
O = matrix(c(15,5.4,56,2.1,225,70,1300,40),nrow =4, ncol = 2)
a = dim(I)
m = a[1]
n1 = a[2]

b = dim(O)
n2 = b[2]
f = cbind(matrix(0,m,n1),O)
lb = matrix(0,n1+n2,1)
x = matrix(0,m,n1+n2)

for (i in 1:m)
{
  Aeq = c(I[i,], matrix(0,1,n2))
  beq = 1
  A = rbind(Aeq,cbind(matrix(0,m,n1), O) - cbind(I, matrix(0,m,n2)))
  b = rbind(1,matrix(0,m,1))
  z = solveLP(f[i,],b,A,maximum=TRUE,const.dir = c("==","<=","<=","<=","<="),lpSolve=TRUE)
  x[i,]=z$solution
}

result = x*cbind(I,O)
sum(result[,1:3])
rowSums(result[,4:5])
