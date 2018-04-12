# MySQL scripts

* Different scripts for uploading info. Since it uses Aria Engine, MariaDB must be used (change to MyISAM if using MySQL).


## Notes


Some problems that can be found

* Fixing table encodings 

    SELECT CONCAT("ALTER TABLE ", TABLE_SCHEMA, '.', TABLE_NAME," CONVERT TO CHARACTER SET latin1 COLLATE 'latin1_swedish_ci'") AS    ExecuteTheString
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA="biosql"



