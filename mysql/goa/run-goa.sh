#!/bin/bash

set -ueo pipefail

JSONFILE=${1:-../config.json}

curdir="$(dirname "$(realpath "$0")")"

workdir=$(jq .workdir $JSONFILE)

user=$(jq .mysql.user $JSONFILE)
password=$(jq .mysql.password $JSONFILE)
host=$(jq .mysql.host $JSONFILE)
db=$(jq .mysql.db $JSONFILE)

mkdir -p $workdir
cd $workdir

rm -f *gz
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpa.gz -o /dev/null
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpi.gz -o /dev/null

cd $curdir

# TODO preprocess data in UniProtGOA for less time

python gpinfotaxon-mysql.py $workdir/goa_uniprot_all.gpi.gz $JSONFILE > temp.taxon.csv

mysql -s -u$user -p$password -h$host $db -e "LOAD DATA LOCAL INFILE 'temp.taxon.csv' INTO TABLE goataxon FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

rm temp.taxon.csv

python gpgoassociation-mysql.py $workdir/goa_uniprot_all.gpa.gz $JSONFILE > temp.goa.csv

mysql -s -u$user -p$password -h$host $db -e "LOAD DATA LOCAL INFILE 'temp.goa.csv' INTO TABLE goassociation FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

rm temp.goa.csv
