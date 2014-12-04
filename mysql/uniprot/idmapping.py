import sys
import os
import os.path
import csv
import MySQLdb

def main(argv):
        if len(sys.argv) < 2:
                sys.exit()

        host = "xxx"
        user = "xxx"
        pwd = "xxx"
        database = sys.argv[2]
        
        db=MySQLdb.connect(host=host,user=user,
                  passwd=pwd,db=database)
        
        
        cursor = db.cursor()

        cursor.execute("DROP TABLE IF EXISTS idmapping")
        sql = """CREATE TABLE `idmapping` (
  `UniProtKB-AC` varchar(25) DEFAULT NULL,
  `ID_type` varchar(20) DEFAULT NULL,
  `ID` varchar(50) DEFAULT NULL,
  KEY `UNIPROT` (`UniProtKB-AC`),
  KEY `TYPE` (`ID_type`),
  KEY `ID` (`ID`)
) ENGINE=MyISAM;"""
        cursor.execute(sql)
    
        cursor.execute("SET autocommit=0;")
        cursor.execute("SET unique_checks=0;")
        cursor.execute("SET foreign_key_checks=0;")

        i = 0
        limit = 10000

        with open(sys.argv[1],'r') as f:
                reader=csv.reader(f,delimiter='\t')
                for row in reader:
                        if ( row[0].startswith('!') ): #Avoid row with !
                                continue

                        cursor.execute('INSERT INTO idmapping VALUES("'+row[0]+'", "'+row[1]+'", "'+row[2]+'")')
                        i = i+1
                        if (i == limit):
                                i=0
                                db.commit()
        
        db.commit()
        cursor.close
        

if __name__ == "__main__":
        main(sys.argv[1:])
