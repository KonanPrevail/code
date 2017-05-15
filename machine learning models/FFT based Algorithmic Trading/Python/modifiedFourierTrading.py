# derived from a standard Quantopian algorithm
import numpy
from scipy.fftpack import fft
from scipy.fftpack import ifft

def initialize(context):
    
    #context.security = sid(24) # Apple stock
    #context.security=sid(2119)
    context.security = sid(43721) # SCTY

def handle_data(context, data):
    
    N = 20
    prices = numpy.asarray(history(N, '1d', 'price')) 
    
    # Turn off high frequencies
    wn = 5
    y = fft(numpy.transpose(prices)[0])
    y[wn:-wn] = 0
   
    prec = ifft(y).real
	b = 0
	e = 15
	
    current_rec = numpy.mean(prec[b:e])
    average_rec = numpy.mean(prec) # average of N elements
    ratio = current_rec/average_rec
    
    buy_threshold = 0.99 # Ratio threshold at which to buy
    close_threshold = 1.0  # Ratio threshold at which to close buy position
   
    current_price = data[context.security].price    
    cash = context.portfolio.cash
    
    if ratio < buy_threshold and cash > current_price:
        
        number_of_shares = int(cash/current_price)
        
        order(context.security, +number_of_shares)
        
    elif ratio > close_threshold:
        
        order_target(context.security, 0)
    
    record(stock_price=data[context.security].price)