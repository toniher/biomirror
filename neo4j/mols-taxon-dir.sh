#DIR of parts
DIR=$1

for file in $DIR/*
do
	echo $file
	echo -e "id\ttaxon:int" |cat - $file > /data/toniher/tempfile && mv /data/toniher/tempfile $file
	echo "import-cypher -b 10000 -d\"\t\" -i $file -o /data/toniher/out MATCH (c:MOL {id:{id}}), (p:TAXID {id:{taxon}}) CREATE (c)-[:has_taxon]->(p)" > /data/toniher/script
        /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
done


