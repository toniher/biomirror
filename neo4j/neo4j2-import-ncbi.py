#!/usr/bin/env python
import py2neo
from py2neo.packages.httpstream import http
from py2neo.cypher import cypher_escape

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

http.socket_timeout = 9999

graph = py2neo.Graph()
graph.bind("http://localhost:7474/db/data/")

tx = graph.cypher.begin()

label = "TAXID"

parentid={}

def create_taxid(line, number):
    taxid = str(line[0]).strip()
    rank = line[2].strip()
    
    statement = "CREATE (n:"+label+" { id : "+taxid+", rank: \""+rank+"\" })"
    #print statement
    
    parentid[taxid] = line[1]
    
    return statement


logging.info('creating nodes')
reader = pandas.read_csv(opts.nodes, iterator=True, index_col=False, engine="c", chunksize=1, header=None, delimiter="|")
iter = 0
for row in reader:
    rowlist = row.values.tolist()
    statement = create_taxid(rowlist[0], iter)
    tx.append(statement)
    iter = iter + 1
    if ( iter > 5000 ):
        tx.process()
        tx.commit()
        tx = graph.cypher.begin()

        iter = 0

tx.process()
tx.commit()

idxout = graph.cypher.execute("CREATE INDEX ON :"+label+"(id)")
idxout = graph.cypher.execute("CREATE INDEX ON :"+label+"(rank)")


tx = graph.cypher.begin()


logging.info('adding relationships')
iter = 0

for key in parentid:

    parent_taxid = parentid[key]
    
    statement = "MATCH (c:"+label+" {id:"+str(key)+"}), (p:"+label+" {id:"+str(parent_taxid)+"}) CREATE (c)-[:has_parent]->(p)"
    #print statement

    tx.append(statement)

    iter = iter + 1
    if ( iter > 5000 ):
        tx.process()
        tx.commit()
        tx = graph.cypher.begin()
        
        iter = 0

tx.process()
tx.commit()

logging.info('adding name info')
reader = pandas.read_csv(opts.names, iterator=True, index_col=False, engine="c", chunksize=1, header=None, delimiter="|")

iter = 0
taxidsave = 1
scientific = ''
names = []

tx = graph.cypher.begin()

for row in reader:
    rowlist = row.values.tolist()
    taxid = int(rowlist[0][0])
    
    # If different, let's save
    if taxid != taxidsave :
        namestr = ""
        for n in names:
            namestr = namestr + '"' + n + '"'
        taxidsave = taxid
        namestr = "[" + namestr + "]"
        statement = "MATCH (n { id: "+str(taxidsave)+" }) SET n.scientific_name = '"+scientific+"', n.name = "+namestr+" RETURN 1"
        #print statement
        
        tx.append(statement)
        names = []
        scientific = ''
    
        iter = iter + 1
        if ( iter > 5000 ):
            tx.process()
            tx.commit()
            tx = graph.cypher.begin()
            
            iter = 0

	if rowlist[0][3] == 'scientific name' :
		scientific = rowlist[0][1].strip()
	
	names.append( str( rowlist[0][1] ).strip().replace('"', '\\"') )

tx.process()
tx.commit()

idxout = graph.cypher.execute("CREATE INDEX ON :"+label+"(scientific_name)")
idxout = graph.cypher.execute("CREATE INDEX ON :"+label+"(name)")




