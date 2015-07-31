#!/usr/bin/env python
import py2neo
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

pp = pprint.PrettyPrinter(depth=6)

opts=parser.parse_args()

logging.basicConfig(level=logging.WARNING)

graph = py2neo.Graph()
graph.bind("http://localhost:7474/db/data/")
batch = py2neo.batch.PushBatch(graph)

pp.pprint(batch)

relationshipmap={}

def create_go_term(line):
	if(line[6]=='1'):
		relationshipmap[line[0]]=line[1]
	goid = line[0]
	goacc = line[3]
	gotype = line[2]
	goname = line[1]

	term = py2neo.Node("GO_TERM")
	term.cast( {
		"id": goid, "acc": goacc, "term_type": gotype, "name": goname
	})

	#term.labels.add("GO_TERM")
	
	term.bind(graph.uri+"/node/"+goid)
	pp.pprint(term)
	
	term.push()
	#batch.append( term )
	
	return True


logging.info('creating terms')
reader = csv.reader(open(opts.termfile),delimiter="\t")
iter = 0
for row in reader:
	create_go_term(row)
	iter = iter + 1
	if ( iter > 5000 ):
		# batch.push()
		iter = 0


# batch.push()

