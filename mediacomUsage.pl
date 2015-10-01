#!/usr/bin/perl
# Author: Paul Beach
# Script to obtain current internet usage metrics from Mediacom website
# Last updated: 30 Sep 15

use WWW::Mechanize;
use WWW::Mechanize::Plugin::FollowMetaRedirect;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0; #complains about certificate verifiation otherwise

$username = 'username@mediacombb.net';
$password = 'ReallyGoodPassword';

my $mech = WWW::Mechanize->new(autocheck => 1); #Launch a WWW::Mech instance

$mech->get("http://mediacomtoday.com/usagemeter"); #Load the usagemeter webpage
$mech->submit_form(); # The first of many unnecessary redirects
$mech->set_visible($username, $password); # Enter our username and password into the visible form fields
$mech->click(); # Submit the form
$mech->click(); # Redirect number 2
$mech->follow_meta_redirect; # Redirect number 3
$mech->submit_form(); # Redirect number 4
$mech->submit_form(); # 5... Are you kidding me?
$mech->get("http://www.mediacomtoday.com/usagemeter/usagemeter.php"); # Load an iframe...
$mech->submit_form(); # 6... for good measure
 
# Parse the usagemeter.php page for the relevant info (usage, dates)
@values = split(';',$mech->content()); # Split out the data into something I can easily parse
my @usage = grep /usageCurrentData\.push/,@values; # Find the overall usage
my @up = grep /usageCurrentUpData\.push/,@values; # My upload bandwidth
my @down = grep /usageCurrentDnData\.push/,@values; # My download bandwidth
my @dates = grep /usageCurrentCategories\.push/,@values; # The billing period

# Clean up leading whitespace
@usage[0] =~ s/^\s+//;
@up[0] =~ s/^\s+//;
@down[0] =~ s/^\s+//;
@dates[0] =~ s/^\s+//;

# Trim out useful information
@usage[0] = substr($usage[0], 22, length($usage[0])-23);
@up[0] = substr($up[0], 24, length($up[0])-25);
@down[0] = substr($down[0], 24, length($down[0])-25);
@dates[0] = substr($dates[0], 29, length($dates[0])-31);

my $mediacomDates = 'mediacomDates.txt';
open(my $fh, '>', $mediacomDates) or die "Could not open '$mediacomDates' $!";
print $fh "$dates[0]";
close $fh;

# More cleanup
@dates = split('-',@dates[0]);
@dates[0] =~ s/\s+$//;
@dates[1] =~ s/^\s+//;

print "$usage[0]\n";
print "$up[0]\n";
print "$down[0]\n";
print "$dates[0]\n@dates[1]";

my $mediacomUsage = 'mediacomUsage.txt';
open(my $fh, '>', $mediacomUsage) or die "Could not open '$mediacomUsage' $!";
print $fh "$usage[0]";
close $fh;

exit 0;

# Future stuff to do
# - Send usage warning emails
# - Shutdown WAN link if nearing overage
# - Restart WAN link after new billing cycle
