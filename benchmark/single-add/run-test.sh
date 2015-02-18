#/bin/sh

PASSWORD=$1

>&2 echo "BLAST - SINGLE ADD - QUERY"
time ./singleadd-ncbiblast-query.sh

>&2 echo "SAMTOOLS - SINGLE ADD - QUERY"
time ./singleadd-samtools-query.sh

>&2 echo "COUCHDB - SINGLE ADD - QUERY"
time python singleadd-couchdb-query.py ../datasets/drosoph.single.aa.md5 7d3bb4ae52311b22e8e7daf4daf4587e

>&2 echo "SQLITE - SINGLE ADD - QUERY"
time python singleadd-sqlite-query.py ../datasets/drosoph.single.aa.md5 7d3bb4ae52311b22e8e7daf4daf4587e

>&2 echo "REDIS - SINGLE ADD - QUERY"
time python singleadd-redis-query.py ../datasets/drosoph.single.aa.md5 7d3bb4ae52311b22e8e7daf4daf4587e


