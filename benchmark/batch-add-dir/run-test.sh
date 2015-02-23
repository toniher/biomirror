#/bin/sh

PASSWORD=$2
FASTA=$1
DIREND=../dir
TMPDIR=/data/temp

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

date1=$(date +"%s")
>&2 echo "FASTA 2 CSV "
for dfile in $DIREND/* ; do
	python ../datasets/fasta2csv.py $dfile $dfile.csv
done
date2=$(date +"%s")
diff=$(($date2-$date1))
>&2 echo "$(($diff / 60)) m $(($diff % 60)) s"

>&2 echo "SQLITE - DROP"
time rm -rf ../datasets/testseq
>&2 echo "SQLITE - START"
time sqlite3 ../datasets/testseq < ./batch-sqlite-load-add.pre.sh
date1=$(date +"%s")
>&2 echo "SQLITE - LOAD ADD"
for dfile in $DIREND/*csv ; do
	cp batch-sqlite-load-add.sh $TMPDIR/sqlite.sh
	export dfile
	perl -pi -e 's/\$CSVFILE/$ENV{dfile}/g' $TMPDIR/sqlite.sh
	time sqlite3 ../datasets/testseq < $TMPDIR/sqlite.sh
done
date2=$(date +"%s")
diff=$(($date2-$date1))
>&2 echo "$(($diff / 60)) m $(($diff % 60)) s."

>&2 echo "MYSQL - DROP"
time mysql -utoniher -e 'DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS test;'
>&2 echo "MYSQL - ADD"
time python batch-mysql-add.py $DIREND $PASSWORD

>&2 echo "MYSQL - DROP"
time mysql -utoniher -e 'DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS test;'
>&2 echo "MYSQL - LOAD ADD"
cp -rf $DIREND $TMPDIR
chmod -R a+rx $TMPDIR/dir
time python batch-mysql-load-add.py $TMPDIR/dir $PASSWORD


>&2 echo "REDIS - DROP"
time redis-cli 'flushdb';
>&2 echo "REDIS - ADD"
time python batch-redis-add.py $DIREND


