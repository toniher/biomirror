#!/bin/sh

JSONFILE=${1:-../conf/ncbi.json}
LISTDB=${2:-../conf/ncbi-files.txt}

BASEDIR=$(jq .basedir $JSONFILE)
SUBDIR=$(jq .subdir $JSONFILE)
TIMEOUT=$(jq .timeout $JSONFILE)
PASSIVE=$(jq .passive $JSONFILE)
#Alternative
#PASSIVE="--passive"

BLAST_IMG=$(jq .containers.blast $JSONFILE)

DATE=`date +%Y%m`

# List of DB to download. Extracted from update_blastdb.pl --showall
# Script below from NCBI Blast+ package
SCRIPT="singularity exec -e $BLAST_IMG update_blastdb.pl"

# TODO: Repeat if log error
# perl -lane 'print $1 if $_=~/Failed to download (\S+?)\./' down-ncbi-202008.2020.log

ENDDIR=${BASEDIR}/${DATE}/${SUBDIR}

echo $ENDDIR

if [ ! -d $ENDDIR ]; then
	mkdir -p $ENDDIR
fi

cd $ENDDIR || exit

while IFS='' read -r line || [[ -n "$line" ]]; do
	$SCRIPT $PASSIVE --timeout $TIMEOUT --decompress $line
done < "$LISTDB"
