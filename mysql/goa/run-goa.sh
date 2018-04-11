#!/bin/bash

set -ueo pipefail

source "../config.sh"


mkdir -p files

cd files
rm -f *gz
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpa.gz -o /dev/null
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpi.gz -o /dev/null

cd ../

# TODO preprocess data in UniProtGOA for less time

python gpinfotaxon-mysql.py files/goa_uniprot_all.gpi.gz ../config.json > temp.taxon.csv

mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE 'temp.taxon.csv' INTO TABLE goataxon FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

rm temp.taxon.csv

python gpgoassociation-mysql.py files/goa_uniprot_all.gpa.gz ../config.json > temp.goa.csv

mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE 'temp.goa.csv' INTO TABLE goassociation FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

rm temp.goa.csv

