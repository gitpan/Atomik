# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Feed.pm 67814 2008-08-05T03:10:41.547446Z daisuke  $

package Atomik::Feed;
use Moose::Role;
use Atomik;
our $AUTOLOAD;

requires qw(from_file from_xml from_any);

no Moose;

sub AUTOLOAD {
    my ($class, @args) = @_;

    if ($class ne 'Atomik::Feed') {
        confess "No such method $AUTOLOAD";
    }

    my $method = $AUTOLOAD;
    if (&Atomik::HAVE_LIBXML) {
        $method =~ s/^.*:://;
        return Atomik::LibXML::Feed->$method(@args);
    }
}


1;