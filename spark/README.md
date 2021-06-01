Idmapping data can be downloaded from:

    ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz

Place in a local directory, e.g., ```/scratch/tmp```:

    cd /scratch/tmp; wget -c -t0 ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz

We use available [Spark Docker images from Big Data Europe project](https://github.com/big-data-europe/docker-spark) and run a system in our machine.

    git clone https://github.com/big-data-europe/docker-spark
    cd docker-spark
    git checkout 3.0.0-hadoop3.2
    docker-compose up

We can execute the process our specific Docker image:

    docker build -t cleanidmapping .
    docker run -d --volume /scratch/tmp:/scratch --network docker-spark_default --name cleanidmapping -e ENABLE_INIT_DAEMON=false --link spark-master:spark-master  cleanidmapping tail -f /dev/null
    
    nohup docker exec cleanidmapping bash -c 'cd /scratch; gunzip idmapping.dat.gz'
    nohup docker exec cleanidmapping bash -c 'python3 /app/rewrite-IDmapping.py /scratch/idmapping.dat > /scratch/idmapping.rew.dat' &> log &
    
    nohup docker exec cleanidmapping python3 /app/cleanIdmapping.py -input /scratch/idmapping.rew.dat -output /scratch/idmapping.processed.csv &> log & 


