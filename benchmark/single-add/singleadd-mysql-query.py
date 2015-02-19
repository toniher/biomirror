import sys
import os
import MySQLdb
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file
		myDB = 'test'
		myUser = 'toniher'

		conn = MySQLdb.connect(host="localhost", # your host, usually localhost
				user=myUser, # your username
				db=myDB) # name of the data base
				
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
		
		c.execute("SELECT seq from SEQS where id='"+checkID+"'" )
		data = c.fetchone()
		for row in  data :
				print row
				
		c.execute("SELECT seq from SEQS where id='"+str(argv[1])+"'" )
		data = c.fetchone()
		for row in  data :
				print row

				
		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])
