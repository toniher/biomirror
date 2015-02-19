#!/bin/sh

mkdir -p ../tmp
cp -rf $2* ../tmp
cat $3 $1 > $3.2
mv $3.2 $3

samtools faidx $3

samtools faidx $3 $5
samtools faidx $3 $4

rm -rf ../tmp

