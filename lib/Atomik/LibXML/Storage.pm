# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Storage.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::LibXML::Storage;
use Moose;
use XML::LibXML;

with 'Atomik::Storage';

has 'libxml' => (
    is => 'rw',
    isa => 'XML::LibXML::Node',
    required => 1,
    handles => [
        qw(getAttributeNS toString)
    ]
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub BUILDARGS {
    my ($class, %args) = @_;

    my $libxml = delete $args{libxml};
    if ($libxml) {
        if ( $libxml->isa('XML::LibXML::Document') ) {
            $libxml = $libxml->documentElement();
        }

        $libxml = $libxml->cloneNode(1);
    }

    return { %args, libxml => $libxml };
}

sub from_any {
    my ($class, $thing) = @_;

    if (blessed $thing) {
        if ( $thing->isa('XML::LibXML::Node') ) {
            return $class->new( libxml => $thing );
        }
    }
    confess "don't know what to do with $thing";
}

sub findnodes_from_tagname {
    my ($self, %args) = @_;

    my $tag = $args{tag};
    my @nodes;
    if (my $ns = $args{namespace}) {
        @nodes = $self->libxml->getElementsByTagNameNS($ns, $tag);
    } else {
        @nodes = $self->libxml->getElementsByTagName($tag);
    }

    if ($args{strip}) {
        foreach (@nodes) {
            $_ = $_->textContent;
        }
    }

    return wantarray ? @nodes : $nodes[0];
}

sub findchildren_from_tagname {
    my ($self, %args) = @_;

    my $tag = $args{tag};
    my $ns = $args{namespace};
    my @nodes;
    if ($ns) {
        @nodes = $self->libxml->getChildrenByTagNameNS( $ns, $tag);
    } else {
        @nodes = $self->libxml->getChildrenByTagName( $tag );
    }

    if ($args{strip}) {
        foreach (@nodes) {
            $_ = $_->textContent;
        }
    }

    return wantarray ? @nodes : $nodes[0];
}

sub find_attr {
    my ($self, %args) = @_;
    return $self->libxml->getAttribute($args{attr});
}

sub set_attr {
    my ($self, %args) = @_;
    return $self->libxml->setAttribute($args{attr}, $args{value});
}

sub set_child {
    my ($self, %args) = @_;
    my $node = $self->findchildren_from_tagname(%args);
    my $root = $self->libxml;
    if ($node) {
        $root->removeChild($node);
    }

    my $elem = $root->ownerDocument()->createElementNS($args{namespace}, $args{tag});
    $elem->appendText( $args{content} );
    $root->appendChild($elem);
    $root;
}


1;