drop table if exists `gene_info`;
CREATE TABLE `gene_info` (
  `tax_id` int(11) NOT NULL default '0',
  `GeneID` int(11) NOT NULL default '0',
  `Symbol` varchar(16) NOT NULL default '',
  `LocusTag` varchar(16) NOT NULL default '',
  `Synonyms` varchar(16) NOT NULL default '',
  `dbXrefs` varchar(16) NOT NULL default '',
  `chromosome` varchar(16) NOT NULL default '',
  `map_location` varchar(16) NOT NULL default '',
  `description` text NOT NULL default '',
  `type_of_gene` varchar(16) NOT NULL default '',
  `Symbol_from_nomenclature_authority` varchar(16) NOT NULL default '',
  `Full_name_from_nomenclature_authority` varchar(16) NOT NULL default '',
  `Nomenclature_status` varchar(16) NOT NULL default '',
  `Other_designations` varchar(16) NOT NULL default '',
  `Modification_date` varchar(16) NOT NULL default '',
  KEY `index_geneid` (`GeneID`),
  KEY `index_symbol` (`Symbol`),
  KEY `index_tax_id` (`tax_id`)
) ENGINE=MyISAM;

drop table if exists `gene2accession`;
CREATE TABLE `gene2accession` (
`tax_id` int(11) NOT NULL default '0',
`GeneID` int(11) NOT NULL default '0',
`status` varchar(16) NOT NULL default '',
`RNA_nucleotide_accession` varchar(16) NOT NULL default '',
`RNA_nucleotide_gi` varchar(16) NOT NULL default '',
`protein_accession` varchar(16) NOT NULL default '',
`protein_gi` varchar(16) NOT NULL default '',
`genomic_nucleotide_accession` varchar(255) NOT NULL default '',
`genomic_nucleotide_gi` varchar(16) NOT NULL default '', 
`start_position` varchar(16) NOT NULL default '',
`end_positon` varchar(16) NOT NULL default '',
`orientation` varchar(16) NOT NULL default '',
`assembly` varchar(16) NOT NULL default '',
KEY `index_geneid` (`GeneID`),
KEY `index_accession` (`protein_accession`),
KEY `index_protein_gi` (`protein_gi`),
KEY `index_genomic_nucleotide_gi` (`genomic_nucleotide_gi`),
KEY `index_RNA_nucleotide_gi` (`RNA_nucleotide_gi`),
KEY `index_tax_id` (`tax_id`)
) ENGINE=MyISAM;


