#!/usr/bin/env bash

set -ueo pipefail

BASEDIR=/db/ncbi/
CURRENT=`date +%Y%m`

DATE=${1:-${CURRENT}}

NCBIBLAST="singularity exec -e /software/bi/singularity/ncbi-blast/ncbi-blast-2.10.1.sif"
DIAMOND="singularity exec -e /software/bi/singularity/diamond/diamond-0.9.30.sif"

LISTDB=(cdd_delta env_nr landmark nr pdbaa refseq_protein swissprot tsa_nr)

if [ ! -d ${BASEDIR}/${DATE}/blastdb/db ]; then
  exit 1
fi

LOCATION=${BASEDIR}/${DATE}/blastdb/db

cd $LOCATION

for i in ${LISTDB[@]}; do

  COUNT=$(find . -name "*${i}*" | wc -l)

  if [ "$COUNT" -gt "0" ]; then
    ${NCBIBLAST} blastdbcmd -dbtype prot -db ${i} -entry all -out ${i}.fa
  fi

  if [ -f "${i}.fa" ]; then
    ${DIAMOND} diamond makedb --in ${i}.fa --db ${i}
  fi

  if [ -f "${i}.dmnd" ]; then
    rm ${i}.fa
  fi

  echo "Done ${i}"

done
