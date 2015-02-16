#!/usr/bin/env perl

use warnings;
use strict;
use JSON qw( decode_json );
use LWP::Simple;
use Config::JSON;
use Data::Dumper;

# Get JSON Config
# We assume same path as script
my $config = Config::JSON->new("../conf/indexes.json");

my $list_programs = $config->get("programs");

#Dir where ensembl release
my $dir = shift;

# We allow here filtering by organism
my $organism = shift;

#get config
my ($branch) = $dir =~/(release\-\d+)/;

my $emailbin = "~/bin/sendMsg.sh";

# Email Messages
my $subjsend = "Starting creating indexes for ENSEMBL files";
my $messagesend = "Please, be patient";

system ("$emailbin '$subjsend' '$messagesend'");


opendir(DIR, $dir) || die "Cannot open $dir";

my @listdir = grep {-d "$dir/$_" && $_!~/^\./} readdir(DIR);

closedir(DIR);

my $restrict = 0;
if ( defined( $organism ) ) {
	$restrict = 1;
}

foreach my $indir (@listdir) {

	my ( @subdirs ) = checkWhere( $dir."/".$indir );

	if ( $#subdirs > -1 ) {
	
		foreach my $subdir ( @subdirs ) {

			if ( $restrict > 0 && $organism ne $subdir ) {
				# Skip organisms not in param
				next;
			}
	
			processPrograms( "$dir/$indir/$subdir", $list_programs);
		}
		
	} else {
	
		if ( $restrict > 0 && $organism ne $indir ) {
			# Skip organisms not in param
			next;
		}
	
		processPrograms( "$dir/$indir", $list_programs);
	}
	
	#last; # Use for only testing one
}

#exit;


# Email Messages
my $subjsend2 = "Finished creating indexes for NA ENSEMBL files";
my $messagesend2 = "Please, check that everything went well";

system ("$emailbin '$subjsend2' '$messagesend2'");

sub checkWhere {
	my $dir = shift;
	
	my @subdirs = ();
	
	if ( $dir=~/_collection/ ) {
	
		opendir(DIR, $dir) || die "Cannot open $dir";
		@subdirs = grep {-d "$dir/$_" && $_!~/^\./} readdir(DIR);
		closedir(DIR);
	
	}

	return @subdirs;
}

sub processPrograms {

	my $dir = shift;
	my $listprograms = shift;
	
	opendir(DIR, "$dir");
	my ( @listdirs ) = grep { -d "$dir/$_" && $_!~/^\./ } readdir(DIR); 

	foreach my $ver ( @listdirs ) {

		if (-e "$dir/$ver") {

			opendir(INDIR, "$dir/$ver") || die "Cannot open it";

			my @listindir = grep {-f "$dir/$ver/$_" && $_!~/^LOG/ && $_!~/\.chrom\./} readdir(INDIR);
		
			#print Dumper( @listindir );
			# preprocess for chromosomes -> #TODO: Move up, so no repeat
			my ( $orgdir ) = $dir =~ /\/?(\w+)\s*$/;
			$orgdir =~s/\s/_/g;
			#print $orgdir, "\n";

			my $chromosomes = getchromsREST($orgdir, $dir);

			# indexing
			indexfiles("$dir/$ver", \@listindir, $listprograms, $chromosomes, $ver);

			closedir(INDIR);
		}
	
	}

}

sub indexfiles {

	my $path = shift;
	my $listinfiles = shift;
	my $listprogs = shift;
	my $chromosomes = shift;
	my $ver = shift;

	#print Dumper($path);
	#print Dumper($listinfiles);
	#print Dumper($listprogs);
	#print Dumper($chromosomes);
	#print Dumper($ver);

	foreach my $file (@{$listinfiles}) {
		
		if ($file=~/\.chrom\./) {next;}

		my $endfile = $path."/".$file."\n";

		#chromfile
		my ($prefile, $ext) = $file =~ /(\S+)\.(\S+)\s*$/;
		my $chromfile = $prefile.".chrom.".$ext;
		my $endchromfile = $path."/".$chromfile;

		#Generate chromfile
		#print @{$chromosomes}, "\n";
		
		# Process to chromose indexes if we have karyotype. That is, more than 1
		if (scalar @{$chromosomes} > 1 && $file!~/\_rm\./ && $file!~/\_sm\./ && $ver eq 'genome') { processfilechrom($endfile, $chromosomes, $endchromfile); }


		foreach my $prog ( @{$listprogs} ) {

			if ( ! inArray( $ver, $prog->{"group"} ) ) {
				next;
			}
			

			# Adapt to chromosome context
			my $chromcontext = 0;
			my $usefile = $file;
			my $endusefile = $endfile;

			if ( $prog->{"chrom"} ) {
				$usefile = $chromfile;
				$endusefile = $endchromfile;
				$chromcontext = 1;
			}

			if (($ver ne 'genome') &&  ($chromcontext == 1)) {
				next;
			}

			#If no karyotype and chrom indexer, skip
			if ((scalar @{$chromosomes} < 2) && ($chromcontext == 1)) {
				next;
			}

			if ($file=~/\_rm\./ && $file=~/\_sm\./ && $chromcontext == 1) {
				next;
			}

			my $dirindex = $prog->{'name'}."_".$prog->{'version'};
			my $enddirindex = $path."/indexes/".$dirindex;
			unless (-e $enddirindex) {
				# Create enddirindex
				print "INDEX: ", $enddirindex, "\n";
				system("mkdir -p $enddirindex");
			}
			
			my $endfileindex = $enddirindex."/".$usefile;
			chomp($endusefile);
			chomp($endfileindex);
			chomp($path);
			chomp($enddirindex);
			my $command = $prog->{'command'};
			# PROG -> Actual program
			$command =~ s/\#PROG/$prog->{'path'}/g;
			# ORIG -> Origin file
			$command =~ s/\#ORIG/$endusefile/g;
			# DEST -> Destination file
			$command =~ s/\#DEST/$endfileindex/g;
			# BASE -> Base dir, where fasta files are
			$command =~ s/\#BASE/$path/g;
			# END -> End dir, where indexes are placed
			$command =~ s/\#END/$enddirindex/g;
			
			#system($command);
			print "COMMAND: ", $command, "\n";

		}	

	}

}

sub getchromsREST {
	my $species = shift;
	my $dir = shift;
	
	my $site = "ensembl";
	
	if ( $dir =~/ensemblgenomes/ ) { 
		$site = "ensemblgenomes";
	}
	
	# TODO: detect ensemblgenomes from directory

	my @chromosomes;

	my $json = get( "http://rest.$site.org/info/assembly/".$species."?content-type=application/json" );

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


sub inArray {

	my $elem = shift;
	my $array = shift;

	my %params = map { $_ => 1 } @{$array};
	if( exists( $params{$elem} ) ) {
		return 1;
	} else {
		return 0;
	}

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







