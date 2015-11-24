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
        database = "xxx"

        configfile = "config.json"

        if sys.argv[2] :
                configfile = sys.argv[2]

        with open(configfile) as json_data_file:
                data = json.load(json_data_file)
        
        if data.has_key("mysql"):
                if data["mysql"].has_key("db"):
                        database = data["mysql"]["db"]
                if data["mysql"].has_key("host"):
                        host = data["mysql"]["host"]
                if data["mysql"].has_key("user"):
                        user = data["mysql"]["user"]
                if data["mysql"].has_key("password"):
                        pwd = data["mysql"]["password"]

        db=MySQLdb.connect(host=host,user=user,
                  passwd=pwd,db=database)
        
        
        cursor = db.cursor()

        cursor.execute("DROP TABLE IF EXISTS goataxon")
        sql = """CREATE TABLE `goataxon` (
                `UniProtKB-AC` varchar(25),
                `Taxon` int(12),
                key `UNIPROT` (`UniProtKB-AC`),
                key `Taxon` (`Taxon`)
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

                        taxon = row[5].replace("taxon:", "")

                        cursor.execute('INSERT INTO goataxon VALUES("'+row[0]+'", "'+taxon+'")')
                        i = i+1
                        if (i == limit):
                                i=0
                                db.commit()
        
        db.commit()
        cursor.close
        

if __name__ == "__main__":
        main(sys.argv[1:])
