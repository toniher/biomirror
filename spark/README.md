Idmapping data can be downloaded from:

    ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz

Stuff related to Hadoop, Spark, HBASE, etc.

    nohup python rewrite-IDmapping.py idmapping.dat > idmapping.new.dat &
    nohup hdfs dfs -copyFromLocal idmapping.new.dat idmapping.new.dat &> log &
    nohup spark-submit cleanIdmapping.py  &> log &
    #hbase org.apache.hadoop.hbase.mapreduce.ImportTsv -Dimporttsv.columns=map:uniprot,map:db,HBASE_ROW_KEY idmapping /user/hbase/idmappingall

retrieve:

     hdfs dfs -getmerge idmappingall idmappingall.csv

## ONGOING

    Using: https://github.com/big-data-europe/docker-spark
    docker-compose up

Put Dockerfile and simplify with Spark

    docker build -t cleanidmapping .
	docker run -d --volume /scratch/tmp:/scratch --network docker-spark_default --name cleanidmapping -e ENABLE_INIT_DAEMON=false --link spark-master:spark-master  cleanidmapping tail -f /dev/null
	nohup  docker exec cleanidmapping python3 /app/cleanIdmapping.py -input /scratch/idmapping.dat -output /scratch/out.csv &> log & 
