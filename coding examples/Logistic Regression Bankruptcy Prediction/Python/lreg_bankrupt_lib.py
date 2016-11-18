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
