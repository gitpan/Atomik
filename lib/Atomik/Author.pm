# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Author.pm 68156 2008-08-10T23:46:14.974605Z daisuke  $

package Atomik::Author;
use Moose;
use MooseX::DOM;

has_dom_root 'author';
has_dom_child 'email';
has_dom_child 'name';
has_dom_child 'uri';
has_dom_child 'url';
has_dom_child 'homepage';

no Moose;
no MooseX::DOM;

1;
