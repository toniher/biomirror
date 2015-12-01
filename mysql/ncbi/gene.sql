drop table if exists `gene_info`;
CREATE TABLE `gene_info` (
  `tax_id` int(11) NOT NULL default '0',
  `GeneID` int(11) NOT NULL default '0',
  `Symbol` varchar(16) NOT NULL default '',
  `LocusTag` varchar(16) NOT NULL default '',
  `Synonyms` varchar(16) NOT NULL default '',
  `chromosome` varchar(16) NOT NULL default '',
  `map_location` varchar(16) NOT NULL default '',
  `description` text NOT NULL default '',
  `type_of_gene` varchar(16) NOT NULL default ''
  KEY `index_geneid` (`GeneID`),
  KEY `index_symbol` (`Symbol`),
  KEY `index_tax_id` (`tax_id`)
) ENGINE=MyISAM;

drop table if exists `gene2accession`;
CREATE TABLE `gene2accession` (
`GeneID` int(11) NOT NULL default '0',
`RNA_nucleotide_gi` varchar(16) NOT NULL default '',
`protein_gi` varchar(16) NOT NULL default '',
`genomic_nucleotide_gi` varchar(16) NOT NULL default '', 
`start_position` varchar(16) NOT NULL default '',
`end_positon` varchar(16) NOT NULL default '',
`orientation` varchar(16) NOT NULL default '',
`assembly` varchar(16) NOT NULL default '',
KEY `index_geneid` (`GeneID`),
KEY `index_protein_gi` (`protein_gi`),
KEY `index_genomic_nucleotide_gi` (`genomic_nucleotide_gi`),
KEY `index_RNA_nucleotide_gi` (`RNA_nucleotide_gi`)
) ENGINE=MyISAM;

drop table if exists `gene_group`;
CREATE TABLE `gene_group` (
  `GeneID` int(11) NOT NULL default '0',
  `relationship` varchar(50) NOT NULL default '',
  `GeneID_match` int(11) NOT NULL default '0',
  KEY `index_geneid` (`GeneID`),
  KEY `index_relationship` (`relationship`),
  KEY `index_geneid_match` (`GeneID_match`)
) ENGINE=MyISAM;

drop table if exists `gene2pubmed`;
CREATE TABLE `gene2pubmed` (
  `GeneID` int(11) NOT NULL default '0',
  `PubmedID` int(11) NOT NULL default '0',
  KEY `index_geneid` (`GeneID`),
  KEY `index_pubmedid` (`PubmedID`)
) ENGINE=MyISAM;

drop table if exists `gene2go`;
CREATE TABLE `gene2go` (
  `GeneID` int(11) NOT NULL default '0',
  `GO` varchar(20) NOT NULL default '',
  `evidence` varchar(8) NOT NULL default '',
  KEY `index_geneid` (`GeneID`),
  KEY `index_go` (`GO`),
  KEY `index_evidence` (`evidence`)
) ENGINE=MyISAM;

drop table if exists `mim2gene_medgen`;
CREATE TABLE `mim2gene_medgen` (
  `MIM` int(11) NOT NULL default '0',
  `GeneID` int(11) NOT NULL default '0',
  `mimtype` varchar(20) NOT NULL default '',
  `source` varchar(20) NOT NULL default '',
  `MedGenCUI` varchar(20) NOT NULL default '',
  `comment` text NOT NULL default '',
  KEY `index_mim` (`MIM`)
  KEY `index_geneid` (`GeneID`),
  KEY `index_type` (`mimtype`),
  KEY `index_source` (`source`),
  KEY `index_MedGenCUI` (`MedGenCUI`)
) ENGINE=MyISAM;

drop table if exists `gene2refseq`;
CREATE TABLE `gene2refseq` (
`GeneID` int(11) NOT NULL default '0',
`status` varchar(20) NOT NULL default '',
`RNA_nucleotide_acc` varchar(20) NOT NULL default '',
`RNA_nucleotide_gi` varchar(16) NOT NULL default '',
`protein_acc` varchar(20) NOT NULL default '',
`protein_gi` varchar(16) NOT NULL default '',
`genomic_nucleotide_acc` varchar(20) NOT NULL default '',
`genomic_nucleotide_gi` varchar(16) NOT NULL default '', 
KEY `index_geneid` (`GeneID`),
KEY `index_status` (`status`),
KEY `index_protein_acc` (`protein_acc`),
KEY `index_genomic_nucleotide_acc` (`genomic_nucleotide_acc`),
KEY `index_RNA_nucleotide_acc` (`RNA_nucleotide_acc`),
KEY `index_protein_gi` (`protein_gi`),
KEY `index_genomic_nucleotide_gi` (`genomic_nucleotide_gi`),
KEY `index_RNA_nucleotide_gi` (`RNA_nucleotide_gi`)
) ENGINE=MyISAM;


