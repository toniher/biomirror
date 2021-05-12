#!/usr/bin/env perl

# A script to retrieve data for the latest ensembl release
# Based on original code by Steve Moss <gawbul@gmail.com>
# Modified by Toni Hermoso <toni.hermoso@crg.eu> 2011-2014

# make life easier
use warnings;
use strict;

# imports needed
use Net::FTP;
use Cwd;
#use DBI;
#use DBD::mysql;
use File::Spec;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use File::Path qw(make_path remove_tree);
use Data::Dumper;
use File::stat;
use Getopt::Long;
use Config::JSON;

# Control parameters
my $pdown = "1";
my $pextr = "1";

my $jsonfile = shift // "../conf/ensemblgenomes.json";


# Get JSON Config
# We assume same path as script
my $config = Config::JSON->new( $jsonfile );

my $list_taxon = $config->get("organisms");

#Email params
my $emailbin = "~/bin/sendMsg.sh";

##############################################
# Variables here - change values as required #
##############################################

# variables for FTP connection
my $host = "ftp.ensemblgenomes.org";
my $username = "anonymous";
my $password = undef;


my $currelease = check_latest_ensembl($host, $username, $password, '/pub');

# Email Messages
my $subjsend = "Starting mirroring ENSEMBL GENOMES ".$currelease;
my $messagesend = "Please, be patient";


sub check_latest_ensembl {

	my ($host, $username, $password, $path) = @_;

	# connect to ensembl ftp server
	my $ftp = Net::FTP->new($host, KeepAlive=>1) or die "Error connecting to $host: $!";

	# ftp login
	$ftp->login($username, $password) or die "Login failed: $!";

	# chdir to $ftpdir
	$ftp->cwd($path) or die "Can't go to $path: $!";

	# get list of ftp directories
	my @dirs = $ftp->ls();

	my @releases;
	foreach my $dir (@dirs) {

		if ($dir=~/release\-(\d+)/) {

      my $num = $1;
			push(@releases, $num);
		}
	}

  my @ordreleases = sort { $a <=> $b } @releases;
	return("release-".$ordreleases[-1]);
}

sub sortreleases {

	my @releases = @_;
	my %hash = {};
	my @ordreleases;

	foreach my $release ( @releases ) {
		print STDERR $release, "\n";
		my ($num) = $release =~/\-(\d+)/;
		$hash{$num} = $release;
	}

	foreach my $key ( sort { $a <=> $b } keys %hash ) {
		push(@ordreleases, $hash{ $key } );
	}

	return @ordreleases;
}


sub downloaded_latest_ensembl {

	my ($release, $file) = @_;
	my $detect = 0;

	open (FILE, $file) || return(0);

	while (<FILE>) {

		chomp($_);
		print STDERR $_, "\n";
		if ($_ eq $release) {
			$detect = 1;
		}

	}

	close (FILE);
	print STDERR "detect: ", $detect, "\n";

	return($detect);
}

my $base = "";
my $stampfile = $base."/db/.mirror/ensemblgenomes/FASTA";
# TODO: Evaluate filtering by species
my $fstampfile = $base."/db/ensemblgenomes/FASTA";


#Warn about downloading
system ("$emailbin '$subjsend' '$messagesend'");

# TODO: Approach should be changed maybe

