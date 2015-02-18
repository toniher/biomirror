#/bin/sh

PASSWORD=$1

>&2 echo "BLAST - ADD"
time ./batch-ncbiblast-add.sh ../datasets/drosoph.aa.md5
>&2 echo "BLAST - QUERY"
time ./batch-ncbiblast-query.sh

>&2 echo "SAMTOOLS - ADD"
time ./batch-samtools-add.sh ../datasets/drosoph.aa.md5
>&2 echo "SAMTOOLS - QUERY"
time ./batch-samtools-query.sh

>&2 echo "COUCHDB - ADD"
time python batch-couchdb-add.py ../datasets/drosoph.aa.md5 $PASSWORD
>&2 echo "COUCHDB - QUERY"
time python batch-couchdb-query.py 7d3bb4ae52311b22e8e7daf4daf4587e

>&2 echo "SQLITE - ADD"
time python batch-sqlite-add.py ../datasets/drosoph.aa.md5
>&2 echo "SQLITE - QUERY"
time python batch-sqlite-query.py 7d3bb4ae52311b22e8e7daf4daf4587e

>&2 echo "REDIS - ADD"
time python batch-redis-add.py ../datasets/drosoph.aa.md5
>&2 echo "REDIS - QUERY"
time python batch-redis-query.py 7d3bb4ae52311b22e8e7daf4daf4587e


