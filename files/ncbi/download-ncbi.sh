#!/bin/sh

# List of DB to download. Extracted from update_blastdb.pl --showall
LISTDB=$1
# Script below from NCBI Blast+ package
SCRIPT=/db/.scripts/update_blastdb.pl
BASEDIR=/db/ncbi/
DATE=`date +%Y%m`

ENDDIR=$BASEDIR$DATE/blastdb/db

echo $ENDDIR

if [ ! -d $ENDDIR ]; then
	mkdir -p $ENDDIR
fi

cd $ENDDIR

while IFS='' read -r line || [[ -n "$line" ]]; do
   perl $SCRIPT --passive --decompress $line	 
done < "$LISTDB"

