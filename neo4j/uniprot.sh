# Base entries
cut -f 1,3,5,6 gp_information.goa_uniprot | perl -F'\t' -lane ' if ($F[0]!~/^\!/ ) { $F[1]=~s/\"/\\"/g; print join( "\t", @F[0..2] ); } ' > gp_information.goa_uniprot.base

cut -f 1,2,3 gp_information.goa_uniprot.base | perl -F'\t' -lane ' if ($F[2]=~/^protein/ ) { print $_; } ' > gp_information.goa_uniprot.protein

python neo4j2-synonyms-add-from-redis.py /data/db/go/goa/gp_information.goa_uniprot.protein > /data/db/go/goa/gp_information.goa_uniprot.extra

nohup ./mols-dir.sh


# Adding relationships to Taxon
cut -f 1,6 gp_information.goa_uniprot | perl -F'\t' -lane ' if ($F[0]!~/^\!/ && $F[1]=~/^taxon/ ) { my $id=$F[0]; my $tax=$F[1]; $tax=~s/taxon\://g; print $id, "\t", $tax; } ' > gp_information.goa_uniprot.reduced

nohup ./mols-taxon-dir.sh


# Adding relationships to GO
cut -f 1,2,3,4,5,6 gp_association.goa_uniprot | perl -F'\t' -lane ' if ($F[0]!~/^\!/ && $F[0]=~/^UniProt/ ) { print join("\t", @F[1..5]); } '  > gp_association.goa_uniprot.reduced

nohup ./mols-go-dir.sh

