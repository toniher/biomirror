#!/bin/bash
set -ueo pipefail

JSONFILE=${1:-../config.json}

curdir="$(dirname "$(realpath "$0")")"

workdir=$(jq .workdir $JSONFILE)

user=$(jq .mysql.user $JSONFILE)
password=$(jq .mysql.password $JSONFILE)
host=$(jq .mysql.host $JSONFILE)
db=$(jq .mysql.db $JSONFILE)

mysql -s -u$user -p$password -h$host $db < $curdir/idmapping.sql

for file in ${workdir}/*csv
do
  echo $file
  mysql -s -u$user -p$password -h$host $db -e "SET @@session.unique_checks = 0; SET @@session.foreign_key_checks = 0; LOAD DATA LOCAL INFILE '$file' INTO TABLE idmapping FIELDS TERMINATED BY '\t' ENCLOSED BY '' "
done
