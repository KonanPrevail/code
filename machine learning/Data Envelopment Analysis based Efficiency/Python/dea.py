from numpy import array
from numpy import zeros
from numpy import concatenate
from numpy import dot
from numpy import transpose
from scipy.optimize import linprog

I = array([[150,70,5],
            [60,20,3],
            [800,140,20],
            [30,15,1]])

O = array([[15,225],
            [5.4,70],
            [56,1300],
            [2.1,40]])

m,n1=I.shape
m,n2=O.shape

f=concatenate((zeros((m,n1)),-O),axis=1)
lb=array([0]*(n1+n2))
#x=array([[0]*(n1+n2)]*m) 
x=[]
A=concatenate((array([[0]*(n1)]*m),O),axis=1)-concatenate((I,array([[0]*(n2)]*m)),axis=1)
b=array([0]*m) 

for i in range(0,m):
    Aeq=array([concatenate((I[i,:],array([0]*n2)),axis=1)])
    beq=array([1])
    #z=linprog(f[i,:], A_ub=A, b_ub=b, bounds=((0,None),(0,None),(0,None),(0,None),(0,None)),options={"disp": True})
    z=linprog(f[i,:], A_ub=A, b_ub=b,A_eq=Aeq, b_eq=beq, options={"disp": True})
    
    x.append(z.x)

x=array(x)    
result=x*concatenate((I,O),axis=1)
result[:,3]+result[:,4]
   