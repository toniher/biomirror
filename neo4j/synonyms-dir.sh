#DIR of parts
DIR=$1

echo "CREATE INDEX ON :MOL(synonyms);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err

for file in $DIR/*
do
	echo $file
	echo "import-cypher -b 10000 -d\"\t\" -i $file -o /data/toniher/out MATCH (n:MOL {id:{id}}) set n.synonyms = {synonyms}" > /data/toniher/script
        parallel -j6 /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
done
