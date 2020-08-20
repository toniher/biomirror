#!/usr/bin/env perl

#UTILITY to download UniProt+UniRef
#author ernesto.lowy@crg.eu
#author toni.hermoso@crg.eu 

use Net::FTP;
use strict;
use warnings;

my $emailbin = "~/bin/sendMsg.sh";

# Email Messages
my $subjsend = "Started mirroring of Uniprot";
my $messagesend = "Please, be patient";


#List of progs
my $listprogsfile = "/db/.scripts/indexes_record_aa_uniprot.csv";
my %listprogs = getlistprogs($listprogsfile);


#system ("$emailbin '$subjsend' '$messagesend'");

# variables for FTP connection
my $host = "ftp.uniprot.org";
my $username = "anonymous";
my $password = undef;

# connect to ensembl ftp server
my $ftp = Net::FTP->new($host, KeepAlive=>1) or die "Error connecting to $host: $!";

# ftp login
$ftp->login($username, $password) or die "Login failed: $!";

# Binary mode
$ftp->binary;

my $ftpdir = "/pub/databases/uniprot/"; #root dir
print STDERR $ftpdir, "\n";

# chdir to $ftpdir
$ftp->cwd($ftpdir) or die "Can't go to $ftpdir: $!";

# where to put the retrieved files
my $hidden_outputdir="/db/.mirror/uniprot/";
my $outputdir="/db/uniprot/";
my $curr_rel=checkCurrRelease();

$ftp->quit;

&douniprotMirror($curr_rel,'knowledgebase','complete');
&douniprotMirror($curr_rel,'uniref','uniref50');
&douniprotMirror($curr_rel,'uniref','uniref90');
&douniprotMirror($curr_rel,'uniref','uniref100');

#Add species list
system("mkdir -p /db/uniprot/$curr_rel/docs");
system("wget -c -t 20 http://www.uniprot.org/docs/speclist.txt -O $outputdir/$curr_rel/docs/speclist.txt");

#create $outputdir/latest symbolic link to latest release
unlink("$outputdir/latest");
system("ln -s $outputdir/$curr_rel/ $outputdir/latest");

# Email Messages
my $subjsend2 = "Finished Uniprot mirror";
my $messagesend2 = "Please, check that everything went well";

#system ("$emailbin '$subjsend2' '$messagesend2'");



#function to check the current release of Uniprot
sub checkCurrRelease {
    print STDERR "[INFO] Checking current Uniprot release\n";
    $ftp->get('relnotes.txt',"$hidden_outputdir/relnotes.txt");
    my $release;
    open FH,"<$hidden_outputdir/relnotes.txt" or die ("Cannot open $hidden_outputdir/relnotes.txt:$!\n");
    while(<FH>) {
	chomp;
	my $line=$_;
	$release=$1 if $line=~/^UniProt Release (.+)/;
    }
    close FH;
    print STDERR "[INFO] Current release at ftp server is $release\n";
    return($release);
}

#polymorphic function to download uniref and knowledgebase (including 'complete' 'proteomes' mirrors)
sub douniprotMirror {
    my ($curr_release,$type,$subtype)=@_;
    
    # connect to ensembl ftp server
    my $ftp = Net::FTP->new($host, KeepAlive=>1) or die "Error connecting to $host: $!";

# ftp login
    $ftp->login($username, $password) or die "Login failed: $!";

# Binary mode
    $ftp->binary;

    print STDERR "[INFO] Doing mirror for $type/$subtype\n";
    #create hidden dir to allocate $type/$subtype files                                      
    system("mkdir -p $hidden_outputdir/$curr_release/$type/$subtype")==0 or die("Error running system command\n");
    print STDERR "[INFO] Descending into /current_release/$type/$subtype\n";
    $ftp->cwd("$ftpdir/current_release/$type/$subtype") or die "Can't go to $ftpdir/current_release/$type/$subtype:",$ftp->message;

    # get file list              
    my @files = $ftp->ls();

    foreach my $this_file (@files) {
        next unless $this_file=~/fasta/;
        print STDERR "[INFO] Getting $this_file\n";
	$ftp->get($this_file,"$hidden_outputdir/$curr_release/$type/$subtype/$this_file");   
    }

    #move to /db/uniprot/$curr_release/$type/$subtype, unzip and format for blast
    system("mkdir -p $outputdir/$curr_release/$type/$subtype/blast/db")==0 or die("Error running system command\n");
    print STDERR "[INFO] copying *.fasta files to $outputdir/$curr_release/$type/$subtype/blast/db\n";
    system("cp $hidden_outputdir/$curr_release/$type/$subtype/*.fasta* $outputdir/$curr_release/$type/$subtype/blast/db")==0 or die("Error running system command\n");                               
    print STDERR "[INFO] decompressing files at $outputdir/$curr_release/$type/$subtype/blast/db\n";
    system("gzip -d $outputdir/$curr_release/$type/$subtype/blast/db/*.gz")==0 or die("Error running system command\n");                                                                              
    #get fasta files at $outputdir/$curr_release/$type/$subtype/blast/db          
    my $dir_to_process="/$outputdir/$curr_release/$type/$subtype/blast/db";
    opendir DH, $dir_to_process or die "Cannot open $dir_to_process: $!";
    my @fasta_files= grep {/fasta$/} readdir DH;
    closedir DH;
    foreach my $this_file (@fasta_files) {
        print STDERR "[INFO] formatdb of $this_file\n";

	my $prog = "ncbi-blast+";
	my $command = $listprogs{$prog}{'command'};

	my $endusefile = "/$outputdir/$curr_release/$type/$subtype/blast/db/$this_file";

	# PROG -> Actual program
	$command =~ s/\#PROG/$listprogs{$prog}{'path'}/g;
	# ORIG -> Origin file
	$command =~ s/\#ORIG/$endusefile/g;
			
        system($command)==0 or die("Error running $command\n");
    }
    print STDERR "[INFO] mirror for $type/$subtype finished\n";
    $ftp->quit;
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



