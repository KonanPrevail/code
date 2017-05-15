<h2>Neural Networks based Insurance Purchase Prediction</h2>
The computeCost function takes the data set X, for each
example/observation in X, does the following (Here L = 3 indicating 3
layers):

a\. First the labels are converted:

“1”, which is “No” is converted to a vector of \[1,0\]; and “2”, which
is “Yes” is converted to \[0,1\] using the identity matrix trick. The
new labels are stored in the variable Y.

b\. Forward propagation

c\. Compute the regularized cost function

d\. Back-propagation

e\. And compute the gradient of the cost function

The cost and the gradient of the cost are then stored in the variables J
and grad.

A1: contains multiple a^(1)^ on its rows (after adding the bias value),
each is corresponding to an example/observation

A2: contains multiple a^(2)^ on its rows (after adding the bias value),
each is corresponding to an example/observation

A3: contains multiple a^(3)^ on its rows, each is corresponding to an
example/observation. Note that A3 is also H.

Z2: contains multiple z^(2)^ on its rows, each is corresponding to an
example/observation.

Z3: contains multiple z^(3)^ on its rows, each is corresponding to an
example/observation.

delta3, delta2, BigDelta1, BigDelta2 are matrix implementation of the
corresponding variables in the pseudo-code.

The normalize function is used to normalize the features/variables in X.
The predict function is to predict if a customer would buy insurance
given X. The prediction is stored in pred and returned to the main code.
Others include sigmoid, and gradient.

