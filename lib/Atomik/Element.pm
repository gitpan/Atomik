# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Element.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::Element;
use Moose;

has 'storage' => (
    is => 'rw',
    does => 'Atomik::Storage',
);

has 'namespace' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'version' => (
    is => 'ro',
    isa => 'Num',
    required => 1,
);

no Moose;

sub from_any {
    my ($class, $any) = @_;

    confess "no argument given to from_any" unless $any;

    my $blessed = Scalar::Util::blessed $any;
    if ($blessed) {
        if ($any->can('toString')) {
            return $class->from_xml($any->toString());
        } elsif ($any->can('as_xml')) {
            return $class->from_xml($any->as_xml());
        }

        confess "don't know how to handle $any";
    }

    my $reftype = Scalar::Util::reftype $any || '';
    if (! $reftype) {
        confess "XXX - Later (from file)";
    }

    if ($reftype eq 'SCALAR') {
        return $class->from_xml($$any);
    }

    confess "don't know how to handle $any";
}

sub element_get {
    my ($self, %args) = @_;

    my @nodes = $self->storage->findnodes_from_tagname(
        tag => $args{tag},
        namespace => $args{namespace},
        strip => 1,
    );

    return wantarray ? @nodes : $nodes[0];
}


sub __mk_element_accessor {
    my $class = shift;
    my $element = shift;
    my $code = sprintf(<<'EOSUB', blessed $class || $class, $element, $element);
        sub %s::%s {
            my $self = shift;
            my $namespace = $self->namespace;
            my $tag = '%s';
            return @_ ?
                $self->element_set(namespace => $namespace, tag => $tag, value => $_[0]) :
                $self->element_get(namespace => $namespace, tag => $tag);
        }
EOSUB
    eval $code;
    confess $@ if $@;
}


# These accessors must differ how they act depending on if the feed is
1;