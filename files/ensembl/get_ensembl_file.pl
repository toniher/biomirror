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

# Control parameters
my $pdown = "1";
my $pextr = "1";

my $USAGE = "perl get_ensemb_file.pl -d -e [-d download] [-e extract]\n";
my ($download_force, $extract_force, $show_help);


&GetOptions(
                        'download|d'                 => \$download_force,
			'extract|e'                 => \$extract_force,
           );

#Email params
my $emailbin = "~/bin/sendMsg.sh";

##############################################
# Variables here - change values as required #
##############################################

# variables for FTP connection
my $host = "ftp.ensembl.org";
my $username = "anonymous";
my $password = undef;


my $currelease = check_latest_ensembl($host, $username, $password, '/pub');

# Email Messages
my $subjsend = "Starting mirroring ENSEMBL ".$currelease;
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


my $ftpdir = "/pub/$currelease/fasta";
print STDERR $ftpdir, "\n";


# other variables
my $base = "";
my $data_dir = $base."/db/.mirror/ensembl/$currelease/fasta"; ####### CHANGE THIS TO THE DIRECTORY YOU WANT TO STORE YOUR FILES IN #######
my $stampfile = $base."/db/.mirror/ensembl/FASTA";
my $data_link = $base."/db/.mirror/ensembl/current_fasta";
my %data_ori = ('dna' => 'genome', 'cdna' => 'transcriptome', 'pep' => 'proteome', 'ncrna' => 'ncrna');

my $final_dir = $base."/db/ensembl/$currelease";
my $fstampfile = $base."/db/ensembl/FASTA";


print STDERR $data_dir, "\n";

#Exit if arrived to the end
if (downloaded_latest_ensembl($currelease, $fstampfile) > 0 && !$download_force && !$extract_force) { exit;}
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

