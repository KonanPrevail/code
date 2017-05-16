#import sys

# clear all variables
#sys.modules[__name__].__dict__.clear()
import pandas as pd
import numpy as np
import math
from sklearn.neural_network import MLPClassifier
import matplotlib.pyplot as plt

# this percentage of data is used for training the model
train_pc = 0.7

# read data from xls file
datPath = "creditcard.csv"

# load data, remove first row of names, skip first column
data = pd.read_csv(datPath,delimiter=',')

# 29 variables are used for modeling
x = data.iloc[:,1:29]

# the last is the target/class variable
y = data.iloc[:,30] 

m = x.shape[0]
n = x.shape[1]

# Stratified sampling: take train_pc percent from both classes (simple sampling would give worse result)
size1 = int(math.floor(train_pc * sum(y == 0)))
size2 = int(math.floor(train_pc * sum(y == 1)))
indY1 = np.where(y == 0)[0]
indY2 = np.where(y == 1)[0]

np.random.seed(1234) # to reproduce the same training/test data each time we sample data
# Indices of instances that are used for training
# Note that the dataset is much imbalanced, so we add more/sample with replacement from the same data to make the number of instances in both classes equal
train_ind = np.concatenate((np.random.choice(indY1, size1, False),
                          np.random.choice(np.random.choice(indY2, size2, False), size1, True)), axis=0)
yTrain = y[train_ind]
test_ind = np.setdiff1d(range(m),train_ind)
yTest = y[test_ind]

# Create training and test datasets
xTrain = x.loc[train_ind, :]
xTest = x.loc[test_ind, :]

# Create and train a decision tree classifier
clf = MLPClassifier(solver='lbfgs', alpha=10, hidden_layer_sizes=(40, 40, 40), random_state=1)
clf = clf.fit(xTrain, yTrain)

# Classify training and test data
trainpred = clf.predict(xTrain)
testpred = clf.predict(xTest)

# Accuracy for training and testing data
print("Train Accuracy: %f\n" % (np.mean(yTrain == trainpred) * 100))
print("Test Accuracy: %f\n" % (np.mean(yTest == testpred) * 100))

# Confusion matrix, how many instances are classified correctly (1->1, 0->0), and missclassified (0->1, 1->0)
pd.crosstab(yTest,testpred, rownames=['Actual Class'], colnames=['Predicted Class'])

# Now plot the decision boundary and training points using 2 most important variables
n_classes = 2
plot_colors = "br" # blue and red
plot_step = 0.02

selX1 = xTrain['V4']
selX2 = xTrain['V14']

# Train using 2 variables for plotting
clf = MLPClassifier(solver='lbfgs', alpha=1e-5, hidden_layer_sizes=(5, 2), random_state=1)
clf = clf.fit(xTrain[['V4','V14']], yTrain)

x_min, x_max = selX1.min() - 1, selX1.max() + 1
y_min, y_max = selX2.min() - 1, selX2.max() + 1
xx, yy = np.meshgrid(np.arange(x_min, x_max, plot_step), np.arange(y_min, y_max, plot_step))

# ravel: Return a contiguous flattened array.
Z = clf.predict(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)
plt.contourf(xx, yy, Z, cmap=plt.cm.Paired)

plt.xlabel('V4')
plt.ylabel('V14')
plt.axis("tight")

# Plot the training points
for i, color in zip(range(n_classes), plot_colors):
    idx = np.where(yTrain == i)
    plt.scatter(selX1.iloc[idx], selX2.iloc[idx], c=color, label=yTrain.iloc[idx].as_matrix()[:1],cmap=plt.cm.Paired)

plt.title("Decision surface of a neural network using paired features")
plt.legend()
plt.show()