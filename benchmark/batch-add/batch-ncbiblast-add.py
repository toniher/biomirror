import sys
import os

def main(argv):
		os.system("makeblastdb -dbtype prot -in "+argv[0]+" -parse_seqids")

if __name__ == "__main__":
                main(sys.argv[1:])



