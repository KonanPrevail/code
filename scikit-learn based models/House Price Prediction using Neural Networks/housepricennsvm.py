#import sys

# clear all variables
#sys.modules[__name__].__dict__.clear()
import pandas as pd
import numpy as np
from sklearn.neural_network import MLPRegressor
from sklearn.svm import SVR
import matplotlib.pyplot as plt
from sklearn.feature_extraction import DictVectorizer
from sklearn.preprocessing import normalize
from sklearn.preprocessing import Imputer

# read data from xls file
trainPath = "train.csv"
testPath = "test.csv"

# load data, remove first row of names, skip first column
train = pd.read_csv(trainPath,delimiter=',')
test = pd.read_csv(testPath,delimiter=',')

# indices of categorical and numeric variables
cat_ind = list(range(2,3))+list(range(5,17))+list(range(19,26))+list(range(27,34))+list(range(35,36))+list(range(39,43))+list(range(53,54))+list(range(55,56))+list(range(57,60))+list(range(60,61))+list(range(63,66))+list(range(72,75))+list(range(77,80))
num_in = list(set(range(1,80))-set(cat_ind))

# Replace nan in LotFrontage and MasVnrArea by the mean
imp = Imputer(missing_values='NaN', strategy='mean', axis=1)
for i in num_in:
    train.iloc[:,i] = np.transpose(imp.fit_transform(train.iloc[:,i]))
    test.iloc[:,i] = np.transpose(imp.fit_transform(test.iloc[:,i]))

# Replace nan in Dataframe as it is confused to NaN, here nan is actually a string value except in LotFrontage and MasVnrArea
train.iloc[:,:] = train.iloc[:,:].replace(np.nan,'nnn')
test.iloc[:,:] = test.iloc[:,:].replace(np.nan,'nnn')

# One Hot Encoder for string data
enc = DictVectorizer(sparse=False) 


# convert Dataframe with selected columns to dictionary as the OneHotEncoder for string values DictVectorizer needs dictionary data
train_dic = train.iloc[:,cat_ind].to_dict(orient = 'records')
test_dic = test.iloc[:,cat_ind].to_dict(orient = 'records')
enc.fit(train_dic)
x_train_categorical = enc.transform(train_dic)
x_test_categorical = enc.transform(test_dic)

# Numerical features
x_train_numeric = train.iloc[:,num_in] 
x_train_numeric = normalize(x_train_numeric)
x_train = np.concatenate((x_train_numeric,x_train_categorical), axis=1)
x_test_numeric = test.iloc[:,num_in] 
x_test_numeric = normalize(x_test_numeric)
x_test = np.concatenate((x_test_numeric,x_test_categorical), axis=1)

# the last is the target/class variable
y_train = train.iloc[:,80] 

m = x_train.shape[0]
n = x_train.shape[1]

# Create and train a decision tree classifier
nnr = MLPRegressor(solver='adam', activation='relu', alpha=10, hidden_layer_sizes=(300,200), random_state=1)
nnr = nnr.fit(x_train, x_train)

# Weights of the NN
weights = nnr.coefs_

# Reduced features
x_train_reduced = np.matmul(x_train,weights[0])
x_test_reduced = np.matmul(x_test,weights[0])

svr = SVR(kernel='poly', C=10, degree=2)
#svr = SVR(kernel='sigmoid', C=10)
svr = svr.fit(x_train_reduced, y_train)

# Predict training and test data
trainpred = svr.predict(x_train_reduced)
# testpred = svr.predict(x_test_reduced)

# Returns the coefficient of determination R^2 of the prediction.
#==============================================================================
# http://scikit-learn.org/stable/modules/generated/sklearn.svm.SVR.html#sklearn.svm.SVR.score
# The coefficient R^2 is defined as (1 - u/v), where u is the regression sum of squares 
# ((y_true - y_pred) ** 2).sum() and v is the residual sum of squares 
# ((y_true - y_true.mean()) ** 2).sum(). Best possible score is 1.0 and it can be negative 
# (because the model can be arbitrarily worse). 
# A constant model that always predicts the expected value of y, 
# disregarding the input features, would get a R^2 score of 0.0
#==============================================================================
score = svr.score(x_train_reduced, y_train)

# Accuracy for training and testing data
print("Training data score: %f\n" % score)
# test_ind = test.iloc[:,0]
# result = pd.DataFrame(np.concatenate((test_ind.as_matrix,testpred),axis=1),columns = ['Id','SalePrice'])

plt.scatter(x_train[:,0], y_train, color='darkorange', label='data', s=0.1)
plt.hold('on')
plt.scatter(x_train[:,0], trainpred, color='navy', label='NN SVM model', s=0.1)
plt.xlabel('data')
plt.ylabel('target')
plt.title('NN SVM Regression')
plt.legend()
plt.show()

