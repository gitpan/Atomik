# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Feed.pm 68160 2008-08-10T23:55:31.147997Z daisuke  $

package Atomik::Feed;
use Moose;
use MooseX::DOM;
use Atomik::Author;
use Atomik::Entry;

extends 'Atomik::Element';

has_dom_child 'title';
has_dom_children 'entries' => (
    tag => 'entry',
    filter => sub {
        my ($self, @nodes) = @_;
        return map { 
            Atomik::Entry->new(
                node => $_,
            )
        } @nodes;
    }
);
has_dom_child '__modified', tag => 'modified';
has_dom_child '__updated', tag => 'updated';

no Moose;

*modified = \&updated;
sub updated {
    my $self = shift;
    my $method;
    if ($self->version eq '0.3') {
        $method = '__modified';
    } else {
        $method = '__updated';
    }

    return $self->$method(@_);
}


1;