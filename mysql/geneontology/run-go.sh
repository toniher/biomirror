#!/bin/bash

set -ueo pipefail

source "../config.sh"


path=./files

mkdir $path

cd $path

rm -f *gz

wget -c -t0 http://archive.geneontology.org/latest-lite/go_weekly-assocdb-tables.tar.gz -o /dev/null

tar zxf go_weekly-assocdb-tables.tar.gz

cd go_weekly-assocdb-tables

sed -i -e 's/MyISAM/InnoDB/g' *.sql

cd ../..

cat $path/go_weekly-assocdb-tables/*sql > $path/go_weekly-assocdb-tables.sql

mysql -s -u$user -p$passwd -h$server $db < $path/go_weekly-assocdb-tables.sql

mysqlimport --local -u$user -p$passwd -h$server $db $path/go_weekly-assocdb-tables/*txt


