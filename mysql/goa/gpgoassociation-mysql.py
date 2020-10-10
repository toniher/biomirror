import sys
import os
import os.path
import csv
import MySQLdb
import json
import gzip
import pprint
import re


def main(argv):
    if len(sys.argv) < 2:
        sys.exit()

    host = "localhost"
    user = "xxx"
    pwd = "xxx"
    database = "xxx"

    configfile = "config.json"

    if sys.argv[2]:
        configfile = sys.argv[2]

    with open(configfile) as json_data_file:
        data = json.load(json_data_file)

    if "mysql" in data:
        if "db" in data["mysql"]:
            database = data["mysql"]["db"]
        if "host" in data["mysql"]:
            host = data["mysql"]["host"]
        if "user" in data["mysql"]:
            user = data["mysql"]["user"]
        if "password" in data["mysql"]:
            pwd = data["mysql"]["password"]

    db = MySQLdb.connect(host=host, user=user, passwd=pwd, db=database)

    cursor = db.cursor()

    cursor.execute("DROP TABLE IF EXISTS goassociation")
    sql = """CREATE TABLE `goassociation` (
            `DB` varchar(25),
            `ID` varchar(35),
            `qualifier` varchar(25) default NULL,
            `GO` varchar(20) default NULL,
            `REF` varchar(50) default NULL,
            `ECO` varchar(20) default NULL,
            `Date` date default NULL,
            key `DB` (`DB`),
            key `ID` (`ID`),
            key `qualifier` (`qualifier`),
            key `GO` (`GO`),
            key `REF` (`REF`),
            key `ECO` (`ECO`),
            key `Date` (`Date`),
            key `ID-GO` (`ID`, `GO`)
            ) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci ;"""
    cursor.execute(sql)

    cursor.execute("SET autocommit=0;")
    cursor.execute("SET unique_checks=0;")
    cursor.execute("SET foreign_key_checks=0;")

    i = 0
    limit = 10000

    pp = pprint.PrettyPrinter(depth=4)
    # Open gzipped file
    with gzip.open(sys.argv[1], 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for row in reader:
            # Avoid row with !
            if (row[0].startswith('!') or row[0].startswith('gpa')):
                continue

            date = row[8]
            if date.isdigit():
                result = re.search("(\d{4})(\d{2})(\d{2})", date )
                date = result.group(1)+"-"+result.group(2)+"-"+result.group(3)

            # cursor.execute('INSERT INTO goassociation VALUES("'+row[0]+'", "'+row[1]+'", "'+row[2]+'", "'+row[3]+'", "'+row[4]+'", "'+row[5]+'", "'+date+'" )')
            print("\t".join([row[0], row[1], row[2], row[3], row[4], row[5], date]))
            i = i+1
            if (i == limit):
                i = 0
                # db.commit()

    # db.commit()
    cursor.close


if __name__ == "__main__":
    main(sys.argv[1:])
