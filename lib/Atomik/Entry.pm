# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Entry.pm 68156 2008-08-10T23:46:14.974605Z daisuke  $

package Atomik::Entry;
use Moose;
use MooseX::DOM;
use Atomik;
use Atomik::Link;
use Atomik::Author;
use Atomik::Content;

extends 'Atomik::Element';

has_dom_root 'entry';
has_dom_child 'id';
has_dom_child 'title';
has_dom_child 'created';
has_dom_child 'summary';
has_dom_child 'content' => (
    filter => sub {
        my $self = shift;
        my @ret = map { Atomik::Content->new(node => $_) } @_;
        wantarray ? @ret : $ret[0];
    }
);

has_dom_child 'author' => (
    filter => sub {
        my $self = shift;
        my @ret = map { Atomik::Author->new(node => $_) } @_;
        wantarray ? @ret : $ret[0];
    }
);
has_dom_children 'links' => (
    tag => 'link',
    filter => sub {
        my $self = shift;
        return map { Atomik::Link->new(node => $_) } @_;
    }
);

has_dom_child '__modified', tag => 'modified';
has_dom_child '__updated', tag => 'updated';

no Moose;
no MooseX::DOM;

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
