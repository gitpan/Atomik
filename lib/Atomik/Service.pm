# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Service.pm 68155 2008-08-10T23:43:48.443812Z daisuke  $

package Atomik::Service;
use Moose;
use MooseX::DOM;
use Atomik::Workspace;

extends 'Atomik::Element';

has_dom_children 'workspaces' => (
    tag => 'workspace',
    filter => sub {
        my $self = shift;
        return map { Atomik::Workspace->new(node => $_) } @_;
    }
);

no Moose;
no MooseX::DOM;

1;