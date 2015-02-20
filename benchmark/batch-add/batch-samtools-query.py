import sys
import subprocess

def main(argv):

		p = subprocess.Popen("samtools faidx "+argv[0]+" "+argv[1], stdout=subprocess.PIPE, shell=True)
		(output, err) = p.communicate()

		print output

if __name__ == "__main__":
		main(sys.argv[1:])
