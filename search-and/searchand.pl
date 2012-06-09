#! /usr/bin/perl -w

# Entête de script générée automatiquement par nsh !
# Auteur : Alex (xyz@gmail.com)
# Titre : search.pl
# TIMTOWTDI but KISS
# Description : Script pour chercher des fichiers et faire de quoi avec (destroy, move, rename, whatever).
# Date de création : Sun Jul 24 11:36:24 EDT 2011
# Modification : 2011-07-24 11:36:24

use strict; #Be strict or be dead!
use Getopt::Long; #CLI args are good
use Pod::Usage; #doc yourself
use File::Find;

# need serach pattern (where to look at) and file pattern (what to look for) and an action pattern.
# build 2 functions to build arrays from user input or command line with getopt.
# then foreach search pattern, find file pattern and perform action.
# Do not forget a dry run option please.
# 2 options: parse command line arguments et decides if we have enough to work with. If we don't, ask for what is missing.
# if not argument is given, full inetractive mode, ask for everything.

#variable declaration
our ($help,@searchpattern,@filepattern,$action,@actionargs,@result) = 0;

#check CLI arguments
sub check {
    #we need at least on directory
    if ( @searchpattern < 1 ) {
        #enter interactive mode
        print "\nYou did not provide a directory to search in. Please provide at least one.\nYou may enter several of them, one per line.\nTo finish your list, enter an empty line\n";
        my ($count,$dir) = 1;
        while ( 0 == 0 ) { #yes, I'm looking for trouble
            print "Directory $count:";
            chomp($dir=<STDIN>);
            if ( $dir ne '' ) { #user is giving something
                if ( -d $dir ) { #it's a real directory
                    push(@searchpattern,$dir);
                    $count ++;
                } else {
                    die "$dir do not exist on this system, exiting\n"; #it's not a real directory
                }
            } else {
                last; #user gave an empty line, we last here.
            }
        }
    }
    #we need an action
    print "No action defined. Please give an action now: " and chomp($action=<STDIN>) unless defined $action;
    #parse the value of $action: we need clean and neat declaration for the system call at the end (in the case of ls -l for example)
    if ( $action =~ /^(.+)-/ ) {
        #we're in trouble, we have to parse
        @actionargs = split / /,$action;
    } else { #simple case
        push(@actionargs, $action);
    }
    #finaly, if no file pattern was given, let's fix it to thw * wildcard
    if ( @filepattern < 1 ) {
        push(@filepattern,'*');
    }
}

sub dryrun {
    print "\n\n\tThis is a dry-run, no action will be performed.\n\tHere is a summary of what could be done, where and on what files.\n\n";
    print "\nDirectory list:\n";
    foreach ( @searchpattern ) {
        print "$_\n";
    }
    #toute cette partie sur Action est absolument inutile
    print "\nAction:\n";
    my $act = '';
    foreach ( @actionargs ) {
        $act = "$act"." $_";
    }
    $act =~ s/^\s+//;
    print "$act\n";
    print "\nFile list:\n";
    foreach ( @filepattern ) {
        print "$_\n";
    }
    print "\n\tIF you are satisfied, please consider the option '-r' to actually Run your command\n\n";
    exit 0;
}

#main function
sub main {
    #CLI options
    my $dryrun;
    GetOptions("run|r" => \$dryrun, "help|?|h" => \$help, "directory|d=s@" => \@searchpattern, "file|f=s@" => \@filepattern, "action|a=s" => \$action);
    @searchpattern = split(/,/,join(',',@searchpattern));
    @filepattern = split(/,/,join(',',@filepattern));

    #Help wanted:
    pod2usage({-verbose => 99, -sections => [ qw(SYNOPSYS OPTIONS EXAMPLES) ]}) and exit if $help;

    #determine if we have all needed arguments (dir and action, we don't need files, if empty, we use *)
    check();

    #dry run
    dryrun() unless $dryrun;

    #do it now!
    foreach my $dir ( @searchpattern ) {
        foreach ( @filepattern ) {
            my $path = "$dir"."/"."$_";
            if ( -f glob($path) ) {
                @result = `$action $path`;
                }
        }
    }
    print "\n";
    foreach ( @result ) {
        print "$_";
    }
    print "\n";
}

main();
__END__

=head1 NAME

searchand.pl - Search and perform som action

=head1 SYNOPSYS

searchand.pl [options]

=head1 OPTIONS

=over 12

=item B<-run>

By default, searchand.pl is in dry run state; i.e: no action is taken, unless one use the -run (or -r) option.

=item B<-help>

help message

=item B<-directory>

the directory (directories) where to look

=item B<-file>

the file(s) pattern(s) to look for

=item B<-action>

the action to take when a match is done

=back

=head1 DESCRIPTION

B<searchand.pl> is a perl program that will search in a list of directories some file patterns and take action on them.

When the program is called, it parses the command line arguments if any. It then decides if it needs more information.

=head1 EXAMPLES

=over 5

=item searchand.pl

Invoking searchand.pl in this way will bring you to full interactive mode. Let the program guide you. -r is omitted, no action taken.

=item searchand.pl -help

Will print this help and quit.

=item searchand.pl -r

By default, searchand.pl is in dry run state. That is, by default, it will NOT perorm any action at all. You MUST specify the -r option to actually take any action you want.

=item searchand.pl -directory /path/to/dir -file myfile.txt -action rm

searchand.pl will in this case try to locate myfile.txt in /path/to/dir and, if found, delete it. Exit status depends on existance of such a file and permission to remove it. -r is omitted, no action taken.

=item searchand.pl -d /path/to/dir -d /other/path -a 'ls -l'

searchand.pl should then list all files in /path/to/dir and in /other/path. This could be achieved by giving multiple path with comma separated values (-d /path/to/dir,/other/path). Note that in order to take the -l into account, you need to quote the entire command. -r is omitted, no action taken.

=item searchand.pl -d /path/to/file,/other/path -a 'rm -f' -f *.doc,*.ppt -r

searchand.pl will look for all .doc and .ppt files in /path/to/file and /other/path to remove them, with force if necessary. The -r option is given, action will be taken.

=back

=head1 AUTHOR

Alexandre Boyer, 2011.
biggnou@gmail.com

=cut
