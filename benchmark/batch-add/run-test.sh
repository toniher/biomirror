#/bin/sh

PASSWORD=$1

echo "BLAST"
time ./batch-ncbiblast-add.sh ../datasets/drosoph.aa.md5
time ./batch-ncbiblast-query.sh

echo "SAMTOOLS"
time ./batch-samtools-add.sh ../datasets/drosoph.aa.md5
time ./batch-samtools-query.sh

echo "COUCHDB"

time python batch-couchdb-add.py ../datasets/drosoph.aa.md5 $PASSWORD
time python batch-couchdb-query.py 7d3bb4ae52311b22e8e7daf4daf4587e

echo "SQLITE"
time python batch-sqlite-add.py ../datasets/drosoph.aa.md5
time python batch-sqlite-query.py 7d3bb4ae52311b22e8e7daf4daf4587e

echo "REDIS"
time python batch-redis-add.py ../datasets/drosoph.aa.md5
time python batch-redis-query.py 7d3bb4ae52311b22e8e7daf4daf4587e






