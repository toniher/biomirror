#/bin/sh

PASSWORD=$1
FASTA=../datasets/drosoph.single.aa.md5
BASE=../datasets/nr-md5
BASETMP=../tmp/nr-md5
SEQ=b8b953e09c5e3a8796fd6b1220a2586c
SEQPRE=416fcc5499fcb42e864436329ac27ae7

mkdir -p ../tmp
cp -rf $BASE* ../tmp
cat $BASETMP $FASTA > $BASETMP.2
mv $BASETMP.2 $BASETMP
>&2 echo "BLAST - SINGLE ADD - QUERY"
time ./singleadd-ncbiblast-query.sh $BASETMP $SEQ $SEQPRE
rm -rf ../tmp

mkdir -p ../tmp
cp -rf $BASE* ../tmp
cat $BASETMP $FASTA > $BASETMP.2
mv $BASETMP.2 $BASETMP
>&2 echo "SAMTOOLS - SINGLE ADD - QUERY"
time ./singleadd-samtools-query.sh $BASETMP $SEQ $SEQPRE
rm -rf ../tmp

>&2 echo "COUCHDB - SINGLE ADD - QUERY"
time python singleadd-couchdb-query.py $FASTA $SEQ

>&2 echo "SQLITE - SINGLE ADD - QUERY"
time python singleadd-sqlite-query.py $FASTA $SEQ

>&2 echo "MYSQL - SINGLE ADD - QUERY"
time python singleadd-mysql-query.py $FASTA $SEQ

>&2 echo "REDIS - SINGLE ADD - QUERY"
time python singleadd-redis-query.py $FASTA $SEQ


