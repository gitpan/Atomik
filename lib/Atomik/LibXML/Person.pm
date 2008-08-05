# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Person.pm 67814 2008-08-05T03:10:41.547446Z daisuke  $

package Atomik::LibXML::Person;
use Moose;
use Atomik::LibXML::Moose;

has_atomik_child 'email';
has_atomik_child 'name';
has_atomik_child 'uri';
has_atomik_child 'url';
has_atomik_child 'homepage';

no Moose;

1;