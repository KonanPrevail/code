# Read some about dense and sparse format
# https://databricks.com/blog/2014/07/16/new-features-in-mllib-in-spark-1-0.html
from pyspark.ml.feature import HashingTF, IDF, Tokenizer,StopWordsRemover
from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.classification import NaiveBayes   
from pyspark.sql import SQLContext, Row
from pyspark.mllib.evaluation import MulticlassMetrics
from operator import itemgetter

sqlContext = SQLContext(sc)

# Here data is a dataframe, can also do transformations and actions like RDD
data = sqlContext.createDataFrame([
    (0.0, "We start learning Spark"),
    (0.0, "Python and R have API to work with it"),
    (1.0, "We use Kmeans to cluster stock movement"),
	(1.0, "We use logistic regression to predict bankruptcy")
], ["label", "content"])

# tokenizer to create a "terms" column so for example:
# from content=u'We start learning Spark'  we have terms=[u'we', u'start', u'learning', u'spark']
tokenizer = Tokenizer(inputCol="content", outputCol="terms")
termsData = tokenizer.transform(data)

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

labels = data.map(
    lambda doc: doc["label"]  # Standard Python dict access 
)

# Training and Test datasets
# Here feature#5 contains the data for training, for example
# [Row(label=0.0, content=u'We start learning Spark', terms=[u'we', u'start', u'learning', u'spark'], filtered=[u'start', u'learning', u'spark'], 
# rawFeatures=SparseVector(262144, {29470: 1.0, 62173: 1.0, 181346: 1.0}), features=SparseVector(262144, {29470: 0.9163, 62173: 0.9163, 181346: 0.9163}))]
# if loaded from a dataset, may use something like:
# training, test = data.randomSplit([0.6, 0.4], seed = 0)
training = tfidf.map(lambda x: LabeledPoint(x[0],x[5]))
testing = tfidf.map(lambda x: x[4])

# Train the model
model = NaiveBayes.train(training)

# prediction
predval = model.predict(testing)
prediction = labels.zip(predval).map(lambda x: {"actual": x[0], "predicted": float(x[1])})

# confusion matrix
metrics = MulticlassMetrics(prediction.map(itemgetter("actual", "predicted")))
metrics.confusionMatrix().toArray()

# Result of metrics.confusionMatrix().toArray()
# array([[ 2.,  0.],
#       [ 0.,  2.]])