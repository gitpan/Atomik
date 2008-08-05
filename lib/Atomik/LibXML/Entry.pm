# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Entry.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::LibXML::Entry;
use Moose;
use Atomik::LibXML::Moose;
use Atomik::LibXML::Content;
use Atomik::LibXML::Link;
use Atomik::LibXML::Person;
use Atomik::LibXML::Storage;

extends 'Atomik::LibXML::Element';
with 'Atomik::Entry';

has '+storage' => (
    default => sub { 
        Atomik::LibXML::Storage->new(
            libxml => XML::LibXML->new->parse_string(<<EOXML)
<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom">
</entry>
EOXML
        );
    }
);

has_atomik_object_list 'links' => (
    class => 'Atomik::LibXML::Link',
    tag   => 'link',
    singular => 'link',
);

has_atomik_child 'title';
has_atomik_child 'created';
has_atomik_child 'summary';
has_atomik_object 'content' => (
    class => 'Atomik::LibXML::Content',
    tag => 'content'
);

has_atomik_object 'author' => (
    class => 'Atomik::LibXML::Person',
    tag => 'author',
);

has_atomik_versioned_element 'modified' => (
    '0.3' => 'modified',
    '1.0' => 'updated',
);

no Moose;

1;