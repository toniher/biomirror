import sys
import os
import sqlite3
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file
		sqliteDB = 'testseq'
		conn = sqlite3.connect( sqliteDB )

		c = conn.cursor()

		batch = 1000;
		itera = 0
		
		checkID = ""

		handle = open( argv[0], "r")
		for record in SeqIO.parse(handle, "fasta") :
				c.execute("INSERT INTO SEQS VALUES ('" + str(record.id) + "', '" + str(record.seq) + "' )")
				checkID = str(record.id)
				itera = itera + 1
				if itera > batch :
						conn.commit()
						itera = 0
		
		if itera > 0:
				conn.commit()

		handle.close()
		
		
		for row in c.execute('SELECT seq from SEQS where id="'+checkID+'"') :
				print row[0]

		for row in c.execute('SELECT seq from SEQS where id="'+argv[1]+'"') :
				print row[0]
				
		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])
