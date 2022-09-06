#!/bin/bash

# Let's update first
sudo yum update -y
# Let's install MariaDB
sudo yum install -y mariadb
sudo yum install -y perl


# Install aws-cli
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws s3 ls ${bucket_data_path}/ | perl -lane 'print $F[3]' > /tmp/files.txt

while read -r ifile; do
    # LOAD DATA S3 does not allow directly process Gzipped files
    #echo "LOAD DATA FROM S3 's3://${bucket_data_path}/$${ifile}' INTO TABLE idmapping FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' ( 'uniprot', 'db', 'external' ) " > /tmp/command.sql
    aws s3 cp s3://${bucket_data_path}/$${ifile} part.csv.gz
    gunzip part.csv.gz
    echo "LOAD DATA LOCAL INFILE \"/tmp/part.csv\" INTO TABLE idmapping FIELDS TERMINATED BY \"\t\" LINES TERMINATED BY \"\n\" (uniprot, db, external) " > /tmp/command.sql
    mysql -uroot -p${db_password} -h${db_host} biomirror < /tmp/command.sql
    rm -f part.csv
done < "/tmp/files.txt"

echo "CREATE INDEX IF NOT EXISTS index_uniprot ON idmapping (uniprot); CREATE INDEX IF NOT EXISTS index_db ON idmapping (db); CREATE INDEX IF NOT EXISTS index_external ON idmapping (external);" > /tmp/indexes.sql
mysql -uroot -p${db_password} -h${db_host} biomirror < /tmp/indexes.sql


# Once done, trigger system to shutdown
sudo shutdown -h now
