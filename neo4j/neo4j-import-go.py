#!/usr/bin/env python
from py2neo import neo4j
import csv
import shutil
import logging
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("termfile",
                    help="The term.txt file as downloaded from the gene ontology site")
parser.add_argument("termdeffile",
                    help="The term_definition.txt file as downloaded from the gene ontology site")
parser.add_argument("term2termfile",
                    help="The term2term.txt file as downloaded from the gene ontology site")

opts=parser.parse_args()

logging.basicConfig(level=logging.WARNING)

db = neo4j.GraphDatabaseService()
batch = neo4j.WriteBatch(db)

relationshipmap={}

def create_go_term(line):
	if(line[6]=='1'):
		relationshipmap[line[0]]=line[1]
	goid = line[0]
	goacc = line[3]
	gotype = line[2]
	goname = line[1]

	batch.get_or_create_indexed_node( "GO_ID", "id", goid, {
	    "id": goid, "acc": goacc, "term_type": gotype, "name": goname
	})
	
	return True

def add_labels_to_submitted( listnodes, label ):
	for node in listnodes :
		batch.add_labels( node, label )
	
	batch.submit()
	batch.clear()

def add_index_to_submitted( listnodes, index, key ):

	
	for node in listnodes :
		list_props = db.get_properties( node )
		batch.add_to_index( neo4j.Node, index, key, list_props[0][key], node )
	
	batch.submit()
	batch.clear()

logging.info('creating terms')
reader = csv.reader(open(opts.termfile),delimiter="\t")
iter = 0
for row in reader:
	create_go_term(row)
	iter = iter + 1
	if ( iter > 5000 ):
		submitted = batch.submit()
		batch.clear()
		add_labels_to_submitted( submitted, "GO_TERM" )
		add_index_to_submitted( submitted, "GO_TERM", "acc")
		iter = 0

submitted = batch.submit()
batch.clear()
add_labels_to_submitted( submitted, "GO_TERM" )
add_index_to_submitted( submitted, "GO_TERM", "acc")


id_node = db.get_or_create_index(neo4j.Node, "GO_ID")

logging.info('adding definitions')
reader = csv.reader(open(opts.termdeffile),delimiter="\t")
iter = 0
for row in reader:
	matches = id_node.get("id", row[0])
	term = db.node(matches[0]._id)
	batch.set_property(term, 'definition', row[1])
	batch.add_to_index( neo4j.Node, "GO_TYPE", "term_type", term["term_type"], term )
	iter = iter + 1
	if ( iter > 5000 ):
		batch.submit()
		batch.clear()
		iter = 0
		
batch.submit()
batch.clear()

relation = db.get_or_create_index(neo4j.Relationship, "Relation")
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


