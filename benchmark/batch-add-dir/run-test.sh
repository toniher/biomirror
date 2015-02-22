#/bin/sh

PASSWORD=$2
FASTA=$1
DIREND=../dir

>&2 echo "SPLIT"
time ./splitindir.sh $FASTA $DIREND

>&2 echo "COUCHDB - DROP"
time curl -silent -X DELETE http://admin:$PASSWORD@localhost:5984/testseq
>&2 echo "COUCHDB - ADD"
time python batch-couchdb-add.py $DIREND $PASSWORD

>&2 echo "SQLITE - DROP"
time rm -rf ../datasets/testseq
>&2 echo "SQLITE - ADD"
time python batch-sqlite-add.py $DIREND

>&2 echo "MYSQL - DROP"
time mysql -utoniher -e 'DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS test;'
>&2 echo "MYSQL - ADD"
time python batch-mysql-add.py $DIREND


>&2 echo "REDIS - DROP"
time redis-cli 'flushdb';
>&2 echo "REDIS - ADD"
time python batch-redis-add.py $DIREND


