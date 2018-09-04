Stuff related to Hadoop, Spark, HBASE, etc.

    pyspark --packages com.databricks:spark-csv_2.10:1.5.0 cleanIdmapping.py

    hbase org.apache.hadoop.hbase.mapreduce.ImportTsv -Dimporttsv.columns=map:uniprot,map:db,HBASE_ROW_KEY idmapping /user/hbase/idmappingall

retrieve:

     hdfs dfs -getmerge idmappingall idmappingall.csv

