# GeneInfo and Gene Association

Under study

ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz
ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz
ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz
ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_group.gz


We import tables -> gene.sql

mysql -h dbhost -u dbuser -p dbpass biodb -e "LOAD DATA LOCAL INFILE '/your/path/to/gene2accession' INTO TABLE gene2accession FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';"
mysql -h dbhost -u dbuser -p dbpass biodb -e "LOAD DATA LOCAL INFILE '/your/path/to/gene_info' INTO TABLE gene_info FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';"



