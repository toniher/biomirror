#!/usr/bin/env python

import sys
from Bio import SeqIO

def main(argv):

		
		handle = open(argv[0], "rU")
		writefile = open(argv[1], "w")
		
		arrayfasta = {}
		
		for record in SeqIO.parse(handle, "fasta") :
				arrayfasta[record.id] = 0
		handle.close()

		handle = open(argv[0], "rU")
		for record in SeqIO.parse(handle, "fasta") :
				key = record.id
				if arrayfasta[key] == 0:
					writefile.write( str( ">" + key + "\n" + record.seq +"\n" ) )
					arrayfasta[key] = 1
					
		handle.close()
				
		writefile.close()
		
		return True

if __name__ == "__main__":
		main(sys.argv[1:])
