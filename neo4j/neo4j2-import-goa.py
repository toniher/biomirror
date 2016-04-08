#!/usr/bin/env python
import py2neo
from py2neo.packages.httpstream import http
from py2neo.cypher import cypher_escape
from multiprocessing import Pool

import httplib

import csv
import logging
import argparse
import sys
from pprint import pprint

httplib.HTTPConnection._http_vsn = 10
httplib.HTTPConnection._http_vsn_str = 'HTTP/1.0'

parser = argparse.ArgumentParser()
parser.add_argument("info",
                    help="The association file")

opts=parser.parse_args()

logging.basicConfig(level=logging.ERROR)

http.socket_timeout = 9999

numiter = 1000

graph = py2neo.Graph()
graph.bind("http://localhost:7474/db/data/")

label = "MOL"

# We keep no pool for relationship
tx = graph.cypher.begin()
 
# logging.info('adding relationships')
 # restart
reader =  csv.reader(open(opts.info),delimiter="\t")
 
iter = 0
 
for row in reader:
	
	if row[0].startswith( '!' ):
		continue

	dbid = str(row[0]).strip()
	
	if dbid != 'UniProt':
		continue

	molid = str(row[1]).strip()
	qual = str(row[2]).strip()
	goacc = str(row[3]).strip()
	dbref = str(row[4]).strip()
	evidence = str(row[5]).strip()
	
	statement = "MATCH (c:"+label+" {id:\""+molid+"\"}), (p:GO_TERM {acc:\""+goacc+"\"}) CREATE (c)-[:has_go { evidence: \""+evidence+"\", dbref: \""+dbref+"\", qualifier: \""+qual+"\" }]->(p)"
	
	tx.append(statement)
	
	iter = iter + 1
	if ( iter > numiter ):
		tx.process()
		tx.commit()
		tx = graph.cypher.begin()
		
		iter = 0
tx.process()
tx.commit()

