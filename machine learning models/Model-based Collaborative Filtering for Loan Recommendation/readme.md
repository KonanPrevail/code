You are modeling a recommender system for a lending club platform using
model-based Collaborative Filtering (vs memory-based approach computing
similarities between users and items to give recommendations using
rating data).

The model-based CF is a latent factor model, more robust than the
memory-based approach, and handles sparsity better. Consider a sparse
rating matrix of which the elements are ratings given by lender j to
loan i. The rating matrix is modeled by a matrix product of X
(loan-feature matrix) and Ө (user-feature matrix) (see the figure). Each
rating given by lender j to loan i is an inner product of row i in X and
column j in Ө:

$${rating(i,j) = \theta^{j}}^{T}x^{i}$$

The matrix form is as follows:

$$rating = X*\theta^{T}$$

![](media/image1.png){width="4.46875in" height="1.925in"}

The recommender system model helps estimate the missing ratings and
recommends good loans to the lenders. The function costFunction()
computes the regularized cost function as follows:

$$J\left( {\theta^{(1)}\theta^{(2)}\ldots\theta}^{(j)}\ldots\theta^{\left( n_{\text{lender}} \right)},x^{(1)},x^{(2)},\ldots,x^{\left( i \right)},\ldots,x^{(n_{\text{loan}})} \right) = \frac{1}{2}\left\lbrack \sum_{i = 1}^{n_{\text{loan}}}{\sum_{j:r(i,j) = 1}^{}\left( {\theta^{(j)}}^{T}x^{(i)} - y^{(i,j)} \right)^{2}} \right\rbrack + \frac{\lambda}{2}\sum_{i = 1}^{n_{\text{loan}}}{\sum_{k = 1}^{n_{c}}\left( {x_{k}}^{(i)} \right)^{2}} + \frac{\lambda}{2}\sum_{j = 1}^{n_{\text{lender}}}{\sum_{k = 1}^{n_{c}}\left( {\theta_{k}}^{(j)} \right)^{2}}$$

In which the last 2 terms are the regularization terms. And the gradient
of the cost function

$$\frac{\partial}{\partial{x_{k}}^{(i)}}J\left( {\theta^{(1)}\theta^{(2)}\ldots\theta}^{(j)}\ldots\theta^{\left( n_{\text{lender}} \right)},x^{(1)},x^{(2)},\ldots,x^{\left( i \right)},\ldots,x^{(n_{\text{loan}})} \right) = \sum_{j:r(i,j) = 1}^{}\left( {\theta^{(j)}}^{T}x^{(i)} - y^{(i,j)} \right){\theta_{k}}^{(j)} + {{\lambda x}_{k}}^{(i)}$$

$$\frac{\partial}{\partial{\theta_{k}}^{(j)}}J\left( {\theta^{(1)}\theta^{(2)}\ldots\theta}^{(j)}\ldots\theta^{\left( n_{\text{lender}} \right)},x^{(1)},x^{(2)},\ldots,x^{\left( i \right)},\ldots,x^{(n_{\text{loan}})} \right) = \sum_{i:r(i,j) = 1}^{}\left( {\theta^{(j)}}^{T}x^{(i)} - y^{(i,j)} \right){x_{k}}^{(i)} + {{\lambda\theta}_{k}}^{(j)}$$

In the code of costFunction function, X and θ are extracted from the
parameter vector namely params. X has features/variables on its columns,
and θ has the lenders’ preference on it columns. The gradient terms are
stored in the variables grad and returned to the calling function. optimizeCost 
function searches for the optimal parameter vector
using gradient descent.

In the data there are 10 lenders and a large number of loans, in which
many were rated by the lenders with ratings from 1-10 (in practice there
are many lenders, who invest). The ones that are not rated yet have
ratings of 0.

Running with top 3 recommendations for lender 1 would output something
like

Top 3 recommendations for lender 1:

Predicted rating 6.8 for loan of 5000.0 for 36 months with credit card
purpose at 10.7 percent interest

Predicted rating 6.6 for loan of 2500.0 for 60 months with car purpose
at 15.3 percent interest

Predicted rating 6.1 for loan of 2400.0 for 36 months with small
business purpose at 16.0 percent interest
