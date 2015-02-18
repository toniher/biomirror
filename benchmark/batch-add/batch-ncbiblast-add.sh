#!/bin/sh

rm -rf ../datasets/drosoph.aa.md5.*
makeblastdb -dbtype prot -in ../datasets/drosoph.aa.md5 -parse_seqids 

