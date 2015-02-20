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

		c.execute("SELECT seq from SEQS where id='"+str(argv[0])+"'" )
		data = c.fetchone()
		for row in  data :
				print row

		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])
