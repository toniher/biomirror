#!/bin/bash

set -ueo pipefail

JSONFILE=${1:-../config.json}

workdir=$(jq .workdir $JSONFILE)
taxondir=$(jq .taxondir $JSONFILE)

user=$(jq .mysql.user $JSONFILE)
password=$(jq .mysql.password $JSONFILE)
host=$(jq .mysql.host $JSONFILE)
db=$(jq .mysql.db $JSONFILE)

cp -rf $taxondir/* $workdir

curdir="$(dirname "$(realpath "$0")")"

mysql -s -u$user -p$password -h$host $db < $curdir/taxonomy.sql
mysql -s -u$user -p$password -h$host $db -e "LOAD DATA LOCAL INFILE '$workdir/names.dmp' INTO TABLE ncbi_names FIELDS TERMINATED BY '\t|\t' LINES TERMINATED BY '\t|\n' (tax_id, name_txt, unique_name, name_class);"
mysql -s -u$user -p$password -h$host $db -e "LOAD DATA LOCAL INFILE '$workdir/nodes.dmp' INTO TABLE ncbi_nodes FIELDS TERMINATED BY '\t|\t' LINES TERMINATED BY '\t|\n' (tax_id, parent_tax_id,rank,embl_code,division_id, inherited_div_flag,genetic_code_id,inherited_GC_flag, mitochondrial_genetic_code_id,inherited_MGC_flag, GenBank_hidden_flag,hidden_subtree_root_flag,comments);"



