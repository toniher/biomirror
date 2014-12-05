#!/usr/bin/env perl

use warnings;
use strict;
use JSON qw( decode_json );
use LWP::Simple;
use Data::Dumper;

#Chrom apps
my @appsn = ('ncbi-blast');

#List of progs
my $listprogsfile = "/db/.scripts/indexes_record_aa.csv";

my %listprogs = getlistprogs($listprogsfile);

#Dir where ensembl release
my $dir = shift;

# Subdirs considered
my @dirarray = ('proteome');

#get config
my ($branch) = $dir =~/(release\-\d+)/;
my $pluginspath = "/db/ensembl/conf/".$branch.+"/public-plugins/ensembl/conf/ini-files";


my $emailbin = "~/bin/sendMsg.sh";

# Email Messages
my $subjsend = "Starting creating indexes for AA ENSEMBL files";
my $messagesend = "Please, be patient";

system ("$emailbin '$subjsend' '$messagesend'");



opendir(DIR, $dir) || die "Cannot open $dir";

my @listdir = grep {-d "$dir/$_" && $_!~/^\./} readdir(DIR);

closedir(DIR);

foreach my $indir (@listdir) {

	foreach my $ver (@dirarray) {

		if (-e "$dir/$indir/$ver/") {

			opendir(INDIR, "$dir/$indir/$ver/") || die "Cannot open $indir";

			my @listindir = grep {-f "$dir/$indir/$ver/$_" && $_!~/^LOG/ && $_!~/\.chrom\./} readdir(INDIR);
			
			# preprocess for chromosomes
			my $orgini = $indir;
			$orgini =~s/\s/_/g;

			my $chromosomes = getchromsREST($orgini);

			# indexing
			indexfiles("$dir/$indir/$ver", \@listindir, \%listprogs, $chromosomes, $ver);


			closedir(INDIR);
		}

	}

	#last; # Use for only testing one
}

# Email Messages
my $subjsend2 = "Finished creating indexes for AA ENSEMBL files";
my $messagesend2 = "Please, check that everything went well";

system ("$emailbin '$subjsend2' '$messagesend2'");



sub indexfiles {

	my $path = shift;
	my $listinfiles = shift;
	my $listprogs = shift;
	my $chromosomes = shift;
	my $ver = shift;


	foreach my $file (@{$listinfiles}) {
		
		if ($file=~/\.chrom\./) {next;}

		my $endfile = $path."/".$file."\n";

		#chromfile
		my ($prefile, $ext) = $file =~ /(\S+)\.(\S+)\s*$/;
		my $chromfile = $prefile.".chrom.".$ext;
		my $endchromfile = $path."/".$chromfile;

		#Generate chromfile
		print @{$chromosomes}, "\n";
		
		# Process to chromose indexes if we have karyotype
		if (scalar @{$chromosomes} > 0 && $file!~/\_rm\./ && $ver eq 'genome') { processfilechrom($endfile, $chromosomes, $endchromfile); }		


		foreach my $prog (keys %{$listprogs}) {

			# Adapt to chromosome context			
			my $chromcontext = 0;
			my $usefile = $file;
			my $endusefile = $endfile;

			#foreach my $app (@appsc) {
			#	if ($prog eq $app) {
			#		$usefile = $chromfile;
			#		$endusefile = $endchromfile;
			#		$chromcontext = 1;
			#	}
			#}

			if (($ver ne 'genome') &&  ($chromcontext == 1)) {
				next;
			}

			#If no karyotype and chrom indexer, skip
			if ((scalar @{$chromosomes} == 0) && ($chromcontext == 1)) {
				next;
			}

			if ($file=~/\_rm\./ && $chromcontext == 1) {
				next;
			}


			my $dirindex = $prog."_".${$listprogs}{$prog}{'version'};
			my $enddirindex = $path."/indexes/".$dirindex;
			unless (-e $enddirindex) {
				# Create enddirindex
				print $enddirindex, "\n";				
				system("mkdir -p $enddirindex");
			}
			
			my $endfileindex = $enddirindex."/".$usefile;
			chomp($endusefile);
			chomp($endfileindex);
			chomp($path);
			chomp($enddirindex);
			my $command = ${$listprogs}{$prog}{'command'};
			# PROG -> Actual program
			$command =~ s/\#PROG/${$listprogs}{$prog}{'path'}/g;
			# ORIG -> Origin file
			$command =~ s/\#ORIG/$endusefile/g;
			# DEST -> Destination file
			$command =~ s/\#DEST/$endfileindex/g;
			# BASE -> Base dir, where fasta files are
			$command =~ s/\#BASE/$path/g;
			# END -> End dir, where indexes are placed
			$command =~ s/\#END/$enddirindex/g;
			
			system($command);
			#print $command, "\n";

		}	

	}

}

sub getlistprogs {

	my $listfile = shift;
	my %hash;

	open(FILE, $listfile) || die "cannot open INDEX PROGS file!";

	while (<FILE>) {

		if ($_!~/^\s*\#/) {

			#Eg. bowtie,/soft/molbio/bowtie-0.12.7/bowtie-build,0.12.7,#PROG #ORIG #DEST,1
			my ($prog, $path, $ver, $com, $en) = split(/\,/, $_);

			if ($en == 1) {
				$hash{$prog}{'version'} = $ver;
				$hash{$prog}{'path'} = $path;
				$hash{$prog}{'command'} = $com;
			}

		}
	}

	close(FILE);

	return(%hash);
}

sub getchromsREST {
	my $species = shift;

	my @chromosomes;

	my $json = get( "http://rest.ensembl.org/info/assembly/".$species."?content-type=application/json" );

	if ( defined( $json ) ) {
		my $decoded_json = decode_json( $json );
		if ( defined( $decoded_json->{"karyotype"} ) ) {
			@chromosomes = @{$decoded_json->{"karyotype"}};
		}
		
	} else {
		print STDERR "NO KARYOTIPE FOR ".$species."\n";
	}
	

	return(\@chromosomes);
	
}


sub getchroms {

	my $file = shift;
	my @chromosomes;

	open (FILE, $file) || die "cannot open $file!";

	# E.g. for Human
	# ENSEMBL_CHROMOSOMES     = [ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT]

	while (<FILE>) {
		if ($_=~/^ENSEMBL_CHROMOSOMES/) {
			my ($chromlist) = $_=~ /\[\s*(.*)\s*\]/;
			@chromosomes = split(/\s+/, $chromlist);
		}
	}

	close(FILE);

	return(\@chromosomes);
}

sub processfilechrom {
	# Process huge file
	my $file = shift;
	my $listchroms = shift; 
	my $fileout = shift;
	my $done = 0;


	open (FILEOUT, ">$fileout") || die "Cannot write!";	


	foreach my $stchrom (@{$listchroms}) {

		my $print = 0;

		open (FILE, $file) || die "cannot open $file!";
		
		while(<FILE>) {

			if ($_=~/^\s*\>/) {

				$print = 0; #Let's assume not

				if ($_=~/\>(\S+)\s*dna\:chromosome\s*/) {

					my $chrommatch = $1;

					if ($stchrom eq $chrommatch) {

						$print = 1;

					}

				}
			}
			
			if ($print == 1) {
				print FILEOUT $_;
			}
		}

		close(FILE);
	}

	close(FILEOUT);

	
}



