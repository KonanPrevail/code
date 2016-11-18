from __future__ import division # to avoid round to zero in Python 2.xx
# This changes the meaning of the division operator so that it will return a floating point number 
# if needed to give a (closer to) precise answer. The historical behaviour is for x / y to return 
# an int if both x and y are ints, which usually forces the answer to be rounded down

for name in dir():
    if not name.startswith('_'):
        del globals()[name]

import numpy as np
import os
import reg_capm_lib as lib
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

data = np.loadtxt(r"C:\xxx\CAPMuniverse.csv",delimiter=",",skiprows=1)
(m,n) = data.shape # number of observations x number of variables

# y is the return of an individual stock; X is the return of the market
# 0th column is Date, 0-based in Python (1 based in R and MATLAB)
y = np.matrix(data[:, 12]-data[:, 14]).reshape(m,1) # 12th is YHOO, 14th is the risk-free rate
X = data[:, 13]-data[:, 14] # 13th is the market return

# ================== Gradient Descent =======================
#  np.r_ and np.c_. (Think "column stack" and "row stack" (which are also functions) but with matlab-style range generations.)
X = np.matrix(np.c_[np.ones((m,1)), X]) # now add a column of 1 to X so it becomes [x0,x1]
maxrun = 1000000 # maximum number of iterations
step = 0.1
theta = np.matrix(np.zeros((2, 1))) # parameters for x0 and x1 respectively

# result returned in a tuple
theta,cost_range= lib.optimizeCost(X,y,theta,step,maxrun) # matrix form function

pred = X.dot(theta) # predicted y or the hypothesis
# =============== Plot the data and results =================
# plot y against X;
plt.plot(X[:,1], y,"r.",markersize=1,label="Training data") # red dots
plt.ylabel("Individual Security")
plt.xlabel("S&P500")

# now plot the regression line
plt.plot(X[:,1],pred,"b.",markersize=1,label="Predicted regression line") # note: this is 0-based
plt.legend(loc="upper left")
plt.show()

# now plot the cost
plt.plot(cost_range,"b.",markersize=1,label="Cost") # note: this is 0-based
plt.show()
