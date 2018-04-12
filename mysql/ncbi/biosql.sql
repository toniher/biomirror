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
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

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
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gi2uniprot`;
CREATE TABLE `gi2uniprot` (
  `gi` varchar(16) NOT NULL default '',
  `uniprot` varchar(16) NOT NULL default '',
  PRIMARY KEY  (`gi`,`uniprot`),
  KEY `index_gi` (`gi`),
  KEY `index_uniprot` (`uniprot`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gene2go`;
CREATE TABLE `gene2go` (
`tax_id` int(11) NOT NULL default '0',
`GeneID` int(11) NOT NULL default '0',
`GO_ID` varchar(24) NOT NULL default '',
`Evidence` varchar(10) NOT NULL default '',
`Qualifier` varchar(24) NOT NULL default '',
`GO_term` varchar(255) NOT NULL default '',
`PubMed` varchar(255) NOT NULL default '',
`Category` varchar(16) NOT NULL default '',
KEY `index_geneid` (`GeneID`),
KEY `index_goid` (`GO_ID`),
KEY `index_evidence` (`Evidence`),
KEY `index_qualifier` (`Qualifier`),
KEY `index_category` (`Category`),
KEY `index_tax_id` (`tax_id`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gene2pubmed`;
CREATE TABLE `gene2pubmed` (
`tax_id` int(11) NOT NULL default '0',
`GeneID` int(11) NOT NULL default '0',
`PubMed_ID` int(11) NOT NULL default '0',
KEY `index_geneid` (`GeneID`),
KEY `index_pubmed_id` (`pubmed_id`),
KEY `index_tax_id` (`tax_id`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gene2refseq`;
CREATE TABLE `gene2refseq` (
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
`mature_peptide_accession` varchar(16) NOT NULL default '',
`mature_peptide_gi` varchar(16) NOT NULL default '',
`Symbol` varchar(16) NOT NULL default '',
KEY `index_geneid` (`GeneID`),
KEY `index_accession` (`protein_accession`),
KEY `index_protein_gi` (`protein_gi`),
KEY `index_genomic_nucleotide_gi` (`genomic_nucleotide_gi`),
KEY `index_RNA_nucleotide_gi` (`RNA_nucleotide_gi`),
KEY `index_mature_peptide_gi` (`mature_peptide_gi`),
KEY `index_symbol` (`Symbol`),
KEY `index_tax_id` (`tax_id`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gene_group`;
CREATE TABLE `gene_group` (
`tax_id` int(11) NOT NULL default '0',
`GeneID` int(11) NOT NULL default '0',
`relationship` varchar(32) NOT NULL default '',
`Other_tax_id` int(11) NOT NULL default '0',
`Other_GeneID` int(11) NOT NULL default '0',
KEY `index_geneid` (`GeneID`),
KEY `index_tax_id` (`tax_id`),
KEY `index_other_geneid` (`Other_GeneID`),
KEY `index_other_tax_id` (`Other_tax_id`),
KEY `index_relationship` (`relationship`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;

drop table if exists `gene_refseq_uniprotkb_collab`;
CREATE TABLE `gene_refseq_uniprotkb_collab` (
`NCBI_protein_accession` varchar(16) NOT NULL default '',
`UniProtKB_protein_accession` varchar(16) NOT NULL default '',
KEY `index_ncbi_protein_accession` (`NCBI_protein_accession`),
KEY `index_uniprotkb_protein_accession` (`UniProtKB_protein_accession`)
) ENGINE=Aria CHARACTER SET latin1 COLLATE latin1_swedish_ci;
