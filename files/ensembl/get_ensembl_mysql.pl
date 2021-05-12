#!/usr/bin/env perl

# A script to retrieve the current_mysql data for the latest ensembl release
# and push it to a local MySQL database
# Initial code by Steve Moss
# gawbul@gmail.com
# 7th February 2011
# Modified by toni.hermoso@crg.cat

# make life easier
use warnings;
use strict;

# imports needed
use Net::FTP;
use Cwd;
use DBI;
use DBD::mysql;
use File::Spec;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use File::Path qw(make_path remove_tree);
use Config::JSON;


# Control parameters
my $pdown = "1";
my $pextr = "1";
my $pmysql = "1";

# MySQL buffer
my $mysql_sort_buffer = "30331648";

##############################################
# Variables here - change values as required #
##############################################

# variables for FTP connection
my $host = "ftp.ensembl.org";
my $username = "anonymous";
my $password = undef;


my $config = Config::JSON->new("../conf/ensembl_mysql.json");

# Modulating option to drop DB, default not
my $drop = $config->get("drop") // 0;

# Include from process #
my $include = $config->get('include') // () ;

my $currelease;

# Parameter or not
if ( @ARGV == 0) {
	$currelease = check_latest_ensembl($host, $username, $password, '/pub');
}
else {$currelease = shift; }


#Email params
my $emailbin = "~/bin/sendMsg.sh";

# Email Messages
my $subjsend = "Starting mirroring ENSEMBL MYSQL ".$currelease;
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


my $ftpdir = "/pub/$currelease/mysql";
print STDERR $ftpdir, "\n";

# variables for MySQL connection
my $sql_host = $config->get('mysql/host') // 'localhost' ;
my $sql_port = $config->get('mysql/port') // "3306";
my $sql_username = $config->get('mysql/user') // "ensembl";
my $sql_password = $config->get('mysql/password') // "ensembl";


# other variables
my $base = "";
my $data_dir = $base."/db/.mirror/ensembl/$currelease/mysql"; ####### CHANGE THIS TO THE DIRECTORY YOU WANT TO STORE YOUR FILES IN #######
my $stampfile = $base."/db/.mirror/ensembl/LOG-MYSQL";
my $fstampfile = $base."/db/.mirror/ensembl/MYSQL";
my $data_link = $base."/db/.mirror/ensembl/current_mysql";

print STDERR $data_dir, "\n";


#Exit if arrived to the end
if (downloaded_latest_ensembl($currelease, $fstampfile) > 0) { exit;}
#If everything downloaded OK, only extract -> TO FIX
if (downloaded_latest_ensembl($currelease, $stampfile) > 0) { $pdown=0; $pextr=0;}

#Temporal
#$pdown = 0;

#Warn about downloading
system ("$emailbin '$subjsend' '$messagesend'");

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

my $fcount = 0;

# traverse the directories
foreach my $dir (@dirs) {

	$fcount++;


	if ($dir =~ /[a-z]+.*/) {
		# chdir to $dir
		my $newdir = $ftpdir . "/" . $dir;
		$ftp->cwd($newdir) or die "Can't go to $newdir: $!";

		print "Retrieving FTP directory structure for $dir...\n";

		# get file list
		my @files = $ftp->ls();

		# add array to hash
		$ftp_files{$dir} = \@files;

		# return to FTP root
		$ftp->cwd() or die "Can't go to FTP root: $!";

		print "Done!\n\n"
	}
	#if ($fcount > 1) {last;} #Finish download -> REMOVE LATER
}

#-- close ftp connection
$ftp->quit or die "Error closing ftp connection: $!";


# Matches in array

sub matchesinarray {

	my $dir = shift;
	my $arrayre = shift;

	foreach my $re (@{$arrayre}) {

		if ($dir=~ /$re/) {

			return(1);
		}

	}

	return(0);
}

########################
# File retrieval stuff #
########################

# get directory list
@dirs = keys %ftp_files;
@dirs = sort {$a cmp $b} @dirs;

