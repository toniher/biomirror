#!/usr/bin/env python

import sys
from Bio import SeqIO

def main(argv):

		
		handle = open(argv[0], "rU")
		writefile = open(argv[1], "w")
		
		separator = "\t"
		if len(argv) > 2 and argv[2] is not None:
			separator = argv[2]

		for record in SeqIO.parse(handle, "fasta") :
				writefile.write( str( record.id + separator + record.seq +"\n" ) )
		handle.close()
				
		writefile.close()
		
		return True

if __name__ == "__main__":
		main(sys.argv[1:])