foreach my $taxon ( @{ $list_taxon} ) {

	# TODO: Dealing with no subsection, only in bacteria
	my $section = $taxon->{'group'};
	my $subsection = $taxon->{'subgroup'};
	my $name = $taxon->{'name'};

	my $ftpdir = "/pub/$currelease/$section/fasta/$subsection/$name";
	print STDERR $ftpdir, "\n";


	# other variables

	my $data_dir = $base."/db/.mirror/ensemblgenomes/$currelease/$subsection/$name/fasta";

	my %data_ori = ('dna' => 'genome', 'cdna' => 'transcriptome', 'pep' => 'proteome', 'ncrna' => 'ncrna');

	my $final_dir = $base."/db/ensemblgenomes/$currelease/$subsection/$name";



	print STDERR $data_dir, "\n";

	#Exit if arrived to the end
	if (downloaded_latest_ensembl($currelease, $fstampfile) > 0 ) { exit; }
	#If everything downloaded OK, only extract
	if (downloaded_latest_ensembl($currelease, $stampfile) > 0) { $pdown=0;}



	########################
	# FTP stuff below here #
	########################

	# connect to ensembl ftp server
	my $ftp = Net::FTP->new($host, KeepAlive=>1) or die "Error connecting to $host: $!";

	# ftp login
	$ftp->login($username, $password) or die "Login failed: $!";

	# Binary mode
	$ftp->binary;

	# chdir to $ftpdir
	$ftp->cwd($ftpdir) or die "Can't go to $ftpdir: $!";

	# get list of ftp directories
	my @dirs = $ftp->ls();
	my %ftp_files = ();
	my %ftp_sizes = ();

	my $fcount = 0;


	print "Retrieving FTP directory structure for $ftpdir...\n";

	foreach my $group (keys %data_ori) {

		# let's check if exists

		my $indir = $ftpdir. "/". $group;
		$ftp->cwd($indir) or next;

		# get file list
		my @files = $ftp->ls();

		# add array to hash
		$ftp_files{$group} = \@files;

		# retrieve size of files
		foreach my $filed (@files) {
			$ftp_sizes{$group}{$filed} = check_size_ftp($ftp, $indir."/".$filed);
		}

		# return to FTP root
		$ftp->cwd() or die "Can't go to FTP root: $!";
	}




	#-- close ftp connection
	$ftp->quit or die "Error closing ftp connection: $!";

	sub check_size_ftp {

		my $ftp = shift;
		my $fpath = shift;

		#print STDERR $fpath, " - ", $ftp->size($fpath), "\n";
		return($ftp->size($fpath));


	}

	########################
	# File retrieval stuff #
	########################

	print STDERR Dumper(%ftp_files);

	# get directory list

	if ($pdown > 0 ) {



	#REMOVE files if there
	if (-d $data_dir) {
		#print STDERR "iii!\n";
		chdir($data_dir);
		#system("rm -rf ./*");
	}

	# build local directory structure
	unless (-d $data_dir) {
		make_path($data_dir);
	}


	my %files_ref = %ftp_files;
	print Dumper( keys %files_ref );

	foreach my $group (keys %files_ref ) {
		print STDERR $group;
		my $path = File::Spec->catfile($data_dir, "/".$group);
		unless (-d $path) {
			make_path($path);
		}

		my @files = @{$files_ref{$group}};
		my $logfile = $path."/LOG";

		foreach my $file (@files) {

			unless (downloaded_latest_ensembl($file, $logfile) > 0) {
				# change to correct directory
				chdir $path;

				if ( -f "$file" ) {
				      system("rm $file");
        }
				# retrieve the file
				system("wget -t 0 -c -N ftp://$host$ftpdir/$group/$file");
				#Check size file against DB
				my $wc = 0;
				while ( compare_size(cwd()."/".$file, $ftp_sizes{$group}{$file}) < 1 ) {

					#Remove file and try again
					#Maybe after 10 times (network problems) -> to die
					system("rm $file");
					system("wget -t 0 -c -N ftp://$host$ftpdir/$group/$file");
					$wc++;
					if ($wc > 10) {die "network problem with $group/$file\n";}
				}

				open (FILEOUT, ">>LOG") || die "Cannot write";
				print FILEOUT $file, "\n";
				close (FILEOUT);

			}
		}
	}


	}

	sub compare_size {

		my $file = shift;
		my $lfile = shift;

		print STDERR "$file\t$lfile\n";

		if ((stat($file)->size) == $lfile) {

			return("1");
		}

		else {return("0!");}

	}


	##########################
	# Extract the data files #
	##########################
	if ($pextr > 0 ) {

		# change to data dir
		chdir $data_dir;


		print "Extracting data for $data_dir (please be patient)...\n";

		foreach my $group ( keys %ftp_sizes ) {

			# get list of files
			opendir( my $dh, "$data_dir/$group") or die "Can't opendir $data_dir/$group: $!";
			my @files = grep {!/^\./ && -f "$data_dir/$group/$_" && /\.gz$/} readdir($dh); #NOT EXTRACT CHECKSUMS
			closedir $dh;
			@files = sort {$a cmp $b} @files;

			concateninfas(\@files, $group, $data_dir, $final_dir);

		}
		print "Done!\n";


		chdir getcwd();
	}


	sub concateninfas {

		my ($files, $group, $origin, $end) = @_;

		#SPECIFIC PROCESSING AHEAD
		#DNA
		if ($group eq 'dna') {

			#CHROMOSOMAL
			#TOPLEVEL
			my @topfiles;
			my $toppatro = "";

			#RM
			my @rmfiles;
			my $rmpatro = "";

			#SM
			my @smfiles;
			my $smpatro = "";

			foreach my $file (@{$files}) {

				#CHROMOSOMAL && TOPLEVEL
				if ($file=~/\.dna\..*toplev/) {

					push(@topfiles, $file);
					($toppatro)= $file=~/^(\S+dna)\./;
				}

				#RM
				if ($file=~/\.dna_rm\..*toplev/) {

					push(@rmfiles, $file);
					($rmpatro)= $file=~/^(\S+dna_rm)\./;

				}

				#SM
				if ($file=~/\.dna_sm\..*toplev/) {

					push(@smfiles, $file);
					($smpatro)= $file=~/^(\S+dna_sm)\./;
				}

			}

			if ($toppatro=~/^\S+/) {
				#Send TOPLEVEL
				sendinconcaten(\@topfiles, $toppatro, $group, $origin, $end, "normal");
			}

			if ($rmpatro=~/^\S+/) {
				#SEND RM
				sendinconcaten(\@rmfiles, $rmpatro, $group, $origin, $end, "rm");
			}

			if ($smpatro=~/^\S+/) {
				#SEND SM
				sendinconcaten(\@smfiles, $smpatro, $group, $origin, $end, "sm");
			}

		}

		#CDNA
		if ($group eq 'cdna') {

			#ABINITIO
			my @abfiles;
			my $abpatro = "";

			#ALL
			my @callfiles;
			my $callpatro = "";

			foreach my $file (@{$files}) {

				#ABINITIO
				if ($file=~/\.cdna\.abinitio/) {

					push(@abfiles, $file);
					($abpatro)= $file=~/^(\S+cdna\.abinitio)\./;
				}

				#ALL
				if ($file=~/\.cdna\.all/) {

					push(@callfiles, $file);
					($callpatro)= $file=~/^(\S+cdna\.all)\./;

				}
			}

			if ($abpatro=~/^\S+/) {
				#Send ABINITIO
				sendinconcaten(\@abfiles, $abpatro, $group, $origin, $end, "normal");
			}

			if ($callpatro=~/^\S+/) {
				#SEND ALL
				sendinconcaten(\@callfiles, $callpatro, $group, $origin, $end, "rm");
			}

		}


		#NCRNA
		if ($group eq 'ncrna') {

			#FILES
			my @ncfiles;
			my $ncpatro;

			foreach my $file (@{$files}) {

				push(@ncfiles, $file);
				($ncpatro)= $file=~/^(\S+ncrna)\./;


			}
			sendinconcaten(\@ncfiles, $ncpatro, $group, $origin, $end, "normal");


		}

		#PEP
		if ($group eq 'pep') {


			#ABINITIO
			my @pabfiles;
			my $pabpatro = "";

			#ALL
			my @pallfiles;
			my $pallpatro = "";

			foreach my $file (@{$files}) {

				#ABINITIO
				if ($file=~/\.pep\.abinitio/) {

					push(@pabfiles, $file);
					($pabpatro)= $file=~/^(\S+pep\.abinitio)\./;
				}

				#ALL
				if ($file=~/\.pep\.all/) {

					push(@pallfiles, $file);
					($pallpatro)= $file=~/^(\S+pep\.all)\./;

				}
			}

			if ($pabpatro=~/^\S+/) {
				#Send ABINITIO
				sendinconcaten(\@pabfiles, $pabpatro, $group, $origin, $end, "normal");
			}

			if ($pallpatro=~/^\S+/) {
				#SEND ALL
				sendinconcaten(\@pallfiles, $pallpatro, $group, $origin, $end, "rm");
			}


		}


	}

	sub sendinconcaten {

		my ($files, $patro, $group, $origin, $end, $tag) = @_;

		# build directory structure
		my $endpath = $end."/".$data_ori{$group};

		unless (-d $endpath) {
			make_path($endpath);
		}

		my $logfile = $endpath."/LOG-".$tag;
		#Next if arrived to the end

		print STDERR "...".$patro."...\n";

		unless (downloaded_latest_ensembl($currelease, $logfile) > 0 ) {

			my $endfile = $endpath."/".$patro.".fa";
			print STDERR $endfile, "\n";


			if (-e $endfile) {

				system("rm $endfile");
				system("rm $endfile.*");
			}

			foreach my $file (@{$files}) {

				my $orifile = $origin."/".$group."/".$file;
				if (-e "$endfile.gz") {system("rm $endfile.gz");}
				system("cp $orifile $endfile.gz; cd $endpath; gunzip $endfile.gz;") == 0 or die "zcat failed: $?";
				last;

			}


			#LOG if things went well
			open (FILEOUT, ">>$logfile") || die "Cannot write";
			print FILEOUT $currelease, "\n";
			close (FILEOUT);

		}

	}




}

#PRINT STAMPFILE
open (FILEOUT, ">>$stampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

open (FILEOUT, ">>$fstampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);


my $subjsend2 = "Finished mirroring and processing ENSEMBL GENOMES ".$currelease;
my $messagesend2 = "Please check everything went OK";

system ("$emailbin '$subjsend2' '$messagesend2'");

print "Finished!\n";
