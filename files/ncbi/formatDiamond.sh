#!/usr/bin/env bash

set -ueo pipefail

CURRENT=`date +%Y%m`

JSONFILE=${1:-../conf/ncbi.json}
LISTDB=${2:-../conf/ncbi-files.txt}
DATE=${3:-${CURRENT}}
TAXON=${4:-0}

BASEDIR=$(jq .basedir $JSONFILE)
SUBDIR=$(jq .subdir $JSONFILE)
SUBTAXDIR=$(jq .subtaxdir $JSONFILE)

BLAST_IMG=$(jq .containers.blast $JSONFILE)
DIAMOND_IMG=$(jq .containers.diamond $JSONFILE)

#LISTARRAY=(cdd_delta env_nr landmark nr pdbaa refseq_protein swissprot tsa_nr)
IFS=$'\n' read -d '' -r -a LISTARRAY < $LISTDB

NCBIBLAST="singularity exec -e $BLAST_IMG"
DIAMOND="singularity exec -e $DIAMOND_IMG"

if [ ! -d ${BASEDIR}/${DATE}/${SUBDIR} ]; then
  exit 1
fi

LOCATION=${BASEDIR}/${DATE}/${SUBDIR}

cd $LOCATION

if [ "$TAXON" -ne "0" ]; then

  if [ ! -d ${BASEDIR}/${DATE}/${SUBTAXDIR} ]; then
    exit 1
  fi

  cp ${BASEDIR}/${DATE}/${SUBTAXDIR}/accession2taxid/prot.accession2taxid.gz .
  cp ${BASEDIR}/${DATE}/${SUBTAXDIR}/nodes.dmp .
  cp ${BASEDIR}/${DATE}/${SUBTAXDIR}/names.dmp .

fi

for i in ${LISTARRAY[@]}; do

  COUNT=$(find . -name "*${i}*" | wc -l)

  if [ "$COUNT" -gt "0" ]; then
    ${NCBIBLAST} blastdbcmd -dbtype prot -db ${i} -entry all -out ${i}.fa
  fi

  if [ -f "${i}.fa" ]; then
    EXTRA=""
    if [ "$TAXON" -ne "0" ]; then
      EXTRA="--taxonmap prot.accession2taxid.gz --taxonnodes nodes.dmp --taxonnames names.dmp"
    fi
    ${DIAMOND} diamond makedb --in ${i}.fa --db ${i} $EXTRA
  fi

  if [ -f "${i}.dmnd" ]; then
    rm ${i}.fa
  fi

  echo "Done ${i}"

done