if ($pdown > 0) {

my $count = 0;

foreach my $dir (@dirs) {
	$count++; # Counter

	#Avoid excluded dirs
	unless (&matchesinarray($dir, $include) > 0) {next;}

	print STDERR $dir, "\n";

	# build local directory structure
	unless (-d $data_dir) {
		make_path($data_dir);
	}
	my $path = File::Spec->catfile($data_dir, $dir);
	unless (-d $path) {
		mkdir $path;
	}

	my $files_ref = $ftp_files{$dir};
	my @files = @$files_ref;

	print "Retrieving files from $dir...\n";


	foreach my $file (@files) {
		unless (-e substr($file, 0, -3)) {
			# change to correct directory
			chdir $path;
			#Avoid download again CHECKSUM
			if ($file=~/^CHECKSUM/ && -e $file) {next;}

			# retrieve the file
			system("wget -t 0 -c -N ftp://$host$ftpdir/$dir/$file");
		}
	}

	#if ($count > 1) {last;} #Finish download
	}

}


##########################
# Extract the data files #
##########################
if ($pextr > 0) {

print "In extraction process...\n";

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

	#Avoid excluded dirs
	unless (&matchesinarray($dir, $include) > 0) {next;}

	# change into each directory in turn
	chdir "$data_dir/$dir";
	my $logfile = $data_dir."/".$dir."/ELOG";

	#Check if already parsed in DB
	if (downloaded_latest_ensembl($currelease, $logfile) > 0) { next;}

	print "Extracting data for $dir (please be patient)...\n";

	# get list of files
	opendir($dh, "$data_dir/$dir") or die "Can't opendir $data_dir/$dir: $!";
	my @files = grep {!/^\./ && !/^CHECKSUMS/ &&-f "$data_dir/$dir/$_" } readdir($dh); #NOT EXTRACT CHECKSUMS
	closedir $dh;
	@files = sort {$a cmp $b} @files;

	# populate tables in turn
	foreach my $file (@files) {
		if ($file =~ /\.gz$/) {
			my $input = $file;
			my $output = substr($file, 0, -3);
			my $status = 1;

			$status = &checksum($input);

			while (!(-e "$data_dir/$dir/$output")) {
				gunzip $input => $output or $status = 0;

				# if error in unzip then retrieve file again
				if ($status == 0) {
					# delete output file
					unlink $output;

					# get file again
					system("wget -t 0 -c -N ftp://$host/$ftpdir/$dir/$input");

					# update status
					$status = 1;
				}
			}
			unlink $input;
		}
	}

	open (FILEOUT, ">>$logfile") || die "Cannot write";
	print FILEOUT $currelease, "\n";
	close (FILEOUT);
	print "Done!\n";

}
chdir getcwd();

#PRINT STAMPFILE
open (FILEOUT, ">>$stampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

}

##########################
# CHECKSUM #
##########################
sub checksum{

	my $file = shift;
	my $csum = `zcat CHECKSUMS.gz | grep -E '\\b$file' | cut -d ' ' -f 1`;
	my $sum = `sum $file | cut -d ' ' -f 1`;

	if ($csum == $sum) {
		return(1);
	}
	else {
		return(0);
	}
}


##########################
# MySQL stuff below here #
##########################
$pmysql = 1; #Import MySQL - Toniher

