import csv
import numpy as np
import math
from scipy.optimize import minimize

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

# function that return sigmoid of z
def sigmoid(z):
    g = 1 / (1 + np.exp(-z))
    return g

def gradient(z):
    g1 = np.column_stack((np.ones(np.size(z, 0)), sigmoid(z)))
    g2 = np.column_stack((np.ones(np.size(z, 0)), (1 - sigmoid(z))))
    g = np.multiply(g1, g2)
    return g

# cost function
def computeCost(theta, input_num, hidden_num, label_num, X, y, lamba):
    theta1 = theta[0:hidden_num * (1 + input_num)]
    theta2 = theta[hidden_num * (1 + input_num):len(theta)]
    Theta1 = theta1.reshape(hidden_num, 1 + input_num, order="F")
    Theta2 = theta2.reshape(label_num, 1 + hidden_num, order="F")
    m = np.size(X, 0)
    # convert the labels,1 to 10,2 to 01
    I = np.eye(2)
    Y = I[y - 1, :]

    A1 = np.column_stack((np.ones(m), X))
    Z2 = np.dot(A1, Theta1.T)
    A2 = np.column_stack((np.ones(np.size(Z2, 0)), sigmoid(Z2)))
    Z3 = np.dot(A2, Theta2.T)
    H = sigmoid(Z3)
    # A3 = H                      # never used

    # Feedforward & cost function
    J = np.sum(np.multiply(- Y, np.log(H)) +
               np.multiply(- (1 - Y), np.log(1 - H))) / m

    # Regularization
    reg = (lamba / (2*m)) * (np.sum(Theta1[:, 1:np.size(Theta1, 1)]**2) +
                             np.sum(Theta2[:, 1:np.size(Theta2, 1)]**2))

    J = J + reg
    return J

# cost function
def cost_grad(theta, input_num, hidden_num, label_num, X, y, lamba):
    theta1 = theta[0:hidden_num * (1 + input_num)]
    theta2 = theta[hidden_num * (1 + input_num):len(theta)]
    Theta1 = theta1.reshape(hidden_num, 1 + input_num, order="F")
    Theta2 = theta2.reshape(label_num, 1 + hidden_num, order="F")
    m = np.size(X, 0)
    # convert the labels,1 to 10,2 to 01
    I = np.eye(2)
    Y = I[y - 1, :]

    A1 = np.column_stack((np.ones(m), X))
    Z2 = np.dot(A1, Theta1.T)
    A2 = np.column_stack((np.ones(np.size(Z2, 0)), sigmoid(Z2)))
    Z3 = np.dot(A2, Theta2.T)
    H = sigmoid(Z3)
    A3 = H

    # Backpropagation & Big deltas
    delta3 = A3 - Y
    delta2 = np.multiply(np.dot(delta3, Theta2), gradient(Z2))
    delta2 = delta2[:, 1:np.size(delta2, 1)]

    # Accumulate gradients
    BigDelta1 = np.dot(delta2.T, A1)
    BigDelta2 = np.dot(delta3.T, A2)

    # Regularized Gradient
    Theta1_grad = BigDelta1 / m + (lamba / m) *\
        np.column_stack((np.zeros(np.size(Theta1, 0)),
                         Theta1[:, 1:np.size(Theta1, 1)]))

    Theta2_grad = BigDelta2 / m + (lamba / m) *\
        np.column_stack((np.zeros(np.size(Theta2, 0)),
                         Theta2[:, 1:np.size(Theta2, 1)]))

    grad = np.concatenate(
        (Theta1_grad.reshape(hidden_num * (1 + input_num), 1, order="F"),
         Theta2_grad.reshape(label_num * (1 + hidden_num), 1, order="F")),
        axis=0)
    grad = np.squeeze(grad)
    return grad


def predict(Theta1, Theta2, X):
    m = np.size(X, 0)
    h1 = sigmoid(np.dot(np.column_stack((np.ones(m), X)), Theta1.T))
    h2 = sigmoid(np.dot(np.column_stack((np.ones(m), h1)), Theta2.T))
    pred = np.argmax(h2, 1) + 1
    return pred

	
# read data from csv file
datPath = r"C:\xxx\insurance.csv"
with open(datPath, 'rb') as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)

# get the colnames in the first row and remove it
colNames = datList.pop(0)

# convert list to matrix
data = np.array(datList)

# setting up
input_num = 21
hidden_num = 100
label_num = 2
train_pc = 0.66

# insurance data set
y = np.array(data[:, 30], "str")

# index of X selected
idx = np.array([i for j in (range(7, 14), range(15, 29)) for i in j])
X = np.array(data[:, idx], "float")

# normalize X
X = normalize(X)
m = np.size(X, 0)
n = np.size(X, 1)

# y is a 1d array
y = np.array([{"Yes": 2, "No": 1}[y[i]] for i in range(len(y))])

# Stratified sampling
size1 = math.floor(train_pc*sum(y == 1))
size2 = math.floor(train_pc*sum(y == 2))
idxY1 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == 1]
idxY2 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == 2]
B1train = np.concatenate((np.random.choice(idxY1, size1, False),
                          (np.random.choice(idxY2, size2, False))), axis=0)
yTrain = y[B1train]
yTest = np.delete(y, B1train, axis=0)
XTrain = X[B1train, :]
XTest = np.delete(X, B1train, axis=0)

# lambda and initial value
lamba = 0.05
epsilon = 0.1
Theta1 = np.random.rand(hidden_num, 1 + input_num) * 2 * epsilon - epsilon
Theta2 = np.random.rand(label_num, 1 + hidden_num) * 2 * epsilon - epsilon
theta = np.concatenate(
    (Theta1.reshape(hidden_num * (1 + input_num), 1, order="F"),
     Theta2.reshape(label_num * (1 + hidden_num), 1, order="F")))
theta = np.squeeze(theta)

# Optimization using scipy.optimize.minimize
res2 = minimize(computeCost, theta,
                args=(input_num, hidden_num, label_num, XTrain, yTrain, lamba),
                jac=cost_grad, options={"maxiter": 50})

theta1 = res2.x[0:hidden_num * (1 + input_num)]
theta2 = res2.x[hidden_num * (1 + input_num):len(theta)]
Theta1 = theta1.reshape(hidden_num, 1 + input_num, order="F")
Theta2 = theta2.reshape(label_num, 1 + hidden_num, order="F")

predTrain = predict(Theta1, Theta2, XTrain)
print('Training set Accuracy: %f\n' % (np.mean(predTrain == yTrain)*100))
predTest = predict(Theta1, Theta2, XTest)
print('Test set Accuracy: %f\n' % (np.mean(predTest == yTest)*100))
