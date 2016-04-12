#!/usr/bin/env python

import csv
import logging
import argparse
import sys
import os.path
from pprint import pprint


parser = argparse.ArgumentParser()
parser.add_argument("info",
                    help="The info file")
parser.add_argument("dirout",
                    help="Where to place files")

opts=parser.parse_args()

logging.basicConfig(level=logging.ERROR)


numiter = 1000000

synonyms = {}

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

def process_names( names ):

	namestr = ""
	
	for i in xrange( 0 ,len(names)):
		names[i] = '"' + names[i] + '"'

	namestr = "[" + ",".join(names) + "]"

	return namestr


def prepare_synonym( molid, item ):
	
	array_names = process_names ( item )

	statement = molid+"\t"+array_names+"\n"
	return statement

def process_synonyms( synonyms, itervar ):
	
	
	fo = open( opts.dirout + "/" + os.path.basename( opts.info ) + "-" + str(itervar) , "wb")
	
	fo.write( "id\tsynonyms\n" )
	
	for mol in synonyms.keys():
		statement = prepare_synonym( mol, synonyms[ mol ] )
		fo.write( statement )

	fo.close()

logging.info('storing synonyms info')
reader =  csv.reader(open(opts.info),delimiter="\t")


itervar = 0

for row in reader:
	add_synonym(row)
	
	if ( len( synonyms ) > numiter  ) :
		process_synonyms( synonyms, itervar )
		synonyms = {}
		itervar = itervar + 1



