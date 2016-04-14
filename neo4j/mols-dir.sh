#DIR of parts
DIR=/data/db/go/goa/mol

mkdir -p $DIR; cd $DIR; split -l 10000000 ../gp_information.goa_uniprot.extra gp_information.goa_uniprot.extra

echo "Modify files"

for file in $DIR/*
do
	echo -e "id\tname\ttype\tsynonyms:string_array" |cat - $file > /data/toniher/tempfile && mv /data/toniher/tempfile $file
done

echo "CREATE CONSTRAINT ON (n:MOL) ASSERT n.id IS UNIQUE;" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
echo "CREATE INDEX ON :MOL(synonyms);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
echo "CREATE INDEX ON :MOL(name);" > /data/toniher/script 
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
echo "CREATE INDEX ON :MOL(type);" > /data/toniher/script
/data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err

echo "Neo4j importing"

for file in $DIR/*
do
	echo $file
	echo "import-cypher -b 10000 -d\"\t\" -i $file -o /data/toniher/out CREATE (n:MOL { id:{id}, name:{name}, type:{type}, synonyms: { synonyms } })" > /data/toniher/script
        /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file /data/toniher/script >> syn.out 2>> syn.err
done

