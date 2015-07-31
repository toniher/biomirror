#!/usr/bin/env python
import py2neo
from py2neo.packages.httpstream import http
from py2neo.cypher import cypher_escape

import csv
import shutil
import logging
import argparse
import pprint

parser = argparse.ArgumentParser()
parser.add_argument("termfile",
                    help="The term.txt file as downloaded from the gene ontology site")
parser.add_argument("termdeffile",
                    help="The term_definition.txt file as downloaded from the gene ontology site")
parser.add_argument("term2termfile",
                    help="The term2term.txt file as downloaded from the gene ontology site")

opts=parser.parse_args()

logging.basicConfig(level=logging.WARNING)

graph = py2neo.Graph()
graph.bind("http://localhost:7474/db/data/")

relationshipmap={}

http.socket_timeout = 9999

tx = graph.cypher.begin()

label = "GO_TERM"

idxout = graph.cypher.execute("CREATE CONSTRAINT ON (n:"+label+") ASSERT n.acc IS UNIQUE")


def create_go_term(line):
	if(line[6]=='1'):
		relationshipmap[line[0]]=line[1]
	goid = line[0]
	goacc = line[3]
	gotype = line[2]
	goname = line[1]

	statement = "CREATE (n:"+label+" { id : "+goid+", acc : \""+goacc+"\", name: \""+goname+"\" })"
	print statement
	
	return statement


logging.info('creating terms')
reader = csv.reader(open(opts.termfile),delimiter="\t")
iter = 0

for row in reader:
	statement = create_go_term(row)
	tx.append(statement)
	
	iter = iter + 1
	if ( iter > 5000 ):
		tx.process()
		iter = 0

tx.process()
tx.commit()

idxout = graph.cypher.execute("CREATE INDEX ON :"+label+"(id)")

print idxout
tx = graph.cypher.begin()

logging.info('adding definitions')
reader = csv.reader(open(opts.termdeffile),delimiter="\t")
iter = 0
for row in reader:
	
	params = {}
	params["definition"] = row[1]
	statement = "MATCH (n { id: "+row[0]+" }) SET n += "+params+" RETURN 1"
	tx.append(statement)

	iter = iter + 1
	if ( iter > 5000 ):
		tx.process()
		tx.commit()
		iter = 0

tx.process()
tx.commit()

# relation = db.get_or_create_index(neo4j.Relationship, "Relation")
logging.info('adding relationships')
reader = csv.reader(open(opts.term2termfile),delimiter="\t")
iter = 0
for row in reader:

	matches_parent = id_node.get("id", row[2])
	matches_child = id_node.get("id", row[3])
	
	nodeparent = db.node( matches_parent[0]._id )
	nodechild = db.node( matches_child[0]._id )
	
	batch.get_or_create_path( nodechild, relationshipmap[row[1]], nodeparent )
	iter = iter + 1
	if ( iter > 5000 ):
		batch.submit()
		batch.clear()
		iter = 0

batch.submit()




