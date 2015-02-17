import sys
import os
import hashlib
from Bio import SeqIO

def computeMD5hash(string, textconv):
		m = hashlib.md5()
		m.update(string.encode('utf-8'))
		if (textconv == 'base64'):
				return m.digest().encode('base64')[:-1]
		else:
				return m.hexdigest()


def main(argv):

		handle = open( argv[0], "r")
		for record in SeqIO.parse(handle, "fasta") :
				md5id = computeMD5hash( str( record.seq ), "hex" )
				print ">" + md5id
				print record.seq
		handle.close()


if __name__ == "__main__":
		main(sys.argv[1:])
