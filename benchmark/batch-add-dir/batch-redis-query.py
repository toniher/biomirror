import sys
import os
import redis


def main(argv):

		# Put stuff in JSON config file

		r=redis.Redis()  
		seq = r.get( argv[0] );
		print seq

if __name__ == "__main__":
		main(sys.argv[1:])
