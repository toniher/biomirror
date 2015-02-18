import sys
import subprocess

def main(argv):

		p = subprocess.Popen("blastdbcmd -dbtype prot -entry "+argv[0]+" -db ../datasets/drosoph.aa.md5", stdout=subprocess.PIPE, shell=True)
		(output, err) = p.communicate()

		print output

if __name__ == "__main__":
                main(sys.argv[1:])

