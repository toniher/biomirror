CREATE DATABASE IF NOT EXISTS `biomirror`; 
USE `biomirror`;
DROP TABLE IF EXISTS `idmapping`;
CREATE TABLE `idmapping` ( `uniprot` varchar(16) NOT NULL DEFAULT '', `db` varchar(24) NOT NULL DEFAULT '', `external` varchar(72) NOT NULL DEFAULT '' ) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
