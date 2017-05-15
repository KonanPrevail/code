# cleaning
rm(list=ls())

options(error=NULL)

path="c:\\xxx"
setwd(path)

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R","lib"),.libPaths()))
library(SparkR)

sc <- sparkR.init()

lines <- SparkR:::textFile(sc, "morningstar.csv")

ratings <- SparkR:::map(lines, function(x) as.list(strsplit(x, ",")[[1]])[[3]])
result <- SparkR:::countByValue(ratings)

for (i in 1:length(result)) {
  cat("key ", result[[i]][[1]],":",result[[i]][[2]],"\n")
}
	