if ($pmysql > 0) {

print "Importing all 2 MYSQL (please be patient)...\n";


# change to data dir
chdir $data_dir;

# get directory listing
my $dh;
opendir($dh, $data_dir) or die "Can't opendir $data_dir: $!";
@dirs = grep {!/^\./ && -d "$data_dir/$_" } readdir($dh);
closedir $dh;

# sort directories
@dirs = sort {$a cmp $b} @dirs;

# traverse directories
foreach my $dir (@dirs) {

	#Avoid excluded dirs
	unless (matchesinarray($dir, $include) > 0) {next;}

	# change into each directory in turn
	chdir "$data_dir/$dir";
	my $logfile = $data_dir."/".$dir."/LOG";

	#Check if already parsed in DB
	# if (downloaded_latest_ensembl($currelease, $logfile) > 0) { next;}

	# create the database based on the dir name
	print "Creating database for $dir...\n";
	# setup database connection
	my $dsn = "DBI:mysql:INFORMATION_SCHEMA:$sql_host:$sql_port";
	my $dbh = DBI->connect($dsn, $sql_username, $sql_password) or die "Unable to connect: $DBI::errstr\n";

	#If pointed we drop database
	if ($drop == 1) {$dbh->do("DROP DATABASE IF EXISTS $dir");}

	#If not dropping and DB exists, next one
	if ($drop == 0 && checkDBexists($dir, $dbh) > 0) {
		print STDERR "Already $dir\n";
		next;
	}

	$dbh->do("CREATE DATABASE IF NOT EXISTS $dir");
	#system("mysqladmin -h $sql_host -P $sql_port -u $sql_username --password=$sql_password create $dir"); # deprecated - error IF EXISTS
	$dbh->disconnect();



	# populate database with tables from .sql file
	print "Building database structure for $dir...\n";
	my $sql_file = File::Spec->catfile($data_dir, $dir, $dir . ".sql");
	system("mysql -h $sql_host -P $sql_port -u $sql_username --password=$sql_password $dir \< $sql_file");

	# get list of files
	opendir(my $dh, "$data_dir/$dir") or die "Can't opendir $data_dir/$dir: $!";
	my @files = grep {!/^\./ && -f "$data_dir/$dir/$_" } readdir($dh);
	closedir $dh;
	@files = sort {$a cmp $b} @files;

	# setup database connection
	$dsn = "DBI:mysql:$dir:$sql_host:$sql_port";
	$dbh = DBI->connect($dsn, $sql_username, $sql_password) or die "Unable to connect: $DBI::errstr\n";

	# populate tables in turn
	foreach my $file (@files) {
		unless ($file=~"CHECKSUM" || $file=~"LOG" || $file=~ /.*?\.sql$/ || $file=~ /.*?\.gz$/) {
			# get variables
			my $sql_file = File::Spec->catfile($data_dir, $dir, $file);
			my $table = substr($file, 0, -4);

			# build query and execute
			my $path_sql_file = "$sql_file";
			my $timestamp = puttimestamp();
			print "Loading data in $sql_file ($path_sql_file) into $table... @ $timestamp\n";
			my $dostring = "LOAD DATA LOCAL INFILE '".$path_sql_file."' INTO TABLE ".$table;
			$dbh->do("SET SESSION myisam_sort_buffer_size=$mysql_sort_buffer");
			print $dostring, "\n";
			$dbh->do($dostring) or die "Cannot import, $DBI::errstr\n" ;
		}
	}

	# disconnect from database
	$dbh->disconnect();

	open (FILEOUT, ">>$logfile") || die "Cannot write";
	print FILEOUT $currelease, "\n";
	close (FILEOUT);

	print "Done!\n";

}
chdir getcwd();

#PRINT STAMPFILE
open (FILEOUT, ">>$fstampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);
#SYMLINK

print STDERR "$data_dir $data_link\n";

if (-e $data_link) {unlink($data_link);}
symlink($data_dir, $data_link);
}


print "Finished!\n";

my $subjsend2 = "Finished mirroring and processing MYSQL ENSEMBL ".$currelease;
my $messagesend2 = "Please check everything went OK";

system ("$emailbin '$subjsend2' '$messagesend2'");

print "Finished!\n";

sub puttimestamp {

	my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	return ("%4d-%02d-%02d %02d:%02d:%02d\n", $year+1900,$mon+1,$mday,$hour,$min,$sec);
}


sub checkDBexists {

	my $dbname = shift;
	my $dbh  = shift;

	my $outcome = 0;
	$dbname = $dbh->quote($dbname);
	my $sth = $dbh->prepare("SELECT SCHEMA_NAME AS `Database` FROM INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=$dbname");
	$sth->execute;

	$outcome = $sth->rows;

	$sth->finish;

	return $outcome;
}
