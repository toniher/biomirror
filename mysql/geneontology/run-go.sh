#!/bin/bash

set -ueo pipefail

JSONFILE=${1:-../config.json}

curdir="$(dirname "$(realpath "$0")")"

workdir=$(jq .workdir $JSONFILE)

user=$(jq .mysql.user $JSONFILE)
password=$(jq .mysql.password $JSONFILE)
host=$(jq .mysql.host $JSONFILE)
db=$(jq .mysql.db $JSONFILE)

mkdir -p $workdir
cd $workdir

rm -f *gz

wget -c -t0 http://archive.geneontology.org/latest-lite/go_weekly-assocdb-tables.tar.gz -o /dev/null

tar zxf go_weekly-assocdb-tables.tar.gz

cd go_weekly-assocdb-tables

sed -i -e 's/MyISAM/Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci/g' *.sql

cd $workdir

cat $workdir/go_weekly-assocdb-tables/*sql > $workdir/go_weekly-assocdb-tables.sql

mysql -s -u$user -p$password -h$host $db < $workdir/go_weekly-assocdb-tables.sql

mysqlimport --local -u$user -p$password -h$host $db $workdir/go_weekly-assocdb-tables/*txt
