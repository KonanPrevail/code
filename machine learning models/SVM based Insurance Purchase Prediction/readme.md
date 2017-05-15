<h2>SVM based Insurance Purchase Prediction</h2>

The model was implemented based on a support vector machine classifier.

The target variable y is converted to have values of -1 and 1. Numeric 
variables are selected. The variables are normalized to make sure the 
distance-based measures would not be distorted by the range differences 
etween variables. 60% observations are used for training the SVM classifier, 
the rest is used to test it. Stratified sampling is used. Training data 
are stored in XTrain and yTrain. (XTrain: predictor variables, yTrain: target variable).

The training data is first projected on a selected set of eigenvectors
(which retains the total variance of beta percent), this is implemented
in pca function. The returned XTrain has a smaller number of dimensions
(or columns). XTest is projected using the w transform (formed by the
selected eigenvectors).