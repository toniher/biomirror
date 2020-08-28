#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyspark
import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length, size

import pprint

spark = SparkSession.builder.master("local[1]") \
                    .appName('cleanIdmapping') \
                    .getOrCreate()

from pyspark.sql.types import StructType, StructField
from pyspark.sql.types import DoubleType, IntegerType, StringType

parser = argparse.ArgumentParser(description="""Script cleaning Idmapping file""")
parser.add_argument("-input",help="""Input file""")
parser.add_argument("-output",help="""Output file""")
args = parser.parse_args()

schema = StructType([
    StructField("uniprot", StringType()),
    StructField("db", StringType()),
    StructField("extern", StringType())
])

df = spark.read.csv(args.input)
    .schema(schema)
    .option("header", "false")
    .option("delimiter", "\t")
    .option("mode", "DROPMALFORMED")
    .dropDuplicates(['extern'])
    .filter( length(col("extern")) > 4) )

df.write.csv(args.output).options(delimiter="\t")
