#!/usr/bin/env perl

# A script to retrieve the ncbi taxonomy data


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
use LWP::Simple;
use Digest::MD5;
use POSIX qw/strftime/;

# Control parameters
my $pdown = "1";
my $pextr = "1";

# variables for FTP connection
my $host = "ftp.ncbi.nlm.nih.gov";
my $username = "anonymous";
my $password = undef;

my $currelease = strftime("%Y%m", localtime);

my $ftpdir = "/pub/taxonomy/accession2taxid";
print STDERR $ftpdir, "\n";


# other variables
my $base = ""; #Change depending on this is stored
my $data_dir = $base."/db/.mirror/ncbi/$currelease/taxonomy/accession2taxid"; ####### CHANGE THIS TO THE DIRECTORY YOU WANT TO STORE YOUR FILES IN #######
my $stampfile = $base."/db/.mirror/ncbi/TAXONOMY2ACCESSION";

my $final_dir = $base."/db/ncbi/$currelease/taxonomy/db/accession2taxid";
my $fstampfile = $base."/db/ncbi/$currelease/taxonomy/TAXONOMY2ACCESSION";

my $emailbin = "~/bin/sendMsg.sh";

# Email Messages
my $subjsend = "Starting mirroring NCBI Taxonomy Accession";
my $messagesend = "Please, be patient";

system ("$emailbin '$subjsend' '$messagesend'");

# List of included DB
my @listinclude = ('dead_nucl.accession2taxid.gz', 'dead_prot.accession2taxid.gz', 'dead_wgs.accession2taxid.gz', 'nucl_gb.accession2taxid.gz', 'nucl_wgs.accession2taxid.gz', 'pdb.accession2taxid.gz',  'prot.accession2taxid.gz');

my @listmd5 = ('dead_nucl.accession2taxid.gz', 'dead_prot.accession2taxid.gz', 'dead_wgs.accession2taxid.gz', 'nucl_gb.accession2taxid.gz', 'nucl_wgs.accession2taxid.gz', 'pdb.accession2taxid.gz',  'prot.accession2taxid.gz');

print STDERR $data_dir, "\n";

#Exit if arrived to the end
if (downloaded_latest($currelease, $fstampfile) > 0) { exit;}
#If everything downloaded OK, only extract
if (downloaded_latest($currelease, $stampfile) > 0) { $pdown=0;}



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
my %ftp_files = ();
my %ftp_sizes = ();

# get file list
my @files = $ftp->ls();

# add array to hash
$ftp_files{'ncbi'} = \@files;

# retrieve size of files
foreach my $filed (@files) {
        $ftp_sizes{'ncbi'}{$filed} = check_size_ftp($ftp, $ftpdir."/".$filed);
}

# return to FTP root
$ftp->cwd() or die "Can't go to FTP root: $!";

#-- close ftp connection
$ftp->quit or die "Error closing ftp connection: $!";

sub check_size_ftp {

	my $ftp = shift;
	my $fpath = shift;
	#print STDERR $fpath, " - ", $ftp->size($fpath), "\n";
	return($ftp->size($fpath));
}


sub checksum{

	my $file = shift;
        my $md5file = shift;

        unless ($file=~/\.md5\s*$/) {

            if ($file=~/\.gz\s*$/) {

                my $content = get($md5file);
                my ($md5) = $content=~ /^(\S+)\s/;
                open (FILE, "<$file") or die $!;
                my $ctx = Digest::MD5->new;

                $ctx->addfile(*FILE);
                my $filemd5 = $ctx->digest;
                close(FILE);

                if ($filemd5 eq $md5) {return(1);}
                else {return(0);}

            }

            else {return(1);}
        }

        else {
            return(1);
        }


}

