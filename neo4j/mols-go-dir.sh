#DIR of parts
DIR=/data/db/go/goa/molgoa

mkdir -p $DIR; cd $DIR; split -l 10000000 ../gp_association.goa_uniprot.reduced gp_association.goa_uniprot.reduced

echo "Modify files"

for file in $DIR/*
do
		echo -e "id\tqualifier\tgoacc\tref\tevidence" |cat - $file > /data/toniher/tempfile && mv /data/toniher/tempfile $file

done

echo "CREATE INDEX ON :has_go(evidence);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
echo "CREATE INDEX ON :has_go(ref);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
echo "CREATE INDEX ON :has_go(qualifier);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err


echo "Neo4j importing"

for file in $DIR/*
do
	echo $file
	echo "import-cypher -b 10000 -d\"\t\" -i $file -o /data/toniher/out MATCH (c:MOL {id:{id}}), (p:GO_TERM {acc:{goacc}}) CREATE (c)-[:has_go { evidence: {evidence}, ref: {ref}, qualifier: {qualifier} }]->(p)" > /data/toniher/script
        /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
done

