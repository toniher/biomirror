Scripts for importing NCBI Taxonomy and GeneOntology data to Neo4j

Versions for Py2neo 1.6 and Py2neo 2.x

* neo4j-go.py, neo4j2-go.py
    * http://www.geneontology.org/GO.downloads.database.shtml (mysql dump files)
	* Argument files: term.txt, term_definition.txt, term2term.txt
* neo4j-ncbi.py, neo4j2-ncbi.py
	* ftp://ftp.ncbi.nih.gov/pub/taxonomy/
	* Argument files: nodes.dmp, names.dmp

* cypher-query.shell (queries to speed up relationships addition, to be used with: https://github.com/jexp/neo4j-shell-tools )

