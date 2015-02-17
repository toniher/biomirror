import sys
import os
import sqlite3
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file
		sqliteDB = 'testseq'
		conn = sqlite3.connect( sqliteDB )

		c = conn.cursor()
		# Create table
		c.execute('''DROP TABLE SEQS;''')
		c.execute('''CREATE TABLE SEQS ( id varchar(32) PRIMARY KEY, seq text )''')

		batch = 1000;
		itera = 0

		handle = open( argv[0], "r")
		for record in SeqIO.parse(handle, "fasta") :
				c.execute("INSERT INTO SEQS VALUES ('" + str(record.id) + "', '" + str(record.seq) + "' )")
				itera = itera + 1
				if itera > batch :
						conn.commit()
						itera = 0
		
		if itera > 0:
				conn.commit()

		handle.close()
		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])