import sys
import os
import couchdb

def main(argv):

		# Put stuff in JSON config file
		couchServer = 'http://localhost:5984/'
		couchDB = 'testseq'
		
		couch = couchdb.Server(couchServer)

		db = couch[couchDB]

		seqDoc = db.get( argv[0] )
		print seqDoc['seq']

if __name__ == "__main__":
		main(sys.argv[1:])