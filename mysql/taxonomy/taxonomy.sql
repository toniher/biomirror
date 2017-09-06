CREATE TABLE `ncbi_names` (
  `tax_id` mediumint(11) unsigned NOT NULL default '0',
  `name_txt` varchar(255) NOT NULL default '',
  `unique_name` varchar(255) default NULL,
  `name_class` varchar(32) NOT NULL default '',
  KEY `tax_id` (`tax_id`),
  KEY `name_class` (`name_class`),
  KEY `name_txt` (`name_txt`)
);
CREATE TABLE `ncbi_nodes` (
  `tax_id` mediumint(11) unsigned NOT NULL default '0',
  `parent_tax_id` mediumint(8) unsigned NOT NULL default '0',
  `rank` varchar(32) default NULL,
  `embl_code` varchar(16) default NULL,
  `division_id` smallint(6) NOT NULL default '0',
  `inherited_div_flag` tinyint(4) NOT NULL default '0',
  `genetic_code_id` smallint(6) NOT NULL default '0',
  `inherited_GC_flag` tinyint(4) NOT NULL default '0',
  `mitochondrial_genetic_code_id` smallint(4) NOT NULL default '0',
  `inherited_MGC_flag` tinyint(4) NOT NULL default '0',
  `GenBank_hidden_flag` smallint(4) NOT NULL default '0',
  `hidden_subtree_root_flag` tinyint(4) NOT NULL default '0',
  `comments` varchar(255) default NULL,
  PRIMARY KEY  (`tax_id`),
  KEY `parent_tax_id` (`parent_tax_id`)
);
