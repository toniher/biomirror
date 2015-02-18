#!/bin/sh

blastdbcmd -dbtype prot -entry $1 -db ../datasets/drosoph.aa.md5
