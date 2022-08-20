CREATE DATABASE IF NOT EXISTS `biomirror`; 
USE `biomirror`;
DROP TABLE IF EXISTS `idmapping`;
CREATE TABLE `idmapping` ( `uniprot` varchar(16) NOT NULL DEFAULT '', `db` varchar(24) NOT NULL DEFAULT '', `external` varchar(72) NOT NULL DEFAULT '', KEY `index_uniprot` (`uniprot`), KEY `index_db` (`db`), KEY `index_external` (`external`) ) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;
