#!/bin/sh

while read line; do
    declare "$line"
done < "../config.sh"


mkdir -p files

cd files
rm -f *gz
wget -c -t0 ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz -o /dev/null
gunzip idmapping.dat.gz

cd ../

python rewrite-IDmapping.py files/idmapping.dat > files/idmapping.new.dat

mysql -s -u$user -p$passwd -h$server $db < idmapping.sql

mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE 'files/idmapping.new.dat' INTO TABLE idmapping FIELDS TERMINATED BY '\t' ENCLOSED BY '' "

