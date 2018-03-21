#!/bin/bash

set -ueo pipefail

source "../config.sh"

path=./files

origin=/db/ncbi/201706/taxonomy/db/

cp -rf $origin $path

mysql -s -u$user -p$passwd -h$server $db < taxonomy.sql
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/names.dmp' INTO TABLE ncbi_names FIELDS TERMINATED BY '\t|\t' LINES TERMINATED BY '\t|\n' (tax_id, name_txt, unique_name, name_class);"
mysql -s -u$user -p$passwd -h$server $db -e "LOAD DATA LOCAL INFILE '$path/nodes.dmp' INTO TABLE ncbi_nodes FIELDS TERMINATED BY '\t|\t' LINES TERMINATED BY '\t|\n' (tax_id, parent_tax_id,rank,embl_code,division_id, inherited_div_flag,genetic_code_id,inherited_GC_flag, mitochondrial_genetic_code_id,inherited_MGC_flag, GenBank_hidden_flag,hidden_subtree_root_flag,comments);"



