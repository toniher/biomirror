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

aws s3 ls ${bucket_data_path} | perl -lane 'print $F[3]' > /tmp/files.txt

while read -r ifile; do
    echo "LOAD S3 's3://${bucket_data_path}/${ifile}' INTO TABLE idmapping FIELDS TERMINATED BY '\t', LINES TERMINATED BY '\n' ( 'uniprot', 'db', 'external' ) " > /tmp/command.sql
    mysql -uroot -p${db_password} -h${db_host} biomirror < /tmp/command.sql
done < "/tmp/files.txt"



