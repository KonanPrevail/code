<h2>Google Finance Stock Price Download Script</h2>

The Google Finance API can be used to get stock price data for a given
symbol at higher sampling rate than just daily frequency. 

Google API examples: YHOO prices from for 15 days with interval of 300 seconds are
requested by:
http://www.google.com/finance/getprices?q=YHOO&i=300&p=15d&f=d,o,h,l,c,v
In which the parameters are:
q= stock symbol
x= exchange symbol, may be omitted, for example the above can be
http://www.google.com/finance/getprices?q=YHOO&x=NASDAQ&i=300&p=15d&f=d,o,h,l,c,v
i = interval (here i=300 means intervals of 100 seconds or 5 minutes)
p = number of period (here 15d denotes 15 days of data)
f = parameters (day, close, open, high and low, volume)

