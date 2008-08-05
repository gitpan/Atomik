# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Element.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::LibXML::Element;
use Moose;
use Atomik::LibXML::Storage;
use Atomik::LibXML::Moose;

extends 'Atomik::Element';

has '+storage' => (
    isa => 'Atomik::LibXML::Storage',
);

has '+namespace' => (
    default => "http://www.w3.org/2005/Atom"
);

has '+version' => (
    default => '1.0'
);

has_atomik_child 'id';

has_atomik_versioned_element 'modified' => (
    '1.0' => 'modified',
    '0.3' => 'updated'
);

no Moose;

sub as_xml { shift->storage->libxml->toString(1) }

my %NS2VERSION = (
    "http://purl.org/atom/ns#" => '0.3',
    "http://www.w3.org/2005/Atom" => '1.0',
    "http://www.w3.org/2007/app" => '1.0', # AtomPub
);

sub BUILDARGS {
    my ( $class, %args ) = @_;

    my %ret = %args;
    if (my $storage = $args{storage}) {
        my $namespace = $storage->libxml->namespaceURI();
        $ret{namespace} = $namespace;
        $ret{version}   = $NS2VERSION{ $namespace };
    }
    return \%ret;
}

sub from_file {
    my ($class, $filename) = @_;

    my $dom = eval { XML::LibXML->new->parse_file( $filename ) };
    if (! $dom) {
        confess "Failed to parse file $filename: $@";
    }

    $class->new(
        storage => Atomik::LibXML::Storage->new(
            libxml => $dom
        )
    );
}

sub from_xml {
    my ($class, $xml) = @_;

    my $dom = eval { XML::LibXML->new->parse_string( $xml ) };
    if (! $dom) {
        confess "Failed to parse string $xml: $@";
    }

    $class->new(
        storage => Atomik::LibXML::Storage->new(
            libxml => $dom
        )
    );
}

1;
