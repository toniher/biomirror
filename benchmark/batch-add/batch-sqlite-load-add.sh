DROP TABLE IF EXISTS SEQS;
CREATE TABLE SEQS ( id varchar(32) PRIMARY KEY, seq text );
.mode csv
.separator "\t"
.import $CSVFILE SEQS

