#! /usr/bin/perl
# @author: ajb@zs
# @purpose: telnet un serveur pour vérifier si il rejette les adresses invalides.

use Net::Telnet ();

my $t = new Net::Telnet;

# From: address and returned line
my ($from,$r) = '<noc@zerospam.ca>';

print "\n\tDomaine a tester ? ";
my $domain = <>;
chomp($domain);
print "\tTransport du domaine ? ";
my $transport = <>;
chomp($transport);
print "\tPort de livraison ? ";
my $port = <>;
chomp($port);
print "\n";

$t->open(Host => $transport, Port => $port);
$r = $t->getline;
print $r;
print("HELO zerospam.ca\n");
$t->print("HELO zerospam.ca");
$r = $t->getline;
print $r;
print("MAIL FROM: $from\n");
$t->print("MAIL FROM: $from");
$r = $t->getline;
print $r;
print("RCPT TO: <this-should-be-an-invalid-address-007\@$domain>\n");
$t->print("RCPT TO: <this-should-be-an-invalid-address-007@$domain>");
$r = $t->getline;
print $r;
print("QUIT\n");
$t->print("QUIT");
$r = $t->getline;
print $r;

## FOR WINDOWS CLIENTS ONLY ##
# print ("\n\n\tPRESS ENTER TO CLOSE THIS WINDOW\n");
# my $close = <>;
