# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Workspace.pm 68155 2008-08-10T23:43:48.443812Z daisuke  $

package Atomik::Workspace;
use Moose;
use MooseX::DOM;

has_dom_root 'workspace';

no Moose;
no MooseX::DOM;

1;