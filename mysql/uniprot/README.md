# Uniprot

* ID mapping
	* Source: https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz
	* We rewrite the file to include UniProt ID as well:  ```python rewrite-IDmapping.py idmapping.dat > idmapping.proc.dat```
	* Then we can import into ```idmapping``` table with: ```bash run-idmapping.sh idmapping.proc.dat```

## NOTE 

* Before uploading this file to a  MySQL server, we suggest to proccess it to reduce its redundancy and drop entries with too short IDs (check *spark* directory for a suggested solution).
