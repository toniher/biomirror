import sys
import os
import sqlite3
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file
		sqliteDB = '../datasets/testseq'
		conn = sqlite3.connect( sqliteDB )
		
		c = conn.cursor()
		# Create table
		for row in c.execute('SELECT seq from SEQS where id="'+argv[0]+'"') :
				print row[0]

		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])
