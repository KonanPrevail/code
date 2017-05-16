rm(list=ls())
setwd("C://Modeling//Materials")

require(RTextTools)
require(tm)`
require("FactoMineR")
require("MASS")
require(wordcloud)
library(RODBC)

sqlStatement <- "select xls_material_description || ' ' || TRIM(REGEXP_REPLACE(upper(content), '\\d|\\.|%|<|-|\\/|&|,|\\(|\\)|\\*', '')) content from ( 
  select xls_material_description,REGEXP_REPLACE(upper(content), '(^|[ ]*)(TR\\z|TR[^A-Z])', ' TREMOLITE ') content from (
      select xls_material_description,REGEXP_REPLACE(upper(content), '(^|[ ]*)(CR\\z|CR[^A-Z])', ' CROCIDOLITE ') content from (
          select xls_material_description,REGEXP_REPLACE(upper(content), '(^|[ ]*)(AM\\z|AM[^A-Z])', ' AMOSITE ') content from (
              select xls_material_description,REGEXP_REPLACE(upper(content), '(^|[ ]*)(AN\\z|AN[^A-Z])', ' ANTHOPHYLLITE ') content from (
                  select xls_material_description,REGEXP_REPLACE(upper(xls_asbestos_content), '(^|[ ]*)(CH\\z|CH[^A-Z])', ' CHRYSOTILE ') content from assessment)))))"


con <- odbcConnect("xxx", uid="xxx", pwd="xxx", believeNRows=FALSE)
data <- sqlQuery(con, sqlStatement)
corp <- Corpus(VectorSource(data$DESCRIPTION))
close(con)
corpus <- tm_map(corp,stripWhitespace)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus,tolower)
corpus <- tm_map(corpus,removeWords, stopwords("english"))
myStopwords <- c(stopwords('english'), "monthly")
corpus <- tm_map(corpus, removeWords, myStopwords)
dtmc <- DocumentTermMatrix(corpus)
dtmcmax <- as.matrix((dtmc))
fq<-findFreqTerms(dtmc, lowfreq=100)

library(arules)
dtmcreduced<-dtmcmax[,fq];

chrysotile <- apriori(dtmcreduced,  parameter = list(minlen=1,supp = 0.0001, conf = 0.01,target = "rules"),appearance = list(rhs = c("chrysotile"),default="lhs"))
chrysotile.sorted <- sort(chrysotile, by="lift")
inspect(chrysotile.sorted)

amosite<- apriori(dtmcmax,  parameter = list(minlen=1,supp = 0.0001, conf = 0.001,target = "rules"),appearance = list(rhs = c("amosite"),default="lhs"))
amosite.sorted <- sort(amosite, by="lift")
inspect(amosite.sorted)

crocidolite <- apriori(dtmcmax,  parameter = list(minlen=1,supp = 0.0001, conf = 0.001,target = "rules"),appearance = list(rhs = c("crocidolite"),default="lhs"))
crocidolite.sorted <- sort(crocidolite, by="lift")
inspect(crocidolite.sorted)

anthophyllite<- apriori(dtmcmax,  parameter = list(minlen=1,supp = 0.0001, conf = 0.001,target = "rules"),appearance = list(rhs = c("anthophyllite"),default="lhs"))
anthophyllite.sorted <- sort(anthophyllite, by="lift")
inspect(anthophyllite.sorted)

actinolite<- apriori(dtmcmax,  parameter = list(minlen=1,supp = 0.0001, conf = 0.001,target = "rules"),appearance = list(rhs = c("actinolite"),default="lhs"))
actinolite.sorted <- sort(actinolite, by="lift")
inspect(actinolite.sorted)

tremolite<- apriori(dtmcmax,  parameter = list(minlen=1,supp = 0.0001, conf = 0.001,target = "rules"),appearance = list(rhs = c("tremolite"),default="lhs"))
tremolite.sorted <- sort(tremolite, by="lift")
inspect(tremolite.sorted)