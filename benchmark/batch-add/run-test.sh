#/bin/sh

source $1
PASSWORD=$2
TMPDIR=/data/temp

>&2 echo "BLAST - DROP"
time rm -rf $FASTA.p*
>&2 echo "BLAST - ADD"
time ./batch-ncbiblast-add.sh $FASTA
>&2 echo "BLAST - QUERY"
time ./batch-ncbiblast-query.sh $FASTA $SEQ

>&2 echo "BLAST.py - DROP"
time rm -rf $FASTA.p*
>&2 echo "BLAST.py - ADD"
time python batch-ncbiblast-add.py $FASTA
>&2 echo "BLAST.py - QUERY"
time python batch-ncbiblast-query.py $FASTA $SEQ

>&2 echo "SAMTOOLS - DROP"
time rm -rf $FASTA.fai
>&2 echo "SAMTOOLS - ADD"
time ./batch-samtools-add.sh $FASTA
>&2 echo "SAMTOOLS - QUERY"
time ./batch-samtools-query.sh $FASTA $SEQ

>&2 echo "SAMTOOLS.py - DROP"
time rm -rf $FASTA.fai
>&2 echo "SAMTOOLS.py - ADD"
time python batch-samtools-add.py $FASTA
>&2 echo "SAMTOOLS.py - QUERY"
time python batch-samtools-query.py $FASTA $SEQ


>&2 echo "COUCHDB - DROP"
time curl -silent -X DELETE http://admin:$PASSWORD@localhost:5984/testseq
>&2 echo "COUCHDB - ADD"
time python batch-couchdb-add.py $FASTA $PASSWORD
>&2 echo "COUCHDB - QUERY"
time python batch-couchdb-query.py $SEQ

>&2 echo "SQLITE - DROP"
time rm -rf ../datasets/testseq
>&2 echo "SQLITE - ADD"
time python batch-sqlite-add.py $FASTA
>&2 echo "SQLITE - QUERY"
time python batch-sqlite-query.py $SEQ

>&2 echo "SQLITE - DROP"
time rm -rf ../datasets/testseq

>&2 echo "FASTA 2 CSV "
time python ../datasets/fasta2csv.py $FASTA $FASTA.csv

>&2 echo "SQLITE - ADD - LOAD"
cp batch-sqlite-load-add.sh $TMPDIR/sqlite.sh
export FASTA
perl -pi -e 's/\$CSVFILE/$ENV{FASTA}/g' $TMPDIR/sqlite.sh
time sqlite3 < $TMPDIR/sqlite.sh


>&2 echo "MYSQL - DROP"
time mysql -utoniher -e 'DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS test;'
>&2 echo "MYSQL - ADD"
time python batch-mysql-add.py $FASTA
>&2 echo "MYSQL - QUERY"
time python batch-mysql-query.py $SEQ

>&2 echo "MYSQL - DROP"
time mysql -utoniher -e 'DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS test;'
>&2 echo "MYSQL - CP CSV"
time cp $FASTA.csv $TMPDIR/mysql-load.csv; chmod a+rx $TMPDIR/mysql-load.csv
>&2 echo "MYSQL - ADD - LOAD"
time python batch-mysql-load-add.py $TMPDIR/mysql-load.csv $PASSWORD


>&2 echo "REDIS - DROP"
time redis-cli 'flushdb';
>&2 echo "REDIS - ADD"
time python batch-redis-add.py $FASTA
>&2 echo "REDIS - QUERY"
time python batch-redis-query.py $SEQ


