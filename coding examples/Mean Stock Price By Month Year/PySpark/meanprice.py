from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("local").setAppName("MeanPriceByMonth")
sc = SparkContext(conf = conf)

def parseLine(line):
    fields = line.split(',')
    datetimedata = fields[0]
    datetimearray = datetimedata.split('/')
    monthyear = datetimearray[0]+datetimearray[2]
    adjclose = float(fields[6])
    return (monthyear, adjclose)

lines = sc.textFile("adjclose.csv")
rdd = lines.map(parseLine)
priceByMonthYear = rdd.mapValues(lambda x: (x, 1)).reduceByKey(lambda x, y: (x[0] + y[0], x[1] + y[1]))

averagesByMonthYear = priceByMonthYear.mapValues(lambda x: x[0] / x[1])
results = averagesByMonthYear.collect()
for result in results:
    print (result)
