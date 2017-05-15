import numpy as np
import csv
import random
import os

def km(X, K, max_iters):
    m, n = X.shape
    centroids = np.random.rand(K, n)
    idx = np.zeros((m, 1))
    idx = idx.astype(int)
    old_idx = np.zeros((m, 1))
    old_idx = old_idx.astype(int)

    for j in range(max_iters):
        change = False
        for i in range(m):
            idx[i] = int(np.argmin(np.sum((np.tile(X[i, :], (K, 1)) - centroids)**2, axis = 1)))
            if (idx[i] != old_idx[i]) and (not change):
                change = True
        for k in range(K):
            k = np.array(k)
            index = np.squeeze(idx == k)
            centroids[k,:] = np.mean(np.squeeze(X[np.where(index), :]), axis = 0)

        if not change:
            break

        old_idx = idx

    return idx

cwd = os.path.dirname(__file__)
with open(r"" + cwd + "/sp500_short_period.csv") as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)

symbols = np.array(datList.pop(0))

data = np.array(datList)
data = data.astype(np.float)
c = np.double((data[1:np.size(data, 0), :] - data[0:np.size(data, 0) - 1, :]) > 0)
movement = np.transpose(c)

K = 10                          # 10 sectors so that 10 classes
max_iters = 1000                # maximum iterations
random.seed(1234)
idx = km(movement, K, max_iters)

for k in range(K):
    print('\nStocks in group %d moving up together\n' % (k+1))
    k = np.array(k)
    index = np.squeeze(idx == k)
    print(symbols[np.where(index)])
