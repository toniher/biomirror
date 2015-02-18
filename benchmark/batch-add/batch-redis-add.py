import sys
import os
import redis
from Bio import SeqIO


def main(argv):

		# Put stuff in JSON config file

		r=redis.Redis()  

		batch = 1000
		itera = 0

		r.flushdb()

		pipeline=r.pipeline()
		handle = open( argv[0], "r")
		for record in SeqIO.parse(handle, "fasta") :
				pipeline.set( str( record.id ), str( record.seq ) )
				itera = itera + 1
				if itera > batch :
					pipeline.execute()
					itera = 0
		
		if itera > 0 :
				pipeline.execute()

		handle.close()


if __name__ == "__main__":
		main(sys.argv[1:])
