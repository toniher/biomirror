import sys
import os
import redis
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file

		r=redis.Redis()  

		batch = 1000;
		itera = 0

		checkID =  ""

		pipeline=r.pipeline()
		handle = open( argv[0], "r")
		for record in SeqIO.parse(handle, "fasta") :
				pipeline.set( str( record.id ), str( record.seq ) )
				checkID = str( record.id )
				itera = itera + 1
				if itera > batch :
					pipeline.execute()
					itera = 0
		
		if itera > 0 :
				pipeline.execute()

		handle.close()
		
		seqDoc1 = r.get( checkID )
		seqDoc2 = r.get( argv[1] )
		print seqDoc1.seq
		print seqDoc2.seq


if __name__ == "__main__":
		main(sys.argv[1:])
