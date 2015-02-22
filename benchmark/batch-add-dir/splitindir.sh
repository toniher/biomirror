#!/bin/sh

FASTA=$1
EXTENT=100000
DIRNAME=`dirname $FASTA`
DIREND=$2

NUMSEQ=`cat $1|grep '>'|wc -l`

NUMFILES=$(echo "a=$NUMSEQ; b=$EXTENT; if ( a%b ) a/b+1 else a/b" | bc)

echo $NUMFILES
pyfasta split -n $NUMFILES $FASTA

rm -rf $DIREND
mkdir -p $DIREND
export DIREND
export DIRNAME

ls -lR $DIRNAME | perl -lane 'if ($_=~/(\S+\.\d+|\S+\.split)/ ) { system("mv $ENV{DIRNAME}/$1 $ENV{DIREND}");  }'



