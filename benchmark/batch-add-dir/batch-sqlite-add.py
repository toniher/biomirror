import sys
import os
import sqlite3
from Bio import SeqIO
from os import listdir
from os.path import isfile, join

def main(argv):

		# Put stuff in JSON config file
		sqliteDB = '../datasets/testseq'
		conn = sqlite3.connect( sqliteDB )

		c = conn.cursor()
		# Create table
		c.execute('''DROP TABLE IF EXISTS SEQS;''')
		c.execute('''CREATE TABLE SEQS ( id varchar(32) PRIMARY KEY, seq text )''')

		batch = 1000

		onlyfiles = [ argv[0]+"/"+f for f in listdir(argv[0]) if isfile(join(argv[0],f)) ]
		
		for fastafile in onlyfiles:
		
			itera = 0

			handle = open( fastafile, "r")
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
