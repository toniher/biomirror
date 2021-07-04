# Uniprot

* ID mapping
	* Source ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz
	* ```python idmapping.py idmapping.dat```
	* TABLE: ```idmapping``` 
	* Before uploading this file to a  MySQL server, we suggest to proccess it to reduce its redundancy and drop entries with too short IDs (check Spark directory for a suggested solution).

Spark (more performant version) in *Spark* subdirectory in 2 folders above.
