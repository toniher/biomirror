#!/bin/sh

# List of DB to download. Extracted from update_blastdb.pl --showall
LISTDB=$1
# Script below from NCBI Blast+ package
SCRIPT=/db/.scripts/update_blastdb.pl
BASEDIR=/db/ncbi/
DATE=`date +%Y%m`
TIMEOUT=360
PASSIVE=""
#Alternative
#PASSIVE="--passive"

#TODO: Repeat if log Error less down-ncbi-202008.2020.log |grep 'Failed'

ENDDIR=$BASEDIR$DATE/blastdb/db

echo $ENDDIR

if [ ! -d $ENDDIR ]; then
	mkdir -p $ENDDIR
fi

cd $ENDDIR || exit

while IFS='' read -r line || [[ -n "$line" ]]; do
   perl $SCRIPT $PASSIVE --timeout $TIMEOUT --decompress $line
done < "$LISTDB"
