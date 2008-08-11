# $Id$

package Atomik::Content;
use Moose;
use MooseX::DOM;

has_dom_root 'content';
has_dom_content 'data';

no Moose;
no MooseX::DOM;

1;