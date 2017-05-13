<h2>Kmeans Up-Down Stock Movement Clustering</h2>

The given dataset contains the closing stock prices for S&P500 stocks
for a period of time. Their symbols show on the column headers. The
companies operate in 10 sectors as follows (from SP500Companies.xls):

  Health Care</br>
  Financials</br>
  Information Technology</br>
  Industrials</br>
  Utilities</br>
  Materials</br>
  Consumer Staples</br>
  Consumer Discretionary</br>
  Energy</br>
  Telecommunications Services</br>

In the preprocessing step, a new data set is created to indicate if the
stock prices increase compared with the previous day (1 or 0
corresponding to UP or DOWN). The matrix is then transposed such that
the up/down movement of a stock is in in a row. The model clusters
rows/points in a number of clusters. Here the number of clusters is
chosen to be 10 to see if the stocks (or most of) of companies operating
in the same sectors happen to be grouped together.

The km function implements the K-means algorithm. The outer loop loops
for a number of max iterations. The first inner loop assigns each
example/point to a cluster. The second loop re-computes the centroids of
the clusters.


