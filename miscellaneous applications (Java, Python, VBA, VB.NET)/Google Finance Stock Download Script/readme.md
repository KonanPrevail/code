<h2>Google Finance Stock Price Download Script</h2>

The Google Finance API can be used to get stock price data for a given
symbol at higher sampling rate than just daily frequency. <br>

Google API examples: YHOO prices from for 15 days with interval of 300 seconds are
requested by: <br>
http://www.google.com/finance/getprices?q=YHOO&i=300&p=15d&f=d,o,h,l,c,v <br>
In which the parameters are:<br>
q= stock symbol<br>
x= exchange symbol, may be omitted, for example the above can be <br>
http://www.google.com/finance/getprices?q=YHOO&x=NASDAQ&i=300&p=15d&f=d,o,h,l,c,v <br>
i = interval (here i=300 means intervals of 100 seconds or 5 minutes)<br>
p = number of period (here 15d denotes 15 days of data)<br>
f = parameters (day, close, open, high and low, volume)<br>

