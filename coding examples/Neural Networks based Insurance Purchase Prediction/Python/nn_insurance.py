import nn_insurance_lib as lib
import csv
import numpy as np
import math
from scipy.optimize import minimize

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
X = lib.normalize(X)
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
res2 = minimize(lib.computeCost, theta,
                args=(input_num, hidden_num, label_num, XTrain, yTrain, lamba),
                jac=lib.cost_grad, options={"maxiter": 50})

theta1 = res2.x[0:hidden_num * (1 + input_num)]
theta2 = res2.x[hidden_num * (1 + input_num):len(theta)]
Theta1 = theta1.reshape(hidden_num, 1 + input_num, order="F")
Theta2 = theta2.reshape(label_num, 1 + hidden_num, order="F")

predTrain = lib.predict(Theta1, Theta2, XTrain)
print('Training set Accuracy: %f\n' % (np.mean(predTrain == yTrain)*100))
predTest = lib.predict(Theta1, Theta2, XTest)
print('Test set Accuracy: %f\n' % (np.mean(predTest == yTest)*100))
