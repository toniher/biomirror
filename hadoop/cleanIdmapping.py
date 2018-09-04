from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql.functions import col, length, size
import pprint

sc = SparkContext(appName="PythonStreamingQueueStream")    
sqlContext = SQLContext(sc)

from pyspark.sql.types import StructType, StructField
from pyspark.sql.types import DoubleType, IntegerType, StringType

schema = StructType([
    StructField("uniprot", StringType()),
    StructField("db", StringType()),
    StructField("extern", StringType())
])

df = ( sqlContext
    .read
    .format("com.databricks.spark.csv")
    .schema(schema)
    .option("header", "false")
    .option("delimiter", "\t")
    .option("mode", "DROPMALFORMED")
    .load("hdfs:///user/hbase/idmapping.new.dat")
#    .load("hdfs:///user/hbase/idmapping.10000")
    .dropDuplicates(['extern'])
    .filter( length(col("extern")) > 4) )


print df.count()

# df.coalesce(1).write.format('com.databricks.spark.csv').options(delimiter="\t").save('/user/hbase/testall')
# df.repartition(1).coalesce(1).write.csv("/user/toniher/idmappingall.csv", header='true', sep='\t')
df.write.format('com.databricks.spark.csv').options(delimiter="\t").save('/user/hbase/idmappingall')

#df.printSchema()

sc.stop()

