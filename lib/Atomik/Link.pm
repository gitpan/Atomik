# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Link.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::Link;
use Moose::Role;
our $AUTOLOAD;

no Moose;

sub AUTOLOAD {
    my ($class, @args) = @_;

    if ($class ne 'Atomik::Link') {
        confess "No such method $AUTOLOAD";
    }

    my $method = $AUTOLOAD;
    if (&Atomik::HAVE_LIBXML) {
        $method =~ s/^.*:://;
        return Atomik::LibXML::Link->$method(@args);
    }
}


1;
