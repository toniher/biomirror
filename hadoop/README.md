Stuff related to Hadoop, Spark, HBASE, etc.

    nohup python rewrite-IDmapping.py idmapping.dat > idmapping.new.dat &
    nohup hdfs dfs -copyFromLocal idmapping.new.dat idmapping.new.dat &> log &
    nohup spark-submit cleanIdmapping.py  &> log & 
    #hbase org.apache.hadoop.hbase.mapreduce.ImportTsv -Dimporttsv.columns=map:uniprot,map:db,HBASE_ROW_KEY idmapping /user/hbase/idmappingall

retrieve:

     hdfs dfs -getmerge idmappingall idmappingall.csv

