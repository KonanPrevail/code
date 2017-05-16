#!/usr/bin/python3

# import other modules needed, install them if cannot found
import csv
import numpy as np
# from scipy.fftpack import rfft, irfft, fftfreq, fft, ifft
import numpy.fft as f
import matplotlib.pyplot as plt

datPath = "sp500_short_period.csv"

# read data from csv file
with open(datPath) as csvfile:
    csvData = csv.reader(csvfile)
    datList = []
    for row in csvData:
        datList.append(row)

# get the colnames in the first row and remove it
symbols = np.array(datList.pop(0))

# convert list to matrix
data = np.array(datList)
data = data.astype(np.float)

n = np.size(data,0)
T = 24*60*60 # measured every 15 minutes
Fs = 1.0/T # Hz
ls = range(len(data)) # data contains the function

vars = 1
for i in range(vars):
    freq = f.fftfreq(n, d = T)
    spect = f.fft(data[:,i])
    wn = 10

    spect[wn:-wn] = 0
    
    recovered = f.ifft(spect).real
    
    plt.figure()
    plt.plot(data[:,i],"r",label = "Original price")
    plt.plot(recovered,'b', label = "Recovered price")
    plt.title("Original and reconstructed stock prices for symbol " + symbols[i])
    plt.xlabel("Days")
    plt.ylabel("Price")
    plt.legend()
    
    
    

