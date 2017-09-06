#!/bin/sh

while read line; do
    declare "$line"
done < "../config.sh"

path=./files

mkdir -p $path
cd $path

rm -f *gz
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_group.gz -o /dev/null
wget -c -t0 ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_refseq_uniprotkb_collab.gz -o /dev/null
gunzip *.gz

cd ../


mysql -s -u$user -p$passwd -h$server $db < biosql.sql
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene2accession' INTO TABLE gene2accession FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene_info' INTO TABLE gene_info FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene2go' INTO TABLE gene2go FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene2pubmed' INTO TABLE gene2pubmed FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene2refseq' INTO TABLE gene2refseq FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene_group' INTO TABLE gene_group FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/gene_refseq_uniprotkb_collab' INTO TABLE gene_refseq_uniprotkb_collab FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;"



