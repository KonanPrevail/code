from __future__ import division # to avoid round to zero in Python 2.xx
# This changes the meaning of the division operator so that it will return a floating point number 
# if needed to give a (closer to) precise answer. The historical behaviour is for x / y to return 
# an int if both x and y are ints, which usually forces the answer to be rounded down

import numpy as np
def optimizeCost(X,y,theta,step,maxrun):
    m = len(y)
    cost_range = np.zeros((maxrun,1))

    for iter in range(0,maxrun):
        # ============== Include your code here ==============
        # h = np.dot(np.transpose(X),np.transpose(theta))
        h = X.dot(theta)
        grad = 1/m*(h - y).T.dot(X)    # grad is 1 x d
        # grad = 1/m*np.dot(np.transpose(h - y),X)    # grad is 1 x d
        theta = theta - step * grad.T
        cost_range[iter] = 1/2/m*(h-y).T.dot(h-y) ## ** is element-wise power of 2
        # print(iter)
        # ====================================================
    
    # return multiple variables in a tuple
    return theta,cost_range
	
def computeCost(X,y,theta):
    m = len(y)
    cost = 0
    
    # ============== Include your code here ==============
    h = np.dot(X,theta) 
    cost = 1/2/m*(h-y).T.dot(h-y)
    # ====================================================
    
    return(cost)	