#DIR of parts
DIR=$1

for file in $DIR/*
do
	echo $file
        /data/soft/neo4j-community-2.3.3/bin/neo4j-shell -file $file >> syn.out 2>> syn.err
done
