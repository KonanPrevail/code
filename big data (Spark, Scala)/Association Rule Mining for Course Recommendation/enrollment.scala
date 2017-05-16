import org.apache.spark.rdd.RDD
import org.apache.spark.mllib.fpm.AssociationRules
import org.apache.spark.mllib.fpm.FPGrowth.FreqItemset
import org.apache.spark.mllib.fpm.FPGrowth

val data = sc.textFile("file:///home/xxxx/scala/enrollment/enrollment_1.csv")
data.take(2).foreach(println)

val transactions: RDD[Array[String]] = data.map(s => s.trim.split(','))

val fpg = new FPGrowth().setMinSupport(0.001).setNumPartitions(10)
val model = fpg.run(transactions)

model.freqItemsets.collect().foreach {itemset =>
  println(itemset.items.mkString("[", ",", "]") + ", " + itemset.freq)
}

val minConfidence = 0.8
model.generateAssociationRules(minConfidence).collect().foreach { rule =>
  println(
    rule.antecedent.mkString("[", ",", "]")
      + " => " + rule.consequent .mkString("[", ",", "]")
      + ", " + rule.confidence)
}


# counts.saveAsTextFile("hdfs://ib-"+sys.env("HOSTNAME")+":54310/scala_outputs")


