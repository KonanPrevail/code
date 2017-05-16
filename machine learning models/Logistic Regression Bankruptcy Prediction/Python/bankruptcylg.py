import lreg_bankrupt_lib as lib
import csv
import numpy as np
import random
from scipy.optimize import minimize

import numpy as np
import itertools

def computeCost(theta, X, y, lambdad=0):
    m = len(y)                  # number of training examples
    z = np.dot(X, theta)
    h = sigmoid(z)
    # define variable theta0 to spare intercept from regularization
    theta0 = theta
    theta0[0] = 0
    cost = 1 / m * sum(- y * np.log(h) - (1 - y) * np.log(1 - h)) + \
        lambdad / m / 2 * sum(theta0 ** 2)
    return cost

# function computing the gradient of cost function
def cost_grad(theta, X, y, lambdad=0):
    m = len(y)                  # number of training examples
    z = np.dot(X, theta)
    h = sigmoid(z)
    # define variable theta0 to spare intercept from regularization
    theta0 = theta
    theta0[0] = 0
    grad = (1 / m * np.dot(h - y, X)) + lambdad * theta0 / m
    return grad

# construct polynomial terms from original predictors with order restrictted
def mapping(X, degree):
    m = np.size(X, 0)
    n = np.size(X, 1)
    power = selectk(range(degree + 1), n)  # construct degree grid
    ind = np.sum(power, axis=1) <= degree  # restrict order
    power = power[ind, :]
    p = np.size(power, 0)
    Xmap = np.ones([m, p + 1])  # construct polynomial terms
    for i in range(p):
        aterm = np.ones(m)
        for j in range(n):
            aterm = aterm * X[:, j] ** power[i, j]
        Xmap[:, i + 1] = aterm
    return Xmap

# function that normalizes each predictor
def normalize(X):
    m = np.size(X, 0)
    mu = np.mean(X, 0)           # column mean
    sigma = np.std(X, 0, ddof=1)  # set divisor to be m - 1
    muMat = np.tile(mu, (m, 1))
    sigmaMat = np.tile(sigma, (m, 1))
    Xnorm = np.divide(X - muMat, sigmaMat)
    return Xnorm

# function generating grid based on v of dimension k
def selectk(v, k):
    grid = list(itertools.product(v, repeat=k))
    return np.array(grid)

# function simply computing response
def sigmoid(z):
    g = np.ones(np.size(z)) / (1 + np.exp(- z))
    return g

# load data
datPath = r"C:\xxx\bankruptcy.csv"

# read data from csv file
with open(datPath, 'rb') as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row[1:])  # exclude the first char column, Firm

# get the colnames in the first row and remove it
colNames = datList.pop(0)

# convert list to matrix
data = np.array(datList, dtype="float")

# randomly select 70% data points as training set
nRow = np.size(data, 0)
trainInd = random.sample(range(nRow), int(0.7 * nRow))
testInd = np.ones(nRow, np.bool)
testInd[trainInd] = 0

# set up design matrix, response, and initial guess for training data
X = data[trainInd, 0: 12]
X = lib.normalize(X)           # standardize data column-wise
y = data[trainInd, 12]
m = np.size(X, 0)               # number of rows
n = np.size(X, 1)               # number of columns
X = np.concatenate((np.tile(1, (m, 1)), X), 1)  # add intercept
theta = np.zeros(n + 1)

# set up test set
testX = data[testInd, 0: 12]
testX = lib.normalize(testX)
m = np.size(testX, 0)               # number of rows
testX = np.concatenate((np.tile(1, (m, 1)), testX), 1)  # add intercept
testY = data[testInd, 12]

# No regularization
# Optimization using scipy.optimize.minimize
res1 = minimize(lib.computeCost, theta, args=(X, y, ),jac=lib.cost_grad, options={"maxiter": 5000})

# Accuracy with training set
pred = lib.sigmoid(np.dot(testX, res1.x)) >= 0.5
print("Accuracy: %f\n" % (np.mean(pred == testY) * 100))

# Now use regularization
# set up design matrix again ithout intercept as training set
X = data[trainInd, 0: 12]
X = lib.normalize(X)           # standardize data column-wise

# Mapping to higher dimensional space
X2 = lib.mapping(X, 2)         # rename to avoid overwrite more than onece
theta2 = np.zeros(np.size(X2, 1))

# set up test set
testX = data[testInd, 0: 12]
testX = lib.normalize(testX)   # standardize data column-wise

# Mapping to higher dimensional space
testX2 = lib.mapping(testX, 2)  # rename to avoid overwrite more than onece

lambdad = 0.01

# Optimization using scipy.optimize.minimize
res2 = minimize(lib.computeCost, theta2, args=(X2, y, lambdad, ),jac=lib.cost_grad, options={"maxiter": 5000})

# Compute accuracy on our training set
pred2 = lib.sigmoid(np.dot(testX2, res2.x)) >= 0.5
print("Accuracy: %f\n" % (np.mean(pred2 == testY) * 100))
