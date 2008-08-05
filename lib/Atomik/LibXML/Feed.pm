# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Feed.pm 67814 2008-08-05T03:10:41.547446Z daisuke  $

package Atomik::LibXML::Feed;
use Moose;
use Atomik::LibXML::Entry;
use Atomik::LibXML::Moose;
use constant W3_NAMESPACE => 'http://www.w3.org/XML/1998/namespace';

extends 'Atomik::LibXML::Element';
with 'Atomik::Feed';

has '+storage' => (
    handles => [ qw(toString) ]
);

has_atomik_versioned_element 'updated' => (
    '1.0' => 'updated',
    '0.3' => 'modified',
);

has_atomik_object_list 'entries' => (
    class => 'Atomik::LibXML::Entry',
    tag   => 'entry',
);

no Moose;

sub language {
    my $self = shift;
    my $storage = $self->storage;
    if (@_) {
        $storage->setAttributeNS( &W3_NAMESPACE, 'lang', $_[0] );
    }
    return $storage->getAttributeNS( &W3_NAMESPACE, 'lang' );
}

1;
