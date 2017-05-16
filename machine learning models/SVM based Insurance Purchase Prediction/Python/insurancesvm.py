import svm_insurance_lib as lib
import csv
import numpy as np
import math
import cvxopt as opt
from cvxopt import matrix, solvers

# function that normalizes each predictor
def normalize(X):
    m = np.size(X, 0)
    # n = np.size(X, 1)
    maxval = np.max(X, 0)
    minval = np.min(X, 0)
    minMat = np.tile(minval, (m, 1))
    DifMat = np.tile(maxval, (m, 1)) - minMat
    Xnorm = np.divide(X - minMat, DifMat)
    return Xnorm

def pca(X, alpha):
    n = np.size(X, 1)
    covm = np.cov(X, rowvar = False)
    eig_val, eig_vec = np.linalg.eig(covm)   
    val = np.sort(eig_val)[::-1]
    loc = val.argsort()[::-1]
    if alpha >= 1:
        k = alpha
    else:
        k = np.sum(np.array(np.cumsum(val)/np.sum(val) <= alpha).astype(int))
        if k == 0:
            k=1
    E = eig_vec[:, loc]
    w = E[:, 0:k]
    length = np.sqrt(np.sum(w**2, axis=0))
    w = np.divide(w, np.dot(np.ones(n)[:, None], length.T[None,:]))
    return w
    
def kernel(XTest, XTrain, sigma, type):
    if type == 0:
        K = np.dot(XTest, XTrain.T)
    else:
        X1 = np.sum(XTest**2, axis = 1)
        X2 = np.sum(XTrain**2, axis = 1)
        foo1 = np.dot(np.ones(np.size(XTest, axis=0))[:, None], X2.T[None,:]) \
                      - 2 * np.dot(XTest, XTrain.T)
        K = np.dot(X1[:,None], np.ones(np.size(XTrain, axis=0)).T[None,:]) \
                   + foo1
        K = np.exp(-K/(2*sigma))
    return K   
        
# read data from csv file
datPath = r"C:\xxx\insurance.csv"
with open(datPath,'rb') as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)
        
# get the colnames in the first row and remove it
colNames = datList.pop(0)

# convert list to matrix
data = np.array(datList)

# insurance data set
y = np.array(data[:, 30], "str")

# index of X selected
idx = np.array([i for j in (range(7, 14), range(15, 29)) for i in j])
X = np.array(data[:, idx], "float")

# normalize X
X = lib.normalize(X)
m = np.size(X, 0)
n = np.size(X, 1)

# y is a 1d array
y = np.array([{"Yes": 1, "No": -1}[y[i]] for i in range(len(y))])

# Stratified sampling
train_pc = 0.7
size1 = math.floor(train_pc*sum(y == -1))
size2 = math.floor(train_pc*sum(y == 1))
idxY1 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == -1]
idxY2 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == 1]
B1train = np.concatenate((np.random.choice(idxY1, size1, False),
                          (np.random.choice(idxY2, size2, False))), axis=0)
yTrain = y[B1train]
yTest = np.delete(y, B1train, axis=0)
XTrain = X[B1train, :]
XTest = np.delete(X, B1train, axis=0)
TrainSize = np.size(XTrain, axis = 0)

# New representation of the training and test data sets
# reduce the X dimensions 
beta = 0.95
W = lib.pca(XTrain, beta)
XTrain = np.dot(XTrain, W)
XTest = np.dot(XTest, W)

# Gaussian Kernel
sigma = 0.1
K = lib.kernel(XTrain, XTrain, sigma, 0)
a0 = 2.0 * np.spacing(1) * np.ones(TrainSize)

# Inequality that individual alpha>=0
C = 1e+20
G = matrix(np.concatenate((-np.eye(TrainSize), np.eye(TrainSize)), axis = 0))
h = matrix(np.concatenate((np.zeros(TrainSize), C * np.ones(TrainSize)), axis = 0))

# Equality that sum(alpha_i*y_i)=0
A = opt.matrix(np.double(yTrain))
b = matrix(0.0)

# Change from min to max optimization by multiplying with -1
# Regularization term to force H positive definite
yTmat = np.diag(np.double(yTrain))
P = 0.5 * np.dot(yTmat, np.dot(K, yTmat)) + 1e-10 * np.identity(TrainSize)
q = opt.matrix(-np.ones((TrainSize,1)))

opts = {'abstol':1e-5, 'reltol':1e-5, 'maxiters':45}
sol = solvers.qp(matrix(P), q, G, h, A.T, b, initvals = a0, options=opts)
alpha = np.array(sol['x'])

b = np.mean(yTrain - np.dot(K, (np.multiply(alpha, yTrain))))
K1 = lib.kernel(XTest, XTrain, sigma, 0)
pred = np.sign(np.dot((1 + K1)**2, np.multiply(alpha.T, yTrain).T) + b)
print('Test accuracy: %f\n' % (np.mean(pred == yTest)*100))

K2 = lib.kernel(XTrain, XTrain, sigma, 0)
pred = np.sign(np.dot((1 + K2)**2, np.multiply(alpha.T, yTrain).T) + b)
print('Training accuracy: %f\n' % (np.mean(pred == yTrain)*100))
