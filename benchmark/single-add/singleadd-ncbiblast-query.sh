#!/bin/sh

mkdir -p ../tmp
cp -rf $2* ../tmp
cat $3 $1 > $3.2
mv $3.2 $3

makeblastdb -dbtype prot -in $3 -parse_seqids 

blastdbcmd -dbtype prot -entry $5 -db $3
blastdbcmd -dbtype prot -entry $4 -db $3

rm -rf ../tmp

