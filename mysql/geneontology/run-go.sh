#!/bin/sh

while read line; do
    declare "$line"
done < "../config.sh"


path=./files

mkdir $path

cd $path

rm -f *gz

wget -c -t0 http://archive.geneontology.org/latest-full/go_monthly-assocdb-data.gz -o /dev/null

gunzip go_monthly-assocdb-data.gz

cd ..

mysql -s -u$user -p$passwd -h$server $db < $path/go_monthly-assocdb-data

