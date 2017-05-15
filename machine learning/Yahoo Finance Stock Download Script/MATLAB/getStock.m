clc;close all; clear
%set up the parameters to retrieve the data from Yahoo Financial API
a=3;    %from month-1;
b=13;   %from day;
c=2014; %from year;
d=10;    %to month-1;
e=28;   %to day;
f=2015; %to year;
g='d';  %daily prices;


%get the adjusted closing price using the function
data = getstockfunc(a, b, c, d, e, f, g);

%save it to an excel file
filename = 'price.xlsx';
xlswrite(filename, data);
