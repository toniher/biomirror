#!/bin/sh

samtools faidx $1

samtools faidx $1 $3
samtools faidx $1 $2

