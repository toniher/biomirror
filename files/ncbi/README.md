Several scripts for downloading and indexing [NCBI datasets](https://ftp.ncbi.nlm.nih.gov/blast/db/) intended to be used with NCBI BLAST or similar programs (e.g. [DIAMOND](https://github.com/bbuchfink/diamond) as well).

* Download formatted NCBI databases:

```
bash download-ncbi.sh ../conf/ncbi.json ../conf/ncbi-files.txt
```

You can see a list of available NCBI datasets to populate a ```ncbi-files.txt``` with:

```
singularity exec -e ncbi/blast:2.10.1 update_blastdb.pl --showall
```
