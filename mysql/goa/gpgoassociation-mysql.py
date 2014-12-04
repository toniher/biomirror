import sys
import os
import os.path
import csv
import MySQLdb
        

def main(argv):
        if len(sys.argv) < 2:
                sys.exit()
        
        host = "localhost"
        user = "xxx"
        pwd = "xxx"
        database = sys.argv[2]
        
        db=MySQLdb.connect(host=host,user=user,
                  passwd=pwd,db=database)
        
        
        cursor = db.cursor()

        cursor.execute("DROP TABLE IF EXISTS goassociation")
        sql = """CREATE TABLE `goassociation` (
                `UniProtKB-AC` varchar(25),
                `GO` varchar(20),
                key `UNIPROT` (`UniProtKB-AC`),
                key `GO` (`GO`)
                )ENGINE=MyISAM ;"""
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
                        #print row[0]+"-"+row[1]+"\n"
                        cursor.execute('INSERT INTO goassociation VALUES("'+row[1]+'", "'+row[3]+'")')
                        i = i+1
                        if (i == limit):
                                i=0
                                db.commit()
        
        db.commit()
        cursor.close        


if __name__ == "__main__":
        main(sys.argv[1:])
