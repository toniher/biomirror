#!/usr/bin/env python

import sys
from Bio import SeqIO

def main(argv):

		
		handle = open(argv[0], "rU")
		writefile = open(argv[1], "w")
		
		arrayfasta = {}
		
		for record in SeqIO.parse(handle, "fasta") :
				arrayfasta[record.id] = record.seq
		handle.close()
		
		for key in arrayfasta.keys():
				writefile.write( str( ">" + key + "\n" + arrayfasta[key] +"\n" ) )
		writefile.close()
		
		return True

if __name__ == "__main__":
		main(sys.argv[1:])
