import urllib.request as urllib2
import csv
import numpy as np
import pandas as pd

filepath = 'c:/xxx/'

def getStockPrice(q, i = '300', p='15d', f='c'):
    # q: stock symbol
    # i: initerval
    # p: number of period
    # f: parameters
    url = "http://www.google.com/finance/getprices?q="+q+"&i="+i+"&p="+p+"&f="+f
    response = urllib2.urlopen(url)
    data = response.read().decode('utf-8').split('\n')
    a = data[7:len(data)]
    return a 

stocknames = pd.read_csv(filepath + "SymbolList.csv",header=None)

output = []
index = []

for i in range(0,len(stocknames)):
    ttl = stocknames[0][i]
    output1 = getStockPrice(q = ttl)
    output.append(output1) 
    index.append(ttl)

outprice = pd.DataFrame(output, index)
outprice = outprice.transpose()
outprice.to_csv(filepath + "results.csv", encoding='utf-8')

