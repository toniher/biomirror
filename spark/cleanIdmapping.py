#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyspark
import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length
from pyspark.sql.types import StructType, StructField
from pyspark.sql.types import StringType
import pprint

spark = SparkSession.builder.master("local[1]") \
                    .appName('cleanIdmapping') \
                    .config('spark.local.dir', '/scratch/tmp') \
                    .getOrCreate()

parser = argparse.ArgumentParser(description="""Script cleaning Idmapping file""")
parser.add_argument("-input", help="""Input file""")
parser.add_argument("-output", help="""Output file""")
args = parser.parse_args()

schema = StructType([
    StructField("uniprot", StringType()),
    StructField("db", StringType()),
    StructField("extern", StringType())
])

df = spark.read.format("csv") \
     .option("header", False) \
     .option("delimiter", "\t") \
     .option("mode", "DROPMALFORMED") \
     .schema(schema) \
     .load(args.input) \
     .dropDuplicates(['extern']) \
     .filter(length(col("extern")) > 4)

df.write.csv(args.output, sep="\t")
