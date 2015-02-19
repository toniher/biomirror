#!/bin/sh

makeblastdb -dbtype prot -in $1 -parse_seqids 

blastdbcmd -dbtype prot -entry $3 -db $1
blastdbcmd -dbtype prot -entry $2 -db $1