sub downloaded_latest {

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

sub compare_size {

	my $file = shift;
	my $lfile = shift;

	print STDERR "$file\t$lfile\n";

	if ((stat($file)->size) == $lfile) {

		return("1");
	}

	else {return("0!");}

}

sub checkinclude {

	my $file = shift;
	my $list = shift;

	my $prs = 0;

	foreach my $pattern (@{$list}) {

		if ($file=~/^$pattern/) {

			$prs++;
		}
	}

	return($prs);
}


########################
# File retrieval stuff #
########################

if ($pdown > 0) {

#REMOVE files if there
if (-d $data_dir) {
	#print STDERR "iii!\n";
	chdir($data_dir);
	#system("rm -rf ./*");
}

my $count = 0;

    unless (-d $data_dir) {
        make_path($data_dir);
    }


    my $files_ref = $ftp_files{'ncbi'};

    my @files = @{$files_ref};
    my $logfile = $data_dir."/LOG";

    foreach my $file (sort {$a cmp $b} (@files)) {

	#Check if file in list of allowed
	unless (checkinclude($file, \@listinclude) > 0) {
		next;
	}

	unless (downloaded_latest($file, $logfile) > 0) {
            # change to correct directory
            chdir $data_dir;

	    if (-e $file) {
		system("rm $file");
	    }

            # retrieve the file
            system("wget -t 0 -c -N ftp://$host$ftpdir/$file");
            #Check size file against DB
            my $wc = 0;
            while ( compare_size(cwd()."/".$file, $ftp_sizes{'ncbi'}{$file}) < 1 ) {

                    #Remove file and try again
                    #Maybe after 10 times (network problems) -> to die

		    my %params = map { $_ => 1 } @listmd5;

		    if(exists($params{$file})) {

			while ( checksum($file, "ftp://$host$ftpdir/$file.md5") < 1 ) {

			    system("rm $file");
			    system("wget -t 0 -c -N ftp://$host$ftpdir/$file");
			    $wc++;
			    if ($wc > 20) {die "network problem with $file\n";}

			}

		    }
            }

            open (FILEOUT, ">>LOG") || die "Cannot write";
            print FILEOUT $file, "\n";
            close (FILEOUT);
        }
    }




    #PRINT STAMPFILE
    open (FILEOUT, ">>$stampfile") || die "Cannot write";
    print FILEOUT $currelease, "\n";
    close (FILEOUT);


}




##########################
# Extract the data files #
##########################
if ($pextr > 0) {

	# change to data dir
	chdir $data_dir;

	print "Moving data (please be patient)...\n";

	my $dh;
	# get list of files
	opendir($dh, "$data_dir") or die "Can't opendir $data_dir: $!";
	my @filesot = grep {!/^\./ && -f "$data_dir/$_" && !/\.md5$/} readdir($dh); #NOT EXTRACT MDSUMS
	@filesot = sort {$a cmp $b} @filesot;
	print STDERR @filesot, "\n";
	closedir $dh;

	processot(\@filesot, $data_dir, $final_dir);

	print "Done!\n";

	chdir getcwd();

}

sub processot {

	my ($files, $origin, $end) = @_;

	# build directory structure
	my $endpath = $end;

	unless (-d $endpath) {
		make_path($endpath);
	}

	my $logfile = $endpath."/LOG";
	#Next if arrived to the end

	foreach my $file (@{$files}) {

	    chdir $endpath;
            my $endfile = $endpath."/".$file;

                print STDERR $endfile, "\n";

                if (-e $endfile) {

			system("rm -f $endfile");
		}

                my $orifile = $origin."/".$file;
                system("cp $orifile $endfile") == 0 or die "cp failed: $?";

                #LOG if things went well
                open (FILEOUT, ">>$logfile") || die "Cannot write";
                print FILEOUT $file, "\n";
                close (FILEOUT);


	}
}


open (FILEOUT, ">>$fstampfile") || die "Cannot write";
print FILEOUT $currelease, "\n";
close (FILEOUT);

#SYMLINK
# system("unlink $data_link");
# system("ln -s $data_dir $data_link");


print "Finished!\n";

# Email Messages
my $subjsend2 = "Finished mirroring NCBI taxonomy accession";
my $messagesend2 = "Please, check that everything went well";

system ("$emailbin '$subjsend2' '$messagesend2'");
