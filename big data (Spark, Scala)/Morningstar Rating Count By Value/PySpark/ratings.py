from pyspark import SparkConf, SparkContext 
import collections

conf = SparkConf().setMaster("local").setAppName("MorningstarRatings")
sc = SparkContext(conf = conf)

lines = sc.textFile("morningstar.csv")
ratings = lines.map(lambda x: x.split(',')[2])
result = ratings.countByValue()

sortedCounts = collections.OrderedDict(sorted(result.items()))
for key, value in sortedCounts.items():
    print ("%s %i" % (key, value))
