import platform
import numpy as np
import random
   
def costFun(param, Y, r, n_lenders, n_loans, n_features, lamba):
    X = param[0:(n_loans * n_features)]
    Theta = param[(n_loans * n_features):len(param)]
    X = X.reshape(n_loans, n_features, order = "F")
    Theta = Theta.reshape(n_lenders, n_features, order = "F")
    
    # Cost
    predictions = np.dot(X, Theta.T)
    errors = np.multiply(predictions - Y, r) 
    J = (1/2)*np.sum(errors**2)

    # Regularized cost function
    reg_X = (lamba/2) * np.sum(X**2)
    reg_Theta = (lamba/2) * np.sum(Theta**2)
    J = J + reg_Theta + reg_X
    
    return J

def cost_grad(param, Y, r, n_lenders, n_loans, n_features, lamba):    
    X = param[0:(n_loans * n_features)]
    Theta = param[(n_loans * n_features):len(param)]
    X = X.reshape(n_loans, n_features, order = "F")
    Theta = Theta.reshape(n_lenders, n_features, order = "F")
    predictions = np.dot(X, Theta.T)
    errors = np.multiply(predictions - Y, r) 
    
    # Gradients    
    X_grad = np.dot(errors, Theta) # error is  nm x nu,and Theta is nu x n,X_grad is nm x n
    Theta_grad = np.dot(errors.T, X) # error' is  nu x nm,X is nm x n,so Theta_grad is nu x n
 
    # Regularized cost function
    X_grad = X_grad + lamba * X
    Theta_grad = Theta_grad + lamba * Theta

    grad = np.concatenate((X_grad.reshape(n_loans * n_features, 1, order = "F"), \
                           Theta_grad.reshape(n_lenders * n_features, 1, order = "F")))
    grad = np.squeeze(grad)
    return grad
    
def optimizeCost(param, Y, r, n_lenders, n_loans, n_features, lamba, step, maxrun):
    cost_range = np.zeros((maxrun, 1))
    for iter in range(maxrun):
        grad = cost_grad(param, Y, r, n_lenders, n_loans, n_features, lamba)
        J = costFun(param, Y, r, n_lenders, n_loans, n_features, lamba)
        param = param - step * grad
        cost_range[iter] = J

    return param
        
with open(datPath, newline='') as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)
txt = np.array(datList.pop(0))  # get the colnames in the first row and remove it
Y = np.array(datList)[range(100),:]
Y = Y.astype(float)
R = (Y != 0)
R = R.astype(float)

datPath = "..\data\loandata.csv"
with open(datPath, newline='') as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)
text = np.array(datList.pop(0)) # get the colnames in the first row and remove it
num = np.array(datList)[range(100),:]
num = num.astype(float)

n_lenders = np.size(Y, 1)
n_loans = np.size(Y, 0)
n_features = 10
# Initialization
X = np.random.normal(loc = 0.0, scale = 1.0, size = (n_loans, n_features))
Theta = np.random.normal(loc = 0.0, scale = 1.0, size = (n_lenders,n_features))
init_param = np.concatenate((X.reshape(n_loans * n_features, 1, order = "F"),
                             Theta.reshape(n_lenders * n_features, 1, order = "F")))
init_param = np.squeeze(init_param)

# Optimization
lamba = 10
maxrun = 10000
step = 0.001

param = supp.optimizeCost(init_param, Y, R, n_lenders, n_loans, \
                     n_features, lamba, step, maxrun)
# Extract X and Theta from param vector
X = param[0:(n_loans * n_features)]
Theta = param[(n_loans * n_features):len(param)]
X = X.reshape(n_loans, n_features, order = "F")
Theta = Theta.reshape(n_lenders, n_features, order = "F")
pred = np.dot(X, Theta.T)

# print out top 3 ratings for each lender
top_n = 3
for j in range(n_lenders):
    rating = np.sort(pred[:, j])[::-1]
    ind = np.argsort(pred[:, j])[::-1]
    a = num[ind,:]
    print('\nTop %d recommendations for lender %d:\n' % (top_n, (j+1)))
    for i in range(top_n):
        print('Predicted rating %.1f for loan of %.1f for %s with %s purpose at %.1f percent interest\n' %
        (rating[i], np.float(a[i, 0]), a[i, 1], a[i, 6], np.float(a[i,2])))  



