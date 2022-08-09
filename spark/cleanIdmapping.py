#!/usr/bin/env python
# -*- coding: utf-8 -*-

# findspark is needed in some environments
import findspark

findspark.init()

import pyspark

import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length
from pyspark.sql.types import StructType, StructField
from pyspark.sql.types import StringType
import pprint

parser = argparse.ArgumentParser(description="""Script cleaning Idmapping file""")
parser.add_argument("-localdir", help="""Spark local dir""")
parser.add_argument("-input", help="""Input file""")
parser.add_argument("-output", help="""Output file""")
args = parser.parse_args()

spark = SparkSession.builder.master("local[1]")
spark = spark.appName('cleanIdmapping')

# TODO: Make it consider more config options
if args.localdir:
    spark = spark.config('spark.local.dir', args.localdir)

spark = spark.getOrCreate()


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

df.write.csv(args.output, sep="\t", compression="gzip")
