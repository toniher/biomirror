#!/usr/bin/env perl

# A script to retrieve the current_mysql data for the latest ensembl release
# and push it to a local MySQL database
# Based on code by Steve Moss
# gawbul@gmail.com
# 7th February 2011
# Toni Hermoso <toni.hermoso@crg.eu> 2011-2012

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

# Control parameters
my $pdown = "1";
my $pextr = "1";

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
my $subjsend = "Starting mirroring ENSEMBL GTF ".$currelease;
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


my $ftpdir = "/pub/$currelease/gtf";
print STDERR $ftpdir, "\n";


# other variables
my $base = "";
my $data_dir = $base."/db/.mirror/ensembl/$currelease/gtf"; ####### CHANGE THIS TO THE DIRECTORY YOU WANT TO STORE YOUR FILES IN #######
my $stampfile = $base."/db/.mirror/ensembl/GTF";
my $data_link = $base."/db/.mirror/ensembl/current_gtf";

my $final_dir = $base."/db/ensembl/$currelease";
my $fstampfile = $base."/db/ensembl/GTF";


print STDERR $data_dir, "\n";

#Exit if arrived to the end
if (downloaded_latest_ensembl($currelease, $fstampfile) > 0) { exit;}
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

		# let's check if exists

		my $indir = $newdir;
		$ftp->cwd($indir) or next;

		# get file list
		my @files = $ftp->ls();

		# add array to hash
		$ftp_files{$dir} = \@files;

		# retrieve size of files
		foreach my $filed (@files) {
			$ftp_sizes{$dir}{$filed} = check_size_ftp($ftp, $indir."/".$filed);
		}

		# return to FTP root
		$ftp->cwd() or die "Can't go to FTP root: $!";

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


if ($pdown > 0) {

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



		my $path = File::Spec->catfile($data_dir, $dir);
		unless (-d $path) {
			make_path($path);
		}

		my @files = @{$files_ref};
		my $logfile = $path."/LOG-GTF";

		foreach my $file (@files) {

			unless (downloaded_latest_ensembl($file, $logfile) > 0) {
				# change to correct directory
				chdir $path;

				system("rm $file");
				# retrieve the file
				system("wget -t 0 -c -N ftp://$host$ftpdir/$dir/$file");
				#Check size file against DB
				my $wc = 0;
				while ( compare_size(cwd()."/".$file, $ftp_sizes{$dir}{$file}) < 1 ) {

					#Remove file and try again
					#Maybe after 10 times (network problems) -> to die
					system("rm $file");
					system("wget -t 0 -c -N ftp://$host$ftpdir/$dir/$file");
					$wc++;
					if ($wc > 10) {die "network problem with $dir/$file\n";}
				}

				open (FILEOUT, ">>LOG-GTF") || die "Cannot write";
				print FILEOUT $file, "\n";
				close (FILEOUT);

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
if ($pextr > 0) {

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


	# get list of files
	opendir($dh, "$data_dir/$dir") or die "Can't opendir $data_dir/$dir: $!";
	my @files = grep {!/^\./ && -f "$data_dir/$dir/$_" && /\.gz$/} readdir($dh); #NOT EXTRACT CHECKSUMS
	closedir $dh;
	@files = sort {$a cmp $b} @files;


	foreach my $file (@files) {

             my $orifile = $data_dir."/".$dir."/".$file;
	     my $endpath = $final_dir."/".$dir."/gtf/";
	     my $endfile = $final_dir."/".$dir."/gtf/".$file;

	     unless (-d $endpath) {
		make_path($endpath);
	     }

             if (-e "$endfile.gz") {system("rm $endfile.gz");}



             system("cd $endpath; cp $orifile $endfile;  gunzip $endfile;") == 0 or die "zcat failed: $?";

	}


}


chdir getcwd();
}


open (FILEOUT, ">>$fstampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

#SYMLINK
system("unlink $data_link");
system("ln -s $data_dir $data_link");

my $subjsend2 = "Finished mirroring and processing ENSEMBL GTF ".$currelease;
my $messagesend2 = "Please check everything went OK";

system ("$emailbin '$subjsend2' '$messagesend2'");

print "Finished!\n";
