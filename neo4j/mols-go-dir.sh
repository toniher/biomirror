#DIR of parts
DIR=$1

for file in $DIR/*
do
	echo $file
	echo -e "id\tqualifier\tgoacc\tref\tevidence" |cat - $file > /data/toniher/tempfile && mv /data/toniher/tempfile $file
	echo "import-cypher -b 10000 -d\"\t\" -i $file -o /data/toniher/out MATCH (c:MOL {id:{id}}), (p:GO_TERM {acc:{goacc}}) CREATE (c)-[:has_go { evidence: {evidence}, ref: {ref}, qualifier: {qualifier} }]->(p)" > /data/toniher/script
        /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
done

echo "CREATE INDEX ON :has_go(evidence); CREATE INDEX ON :has_go(ref); CREATE INDEX ON :has_go(qualifier);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
