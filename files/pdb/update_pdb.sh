#!/bin/sh

# Update PDB and also formatted derived data

OUTPUT=/nfs/db/pdb
BLASTPATH=/software/bi/el7.2/version/ncbi-blast+/ncbi-blast-2.10.1+/bin
BLASTVER=4

DATE=`date +%Y-%m-%d`

cd $OUTPUT/data/structures/divided
rsync -rlpt -v -z --delete --port=33444 rsync.rcsb.org::ftp_data/structures/divided/pdb ./pdb

cd $OUTPUT/derived_data
rsync -rlpt -v -z --delete --port=33444 rsync.rcsb.org::ftp_derived/ .

mkdir -p $OUTPUT/derived_data_format/blast/$DATE
cp $OUTPUT/derived_data/pdb_seqres.txt $OUTPUT/derived_data_format/blast/$DATE
cd $OUTPUT/derived_data_format/blast/$DATE

${BLASTPATH}/makeblastdb -dbtype prot -parse_seqids -blastdb_version $BLASTVER -in pdb_seqres.fa

# cd $OUTPUT/derived_data_format/blast
# ln -s $DATE latest
