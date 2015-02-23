import sys
import os
import MySQLdb
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file
		myDB = 'test'
		myUser = 'root'
		myPass = argv[1]

		conn = MySQLdb.connect(host="localhost", # your host, usually localhost
				user=myUser, # your username
				db=myDB, # name of the data base
				passwd=myPass) 

		c = conn.cursor()
		# Create table
		c.execute('''CREATE TABLE SEQS ( id varchar(32) PRIMARY KEY, seq text )''')

		c.execute( "LOAD DATA INFILE '"+os.path.abspath( argv[0] )+"' INTO TABLE SEQS" )
		conn.commit()
		conn.close()


if __name__ == "__main__":
		main(sys.argv[1:])
