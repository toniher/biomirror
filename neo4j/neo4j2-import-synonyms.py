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
                    help="The info file")

opts=parser.parse_args()

logging.basicConfig(level=logging.ERROR)

http.socket_timeout = 9999

numiter = 1000

graph = py2neo.Graph()
graph.bind("http://localhost:7474/db/data/")

label = "MOL"

synonyms = {}


def process_statement( statements ):
    
    tx = graph.cypher.begin()

    #print statements
    logging.info('proc sent')

    for statement in statements:
        #print statement
        tx.append(statement)

    tx.process()
    tx.commit()


poolnum = 7;

p = Pool(poolnum)

def add_synonym(line):
	molid = str(line[0]).strip()
	origin = str(line[1]).strip()
	name = str(line[2]).strip()
	

	if not molid in synonyms:
		synonyms[molid] = []
		synonyms[molid].append( molid )

	#print statement
	if origin in ["GI", "RefSeq", "UniProtKB-ID"] :
		synonyms[molid].append( name )

def process_names( array ):

	namestr = ""
	
	for i in xrange( 0 ,len(names)):
		names[i] = '"' + names[i] + '"'

	namestr = "[" + ",".join(names) + "]"

	return namestr


def prepare_synonym( molid, item ):
	
	array_names = process_names ( item )

	label = "MOL"
	statement = "MATCH (n:"+label+" { id:\""+molid+"\" } ) SET n.synonyms = "+array_names+" RETURN n "
	print statement

logging.info('storing synonyms info')
reader =  csv.reader(open(opts.info),delimiter="\t")


list_statements =  []
statements = []

for row in reader:
	add_synonym(row)


iter = 0
for mol in synonyms.keys():
	statement = prepare_synonym( mol, synonyms[ mol ] )
	statements.append( statement )
	iter = iter + 1
	if ( iter > numiter ):
		list_statements.append( statements )
		iter = 0
		statements = []

list_statements.append( statements )
res = p.map( process_statement, list_statements )
