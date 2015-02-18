import sys
import os

def main(argv):
		os.system("samtools faidx "+argv[0])

if __name__ == "__main__":
                main(sys.argv[1:])

