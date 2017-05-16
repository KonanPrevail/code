function AdjClosePrice = getstockfunc(a, b, c, d, e, f, g)
%     
% input: 
% a:               from month,  -1
% b:               from day,    2 digits
% c:               from year,  
% d:               to month,    -1
% e:               to day,      2 digits
% f:               to year     
% g:               d for daily, m for monthly, y for yearly
%
% output: 
% AdjClosePrice:   the adjusted closing price, one column represent one symbol; 
%                  the order of symbols: YHOO, AAPL, GOOG, MSFT, FB, LNKD 
%
%
%read the 6 symbols from excel file named as SymobolList.xlsx
[tmp,s] = xlsread('list.xlsx');

%get the data for each symbol
for i = 1:size(s,1)
    
    %read the data from finance yahoo API
    urllink = sprintf('http://ichart.finance.yahoo.com/table.csv?s=%s&d=%d&e=%d&f=%d&g=%s&a=%d&b=%d&c=%d&ignore=.csv',s{i},d,e,f,g,a,b,c);
    x=urlread(urllink);
    
    %split rows;
    data=strsplit(x, '\n');

    %split each row into 7 columns;
    newdata=[];
    for j = 1:size(data,2)-1
        arow=strsplit(sprintf('%s',data{1,j}),',');
        newdata = [newdata; arow];
    end

    %get the adjusted closing price column
    AdjClosePrice_temp = newdata(:,end);

    %store the adjusted closing price without header as a column for each symbol
    AdjClosePrice(:,i) = str2double(AdjClosePrice_temp(2:end,:));    
end

  
 