cd $1
cat *.sql | mysql -uroot -pxxx $2
mysqlimport -uroot -pxxx -L $2 *.txt
