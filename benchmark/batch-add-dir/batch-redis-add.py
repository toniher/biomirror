import sys
import os
import redis
from Bio import SeqIO
from os import listdir
from os.path import isfile, join

def main(argv):

		# Put stuff in JSON config file

		r=redis.Redis()

		r.flushdb()
		batch = 1000

		onlyfiles = [ argv[0]+"/"+f for f in listdir(argv[0]) if isfile(join(argv[0],f)) ]
		
		for fastafile in onlyfiles:
		
			itera = 0
			pipeline=r.pipeline()
			handle = open( fastafile, "r")
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
