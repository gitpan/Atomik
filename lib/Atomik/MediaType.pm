# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/MediaType.pm 67588 2008-07-31T05:00:38.496278Z daisuke  $

package Atomik::MediaType;
use Moose;
use Moose::Util::TypeConstraints qw(coerce from via);

use overload
    '""' => \&as_string,
    fallback => 1
;

coerce 'Atomik::MediaType'
    => from 'Str'
    => via {
        Atom::MediaType->from_string( $_ );
    }
;

has 'type' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'subtype_major' => (
    is => 'rw',
    isa => 'Str',
);

has 'subtype_minor' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

has 'parameters' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub BUILDARGS {
    my ($class, %args) = @_;

    if (my $subtype = delete $args{subtype}) {
        my ($subtype_major, $subtype_minor);
        if ($subtype =~ /^([^\+]+)\+(.+)$/) {
            $subtype_major = $1;
            $subtype_minor = $2;
        } else {
            $subtype_major = $subtype;
        }

        $args{subtype_major} = $subtype_major;
        $args{subtype_minor} = $subtype_minor;
    }

    return { %args };
}

sub subtype {
    my $self = shift;
    my @subtype = ( $self->subtype_major );
    if (my $minor = $self->subtype_minor) {
        push @subtype, $minor;
    }
    return join('+', @subtype);
}

# XXX - bad naming.
sub assert_subtype_of {
    my ($self, $other) = @_;

    if (! blessed $other) {
        $other = Atomik::MediaType->from_string($other);
    }

    if (! $self->is_subtype($other)) {
        confess "$other is not a subtype of $self";
    }
}

sub from_string {
    my ($class, $string) = @_;
    if ($string !~ /^([^\/]+)\/([^;]+)\s*(?:;\s*(.*))?$/) {
        confess "Could not parse '$string' as a media type";
    }
    my ($type, $subtype, $parameters) = ($1, $2, $3);

    my $obj = $class->new(
        type       => $type,
        subtype    => $subtype,
        parameters => $parameters,
    );
    return $obj;
}

sub as_string {
    my $self = shift;

    my @components = ($self->type);
    if (my $subtype = $self->subtype) {
        push @components, $subtype;
    }

    if (my $parameters = $self->parameters) {
        push @components, $parameters;
    }

    if (@components == 3) {
        return sprintf('%s/%s;%s', @components);
    } elsif (@components == 2) {
        return sprintf('%s/%s', @components);
    } else {
        return $components[0];
    }
}

sub is_subtype {
    my ($self, $other) = @_;

    # wild card against something is always true
    if ( $self->type eq '*' ) {
        return 1;
    }

    # if the main types do not match, then this is false
    if ( $self->type ne $other->type ) {
        return 0;
    }

    if ( $self->subtype eq '*' ) {
        return 1;
    }

    if (! $other->subtype_minor) {
        if ($self->subtype_major ne $other->subtype_major) {
            return 0;
        }
    } elsif ( $self->subtype ne $other->subtype ) {
        return 0;
    }

    # if parameters exist, they must be compared iff BOTH medias
    # have a parameter list
    if ( ! $self->parameters || ! $other->parameters) {
        return 1;
    }

    return $self->parameters eq $other->parameters;
}

# pre-defined types.
# this is placed last so that we can safely use class methods at BEGIN time
our $INITIALIZED;
if (! $INITIALIZED) {
    my %TYPES = (
        entry    => 'application/atom+xml;type=entry',
        feed     => 'application/atom+xml;type=feed',
        service  => 'application/atomsvc+xml',
        category => 'application/atomcat+xml',
    );
    require constant;
    while ( my ($name, $type) = each %TYPES ) {
        my $obj = __PACKAGE__->from_string($type) ;
        constant->import( uc $name => $obj );
    }
    $INITIALIZED = 1;
}
use Sub::Exporter -setup => {
    exports => [ qw(ENTRY FEED SERVICE CATEGORY) ]
};

1;
