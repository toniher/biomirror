#!/bin/sh

while read line; do
    declare "$line"
done < "../config.sh"


mkdir -p files

cd files
rm -f *gz
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpa.gz -o /dev/null
wget -c -t0 ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gpi.gz -o /dev/null

cd ../

# TODO preprocess data in UniProtGOA for less time

python gpinfotaxon-mysql.py files/goa_uniprot_all.gpi.gz ../config.json
python gpgoassociation-mysql.py files/goa_uniprot_all.gpa.gz ../config.json

