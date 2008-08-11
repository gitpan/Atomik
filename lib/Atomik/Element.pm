# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Element.pm 68160 2008-08-10T23:55:31.147997Z daisuke  $

package Atomik::Element;
use Moose;

has 'storage' => ( is => 'rw', does => 'Atomik::Storage' );

has 'namespace' => (
    is => 'rw',
    isa => 'Str',
);

has 'version' => (
    is => 'rw',
    isa => 'Num',
);

no Moose;

my %NS2VERSION = (
    "http://purl.org/atom/ns#" => '0.3',
    "http://www.w3.org/2005/Atom" => '1.0',
    "http://www.w3.org/2007/app" => '1.0', # AtomPub
);

sub BUILD {
    my $self = shift;

    if (my $node = $self->node) {
        my $namespace = $node->namespaceURI();
        $self->namespace( $namespace );
        $self->version( $NS2VERSION{ $namespace } );
    }
    return $self;
}

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