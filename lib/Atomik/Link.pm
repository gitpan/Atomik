# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Link.pm 68153 2008-08-10T22:30:30.128940Z daisuke  $

package Atomik::Link;
use Moose;
use MooseX::DOM;

has_dom_root 'link';
has_dom_attr 'href';
has_dom_attr 'hreflang';
has_dom_attr 'length';
has_dom_attr 'rel';
has_dom_attr 'title';
has_dom_attr 'type';

no Moose;
no MooseX::DOM;

1;