foreach my $dir (@dirs) {

	$fcount++;

	if ($dir =~ /[a-z]+.*/) {
		# chdir to $dir
		my $newdir = $ftpdir . "/" . $dir;
		$ftp->cwd($newdir) or die "Can't go to $newdir: $!";

		print "Retrieving FTP directory structure for $dir...\n";

			foreach my $group (keys %data_ori) {

				# let's check if exists

				my $indir = $newdir. "/". $group;
				$ftp->cwd($indir) or next;

				# get file list
				my @files = $ftp->ls();

				# add array to hash
				$ftp_files{$dir}{$group} = \@files;

				# retrieve size of files
				foreach my $filed (@files) {
					$ftp_sizes{$dir}{$group}{$filed} = check_size_ftp($ftp, $indir."/".$filed);
				}

				# return to FTP root
				$ftp->cwd() or die "Can't go to FTP root: $!";
			}

		print "Done!\n\n"
	}

	#if ($fcount > 2) {last;} #Finish download  -> REMOVE LATER
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

#print STDERR Dumper(%ftp_files);

# get directory list
@dirs = keys %ftp_files;
@dirs = sort {$a cmp $b} @dirs;

if ($pdown > 0 || $download_force) {

#Warn about downloading
system ("$emailbin '$subjsend' '$messagesend'");

#REMOVE files if there
if (-d $data_dir) {
	#print STDERR "iii!\n";
	chdir($data_dir);
	#system("rm -rf ./*");
}

my $count = 0;

foreach my $dir (@dirs) {
	$count++; # Counter
	print STDERR $dir, "\n";

	# build local directory structure
	unless (-d $data_dir) {
		make_path($data_dir);
	}


	my $files_ref = $ftp_files{$dir};

	foreach my $group (keys %{$files_ref}) {

		my $path = File::Spec->catfile($data_dir, $dir."/".$group);
		unless (-d $path) {
			make_path($path);
		}

		my @files = @{$files_ref->{$group}};
		my $logfile = $path."/LOG";

		foreach my $file (@files) {

			unless (downloaded_latest_ensembl($file, $logfile) > 0) {
				# change to correct directory
				chdir $path;

				system("rm $file");
				# retrieve the file
				system("wget -t 0 -c -N ftp://$host$ftpdir/$dir/$group/$file");
				#Check size file against DB
				my $wc = 0;
				while ( compare_size(cwd()."/".$file, $ftp_sizes{$dir}{$group}{$file}) < 1 ) {

					#Remove file and try again
					#Maybe after 10 times (network problems) -> to die
					system("rm $file");
					system("wget -t 0 -c -N ftp://$host$ftpdir/$dir/$group/$file");
					$wc++;
					if ($wc > 10) {die "network problem with $dir/$group/$file\n";}
				}

				open (FILEOUT, ">>LOG") || die "Cannot write";
				print FILEOUT $file, "\n";
				close (FILEOUT);

			}
		}
	}

	#if ($count > 2) {last;} #Finish download -> REMOVE LATER
}

#PRINT STAMPFILE
open (FILEOUT, ">>$stampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

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
if ($pextr > 0 || $extract_force) {

# change to data dir
chdir $data_dir;

# get directory listing
opendir(my $dh, $data_dir) or die "Can't opendir $data_dir: $!";
@dirs = grep {!/^\./ && -d "$data_dir/$_" } readdir($dh);
closedir $dh;

# sort directories
@dirs = sort {$a cmp $b} @dirs;

# traverse directories
foreach my $dir (@dirs) {


	# change into each directory in turn
	chdir "$data_dir/$dir";

	print "Extracting data for $dir (please be patient)...\n";

	foreach my $group (keys %{$ftp_sizes{$dir}}) {

		# get list of files
		opendir($dh, "$data_dir/$dir/$group") or die "Can't opendir $data_dir/$dir/$group: $!";
		my @files = grep {!/^\./ && -f "$data_dir/$dir/$group/$_" && /\.gz$/} readdir($dh); #NOT EXTRACT CHECKSUMS
		closedir $dh;
		@files = sort {$a cmp $b} @files;

		concateninfas(\@files, $group, $dir, $data_dir, $final_dir);


	}
	print "Done!\n";

}


chdir getcwd();
}


sub concateninfas {

	my ($files, $group, $organism, $origin, $end) = @_;

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
			sendinconcaten(\@topfiles, $toppatro, $group, $organism, $origin, $end, "normal");
		}

		if ($rmpatro=~/^\S+/) {
			#SEND RM
			sendinconcaten(\@rmfiles, $rmpatro, $group, $organism, $origin, $end, "rm");
		}

		if ($smpatro=~/^\S+/) {
			#SEND SM
			sendinconcaten(\@smfiles, $smpatro, $group, $organism, $origin, $end, "sm");
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
			sendinconcaten(\@abfiles, $abpatro, $group, $organism, $origin, $end, "normal");
		}

		if ($callpatro=~/^\S+/) {
			#SEND ALL
			sendinconcaten(\@callfiles, $callpatro, $group, $organism, $origin, $end, "rm");
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
		sendinconcaten(\@ncfiles, $ncpatro, $group, $organism, $origin, $end, "normal");


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
			sendinconcaten(\@pabfiles, $pabpatro, $group, $organism, $origin, $end, "normal");
		}

		if ($pallpatro=~/^\S+/) {
			#SEND ALL
			sendinconcaten(\@pallfiles, $pallpatro, $group, $organism, $origin, $end, "rm");
		}


	}


}

sub sendinconcaten {

	my ($files, $patro, $group, $organism, $origin, $end, $tag) = @_;

	# build directory structure
	my $endpath = $end."/".$organism."/".$data_ori{$group};

	unless (-d $endpath) {
		make_path($endpath);
	}

	my $logfile = $endpath."/LOG-".$tag;
	#Next if arrived to the end

	print STDERR "...".$patro."...\n";

	unless (downloaded_latest_ensembl($currelease, $logfile) > 0 && !$extract_force) {

		my $endfile = $endpath."/".$patro.".fa";
		print STDERR $endfile, "\n";


		if (-e $endfile) {

			system("rm $endfile");
			system("rm $endfile.*");
		}

		foreach my $file (@{$files}) {

			my $orifile = $origin."/".$organism."/".$group."/".$file;
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


open (FILEOUT, ">>$fstampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

#SYMLINK
system("unlink $data_link");
system("ln -s $data_dir $data_link");

my $subjsend2 = "Finished mirroring and processing ENSEMBL ".$currelease;
my $messagesend2 = "Please check everything went OK";

system ("$emailbin '$subjsend2' '$messagesend2'");

print "Finished!\n";
