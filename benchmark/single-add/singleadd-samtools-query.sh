#!/bin/sh

mkdir -p ../tmp
cp -rf ../datasets/drosoph.aa.md5* ../tmp
cat ../tmp/drosoph.aa.md5 ../datasets/drosoph.single.aa.md5 > ../tmp/drosoph.aa.md5.2
mv ../tmp/drosoph.aa.md5.2 ../tmp/drosoph.aa.md5

samtools faidx ../tmp/drosoph.aa.md5

samtools faidx ../tmp/drosoph.aa.md5 749b09af5b9cf3352f7124c63489e5a7
samtools faidx ../tmp/drosoph.aa.md5 7d3bb4ae52311b22e8e7daf4daf4587e

rm -rf ../tmp

