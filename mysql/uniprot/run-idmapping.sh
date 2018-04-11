#!/bin/bash
set -ueo pipefail

source "../config.sh"

FILEDIR=files
SCRIPTDIR=`pwd`

mkdir -p $FILEDIR

cd $FILEDIR
rm -f *gz
wget -c -t0 ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz -o /dev/null
gunzip idmapping.dat.gz

cd ../

python rewrite-IDmapping.py $FILEDIR/idmapping.dat > $FILEDIR/idmapping.new.dat
sed -i '/^$/d' $FILEDIR/idmapping.new.dat

rm $FILEDIR/idmapping.dat

mysql -s -u$user -p$passwd -h$server $db < $SCRIPTDIR/idmapping.sql

mysql -s -u$user -p$passwd -h$server $db -e "SET @@session.unique_checks = 0; SET @@session.foreign_key_checks = 0; LOAD DATA LOCAL INFILE '$FILEDIR/idmapping.new.dat' INTO TABLE idmapping FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

