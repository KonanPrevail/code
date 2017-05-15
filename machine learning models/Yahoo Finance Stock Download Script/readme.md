<h2>Yahoo Finance Stock Download Script</h2>

This script helps download stock price from Yahoo Finance.
The API can be used to returns stock price data for a given 
symbol. In this example, YHOO daily price from 4/13/2009 to
1/28/2010 is requested.<br>

http://ichart.finance.yahoo.com/table.csv?s=YHOO&d=0&e=28&f=2010&g=d&a=3&b=13&c=2009&ignore=.csv<br>

The details of the parameters are as follows:<br>

  s   Ticker symbol (YHOO in the example)<br>
  --- --------------------------------------<br>
  a   The "from month"ù - 1
  b   The "from day"ù (two digits)
  c   The "from year"ù
  d   The "to month"ù - 1
  e   The "to day"ù (two digits)
  f   The "to year"ù
  g   d for day, m for month, y for yearly

