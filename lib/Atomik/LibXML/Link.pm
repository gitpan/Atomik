# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Link.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::LibXML::Link;
use Moose;
use Atomik::LibXML::Moose qw(has_atomik_attr);

extends 'Atomik::LibXML::Element';
with 'Atomik::Link';

has '+storage' => (
    default => sub { 
        Atomik::LibXML::Storage->new(
            libxml => XML::LibXML->new->parse_string(<<EOXML)
<?xml version="1.0"?>
<link xmlns="http://www.w3.org/2005/Atom" />
EOXML
        );
    }
);

has_atomik_attr($_) for qw(rel href hreflang title type length);

no Moose;

sub BUILD {
    my ($self, $args) = @_;

    foreach my $key qw(rel href hreflang title type length) {
        return unless defined $args->{$key};
        $self->$key( $args->{$key} );
    }
    $self;
}

1;
