#!/bin/bash
set -ueo pipefail

source "../config.sh"

FILEDIR=files
SCRIPTDIR=`pwd`

mysql -s -u$user -p$passwd -h$server $db < $SCRIPTDIR/idmapping.sql

for file in ${FILEDIR}/*csv
do
  mysql -s -u$user -p$passwd -h$server $db -e "SET @@session.unique_checks = 0; SET @@session.foreign_key_checks = 0; LOAD DATA LOCAL INFILE '$FILEDIR/$file' INTO TABLE idmapping FIELDS TERMINATED BY '\t' ENCLOSED BY '' "
done
