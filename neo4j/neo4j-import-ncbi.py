#!/usr/bin/env python
from py2neo import neo4j
import csv
import shutil
import logging
import argparse
import pandas
import sys
from pprint import pprint

parser = argparse.ArgumentParser()
parser.add_argument("nodes",
                    help="The nodes.dmp file")
parser.add_argument("names",
                    help="The names.dmp file")

opts=parser.parse_args()

logging.basicConfig(level=logging.WARNING)

db = neo4j.GraphDatabaseService()
batch = neo4j.WriteBatch(db)

parentid={}

def create_taxid(line, number):
	taxid = line[0]
	rank = line[2]

	batch.get_or_create_indexed_node( "TAXID", "id", taxid, {
	    "id": taxid, "rank": rank
	})
	
	parentid[taxid] = line[1]

	return True

def add_labels_to_submitted( listnodes, label ):
	for node in listnodes :
		batch.add_labels( node, label )
	
	batch.submit()
	batch.clear()

logging.info('creating nodes')
reader = pandas.read_csv(opts.nodes, iterator=True, index_col=False, chunksize=1, engine='c',header=None, delimiter="\s*\|\s*")
iter = 0
numberiter = 0
for row in reader:
	rowlist = row.values.tolist()
	create_taxid(rowlist[0], numberiter)
	numberiter = numberiter + 1
	iter = iter + 1
	if ( iter > 5000 ):
		submitted = batch.submit()
		batch.clear()
		add_labels_to_submitted( submitted, "TAXID" )

		iter = 0

submitted = batch.submit()
batch.clear()
add_labels_to_submitted( submitted, "TAXID" )


relation = db.get_or_create_index(neo4j.Relationship, "Relation")
logging.info('adding relationships')
iter = 0
numberiter = 0

taxid_node = db.get_or_create_index(neo4j.Node, "TAXID")

for key in parentid:

	parent_taxid = parentid[key]
	matches_parent = taxid_node.get("id", parent_taxid)
	matches_child = taxid_node.get("id", key)
	
	nodeparent = db.node( matches_parent[0]._id )
	nodechild = db.node( matches_child[0]._id )

	batch.get_or_create_path( nodechild, "has_parent", nodeparent )
	numberiter = numberiter + 1
	iter = iter + 1
	if ( iter > 5000 ):
		batch.submit()
		batch.clear()
		iter = 0

batch.submit()

logging.info('adding name info')
reader = pandas.read_csv(opts.names, iterator=True, index_col=False, chunksize=1, engine='c',header=None, delimiter="\s*\|\s*")

iter = 0
taxidsave = 1
scientific = ''
names = []

for row in reader:
	rowlist = row.values.tolist()
	taxid = int(rowlist[0][0])
	
	# If different, let's save
	if taxid != taxidsave :
		matches = taxid_node.get("id", taxidsave)
		ncbinode = db.node(matches[0]._id)
		batch.set_property( ncbinode, 'scientific_name', scientific )
		batch.add_to_index( neo4j.Node, "SCIENTIFIC", "scientific_name", scientific , ncbinode )
		batch.set_property( ncbinode, 'name', names )
		for n in names:
			batch.add_to_index(neo4j.Node, "NAME", "name", n, ncbinode)
		taxidsave = taxid
		names = []
		scientific = ''
	
		iter = iter + 1
		if ( iter > 5000 ):
			batch.submit()
			batch.clear()
			iter = 0

	if rowlist[0][3] == 'scientific name' :
		scientific = rowlist[0][1]
	
	names.append( str( rowlist[0][1] ) )


matches = taxid_node.get("id", taxidsave)
ncbinode = db.node(matches[0]._id)
batch.set_property( ncbinode, 'scientific_name', scientific )
batch.add_to_index( neo4j.Node, "SCIENTIFIC", "scientific_name", scientific , ncbinode )
batch.set_property( ncbinode, 'name', names )
for n in names:
	batch.add_to_index(neo4j.Node, "NAME", "name", n, ncbinode)
batch.submit()

batch.clear()




