#!/usr/bin/python3

# import modules needed
import numpy as np

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

def pca(X, alpha):
    n = np.size(X, 1)
    covm = np.cov(X, rowvar = False)
    eig_val, eig_vec = np.linalg.eig(covm)   
    val = np.sort(eig_val)[::-1]
    loc = val.argsort()[::-1]
    if alpha >= 1:
        k = alpha
    else:
        k = np.sum(np.array(np.cumsum(val)/np.sum(val) <= alpha).astype(int))
        if k == 0:
            k=1
    E = eig_vec[:, loc]
    w = E[:, 0:k]
    length = np.sqrt(np.sum(w**2, axis=0))
    w = np.divide(w, np.dot(np.ones(n)[:, None], length.T[None,:]))
    return w
    
def kernel(XTest, XTrain, sigma, type):
    if type == 0:
        K = np.dot(XTest, XTrain.T)
    else:
        X1 = np.sum(XTest**2, axis = 1)
        X2 = np.sum(XTrain**2, axis = 1)
        foo1 = np.dot(np.ones(np.size(XTest, axis=0))[:, None], X2.T[None,:]) \
                      - 2 * np.dot(XTest, XTrain.T)
        K = np.dot(X1[:,None], np.ones(np.size(XTrain, axis=0)).T[None,:]) \
                   + foo1
        K = np.exp(-K/(2*sigma))
    return K   
        
        
        
 
        
        
        
        
        
        