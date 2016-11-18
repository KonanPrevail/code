from pyspark.ml.feature import HashingTF, IDF, Tokenizer,StopWordsRemover
from pyspark.ml.feature import HashingTF, IDF, Tokenizer
from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.classification import NaiveBayes   
from pyspark.sql import SQLContext, Row
import re

sqlContext = SQLContext(sc)

def cleanhtml(raw_html):
	cleanr = re.compile('<.*?>')
	cleantext = re.sub(cleanr, '', raw_html)
	return cleantext
	
# this is because in the job description, there may be commas inside quotes; you don't have to understand it, but if 
# you want, read about regular expressions
# OTHERWISE, this is not needed, and in the map, there is only map(lambda line: line.split(','))
PATTERN = re.compile(r'''((?:[^,"']|"[^"]*"|'[^']*')+)''')

# here the directory after home is your NetID, first row in clicks: 
# [[u'UserID', u'Date', u'JobID']]
clicks = sc.textFile("file:///home//mcd04005//spark//clicks.tsv").map(lambda line: line.split("\t"))
header = clicks.first() #extract header
clicksRDD = clicks.filter(lambda row: row != header) # filter out the header, check a record by clicksRDD.take(1)

# First row in jobs:
# [[u'JobID', u'WindowID', u'Title', u'Description', u'Requirements', u'City', u'State', u'Country', u'Zip5', u'StartDate', u'EndDate']]
jobs = sc.textFile("file:///home//mcd04005//spark//jobs.tsv").map(lambda line: line.split("\t"))
header = jobs.first() #extract header
jobsRDD = jobs.filter(lambda row: row != header) # filter out the header, check a record by jobsRDD.take(1)

# convert RDD to DataFrame
clicksDF = clicksRDD.toDF() # Check a record by clicksDF.take(1)
jobsDF = jobsRDD.toDF() # Check a record by jobsDF.take(1)

# join 2 DataFrame on JobID, _3 in clicksDF is the jobID column, _1 in jobsDF is the jobID column. Check a record by joinDF.take(1)
joinDF = clicksDF.join(jobsDF, clicksDF._3 == jobsDF._1, "inner")

jobsfeatures = joinDF.map(lambda x: (cleanhtml(x[5] + ' ' + x[6]),x[0])) # concatenate job title and description, the 2nd is click ID
jobsfeaturesDF = sqlContext.createDataFrame(jobsfeatures)
# or jobsfeaturesDF =jobsfeatures.toDF()
# Here if everything went well you see the no more HTML if running the command jobsfeaturesDF.take(1) to get 1 record

# tokenizer to create a "terms" column so for example:
# from _1 we have terms
tokenizer = Tokenizer(inputCol="_1", outputCol="terms")
termsData = tokenizer.transform(jobsfeaturesDF)

# remover to remove stop words that don't contribute so for example
# from terms we have filtered
remover = StopWordsRemover(inputCol="terms", outputCol="filtered")
filteredTermsData = remover.transform(termsData)

# http://spark.apache.org/docs/latest/ml-features.html
# Both HashingTF and CountVectorizer can be used to generate the term frequency vectors.
# HashingTF is a Transformer which takes sets of terms and converts those sets into fixed-length feature vectors. In text processing, a “set of terms” might # be a bag of words. HashingTF utilizes the hashing trick. 
# so from filtered we have rawFeatures
tf = HashingTF(inputCol="filtered", outputCol="rawFeatures").transform(filteredTermsData)

# IDF: IDF is an Estimator which is fit on a dataset and produces an IDFModel. The IDFModel takes feature vectors (generally created from HashingTF or 
# CountVectorizer) and scales each column. Intuitively, it down-weights columns which appear frequently in a corpus.
idf = IDF(inputCol="rawFeatures", outputCol="features").fit(tf)

# TF-IDF. Use tfidf.take(1) to see the 1st record
tfidf = idf.transform(tf)









