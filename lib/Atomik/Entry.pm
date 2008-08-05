# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Entry.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::Entry;
use Moose::Role;
use Atomik;
use Atomik::Link;

our $AUTOLOAD;

requires qw(from_file from_xml from_any);

no Moose;

sub AUTOLOAD {
    my ($class, @args) = @_;

    if ($class ne 'Atomik::Entry') {
        confess "No such method $AUTOLOAD";
    }

    my $method = $AUTOLOAD;
    if (&Atomik::HAVE_LIBXML) {
        $method =~ s/^.*:://;
        return Atomik::LibXML::Entry->$method(@args);
    }
}

1;
