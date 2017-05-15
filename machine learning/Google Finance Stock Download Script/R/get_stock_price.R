rm(list=ls())

getprice<-function(q,i,p,f){
  s1<-'http://www.google.com/finance/getprices?q='
  s2='&i='
  s3='&p='
  s4='&f='
  url<-paste(s1, q, s2, i, s3, p, s4, f, sep = "")
  
  dat<-read.csv(url, header=F)
  df<-data.frame(dat[-c(1,2,3,4,5,6,7),])
  
  return(df)  
}

path="C:/xxx"
setwd(path)

symbol<-read.csv(file="symbols.csv", header=FALSE)
cp<-matrix(data=NA)

for(i in 1:nrow(symbol))
{
  q=symbol[i,1]
  cp[i]<-getprice(q,'300','15d','c')
}

t<-t(symbol)
names(cp)<-t

write.csv(cp,'price.csv')

