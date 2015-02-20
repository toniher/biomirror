import sys
import subprocess

def main(argv):

		p = subprocess.Popen("blastdbcmd -dbtype prot -entry "+argv[1]+" -db "+argv[0]+", stdout=subprocess.PIPE, shell=True)
		(output, err) = p.communicate()

		print output

if __name__ == "__main__":
		main(sys.argv[1:])

