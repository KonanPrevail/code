from pyspark.ml.feature import HashingTF, IDF, Tokenizer,StopWordsRemover
from pyspark.ml.feature import HashingTF, IDF, Tokenizer
from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.classification import NaiveBayes   
from pyspark.sql import SQLContext, Row
import re

sqlContext = SQLContext(sc)

# this is because in the job description, there may be commas inside quotes; you don't have to understand it, but if 
# you want, read about regular expressions
PATTERN = re.compile(r'''((?:[^,"']|"[^"]*"|'[^']*')+)''')

# here the directory after home is your NetID
# jobs = sc.textFile("file:///home//xxxx//spark//data.csv").map(lambda line: line.split(","))
jobs = sc.textFile("xxx/data_sub.csv").map(lambda line: PATTERN.split(line)[1::2])
header = jobs.first() #extract header
data = jobs.filter(lambda row: row != header) # filter out the header

# convert RDD to DataFrame
dataDF = data.toDF()

jobsfeatures = data.map(lambda x: (x[1] + ' ' + x[2],x[5])) # concatenate job title and description, the 2nd is contract term
jobsfeaturesDF = sqlContext.createDataFrame(jobsfeatures)

jobsfeaturesDF =jobsfeatures.toDF()
# tokenizer to create a "terms" column so for example:
# from content=u'We start learning Spark'  we have terms=[u'we', u'start', u'learning', u'spark']
tokenizer = Tokenizer(inputCol="_1", outputCol="terms")
termsData = tokenizer.transform(jobsfeaturesDF)

# remover to remove stop words that don't contribute so for example
# from terms=[u'we', u'start', u'learning', u'spark'] we have filtered=[u'start', u'learning', u'spark']
remover = StopWordsRemover(inputCol="terms", outputCol="filtered")
filteredTermsData = remover.transform(termsData)

# http://spark.apache.org/docs/latest/ml-features.html
# Both HashingTF and CountVectorizer can be used to generate the term frequency vectors.
# HashingTF is a Transformer which takes sets of terms and converts those sets into fixed-length feature vectors. In text processing, a “set of terms” might # be a bag of words. HashingTF utilizes the hashing trick. 
# so from filtered=[u'start', u'learning', u'spark'] we have rawFeatures=SparseVector(262144, {29470: 1.0, 62173: 1.0, 181346: 1.0})
tf = HashingTF(inputCol="filtered", outputCol="rawFeatures").transform(filteredTermsData)

# IDF: IDF is an Estimator which is fit on a dataset and produces an IDFModel. The IDFModel takes feature vectors (generally created from HashingTF or 
# CountVectorizer) and scales each column. Intuitively, it down-weights columns which appear frequently in a corpus.
idf = IDF(inputCol="rawFeatures", outputCol="features").fit(tf)

# TF-IDF
tfidf = idf.transform(tf)

# [Row(_1=u'Engineering Systems Analyst "Engineering Systems Analyst Dorking Surrey Salary ****K Our client is located in Dorking, Surrey and are looking for Engineering Systems Analyst our client provides specialist software development Keywords Mathematical Modelling, Risk Analysis, System Modelling, Optimisation, MISER, PIONEEER Engineering Systems Analyst Dorking Surrey Salary ****K"', _2=u'permanent', terms=[u'engineering', u'systems', u'analyst', u'"engineering', u'systems', u'analyst', u'dorking', u'surrey', u'salary', u'****k', u'our', u'client', u'is', u'located', u'in', u'dorking,', u'surrey', u'and', u'are', u'looking', u'for', u'engineering', u'systems', u'analyst', u'our', u'client', u'provides', u'specialist', u'software', u'development', u'keywords', u'mathematical', u'modelling,', u'risk', u'analysis,', u'system', u'modelling,', u'optimisation,', u'miser,', u'pioneeer', u'engineering', u'systems', u'analyst', u'dorking', u'surrey', u'salary', u'****k"'], filtered=[u'engineering', u'systems', u'analyst', u'"engineering', u'systems', u'analyst', u'dorking', u'surrey', u'salary', u'****k', u'client', u'located', u'dorking,', u'surrey', u'looking', u'engineering', u'systems', u'analyst', u'client', u'provides', u'specialist', u'software', u'development', u'keywords', u'mathematical', u'modelling,', u'risk', u'analysis,', u'modelling,', u'optimisation,', u'miser,', u'pioneeer', u'engineering', u'systems', u'analyst', u'dorking', u'surrey', u'salary', u'****k"'], rawFeatures=SparseVector(262144, {1522: 1.0, 28977: 1.0, 50609: 1.0, 53011: 3.0, 88291: 1.0, 91877: 1.0, 92879: 1.0, 105787: 1.0, 110440: 1.0, 116062: 2.0, 119844: 4.0, 130456: 1.0, 141520: 1.0, 171946: 1.0, 182730: 2.0, 189805: 2.0, 190094: 1.0, 193483: 2.0, 206743: 1.0, 220290: 4.0, 221607: 1.0, 221992: 1.0, 234987: 1.0, 235606: 3.0, 252754: 1.0}), features=SparseVector(262144, {1522: 2.4423, 28977: 2.817, 50609: 3.8286, 53011: 4.5041, 88291: 0.7151, 91877: 4.5218, 92879: 3.0177, 105787: 1.1896, 110440: 4.1163, 116062: 7.211, 119844: 8.4956, 130456: 4.1163, 141520: 3.4232, 171946: 3.4232, 182730: 2.1121, 189805: 6.8464, 190094: 3.8286, 193483: 1.3012, 206743: 3.8286, 220290: 13.6927, 221607: 2.2192, 221992: 2.9124, 234987: 2.1239, 235606: 8.7371, 252754: 2.1704}))]







