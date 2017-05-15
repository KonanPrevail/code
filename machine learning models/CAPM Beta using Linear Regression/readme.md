<h2>CAPM Beta Computation using Linear Regression</h2>

This model applies gradient decent to compute beta of
securities following CAPM model (see the MATLAB link at the bottom):

> *R(k,i) = a(i) + C(k) + b(i) \* (M(k) - C(k)) + V(k,i)*

for samples k = 1, ... , m and assets i = 1, ... , n, where a(i) is a
parameter that specifies the non-systematic return of an asset i, b(i)
is the asset beta of the asset i, and V(k,i) is the residual error for
asset i with associated random variable V(i). Asset alphas a(1), ... ,
a(n) are zeros in strict form of CAPM but non-zeros in practice. C(k) is
sample k of the risk-free asset return.

The dataset CAPMuniverse contains the daily total return data from
03-Jan-2000 to 07-Nov-2005 for 12 stocks as follows: 'AAPL', 'AMZN',
'CSCO', 'DELL', 'EBAY', 'GOOG', 'HPQ', 'IBM', 'INTC', 'MSFT', 'ORCL',
'YHOO'. Columns 14 and 15 are daily return data for the market, and the
risk-free rate. More information regarding the dataset is copied at the
bottom of the page. You will use regression to find the betas of these
securities (another way is to use the normal equation to get the
analytical solution).
