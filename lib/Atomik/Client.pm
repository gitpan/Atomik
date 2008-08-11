# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Client.pm 68152 2008-08-10T22:25:14.315235Z daisuke  $

package Atomik::Client;
use Moose;
use Atomik;
use Atomik::Client::RequestFactory;
use Atomik::Entry;
use Atomik::MediaType;
use Atomik::Service;
use Atomik::WSSE;
use LWP::UserAgent;

has 'wsse' => (
    is => 'rw',
    isa => 'Atomik::WSSE',
    coerce => 1,
);

has 'debug' => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

has 'strict_content_type' => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

has 'request_factory' => (
    is => 'rw',
    isa => 'Atomik::Client::RequestFactory',
    default => sub { Atomik::Client::RequestFactory->new() },
    handles => {
        request_create => 'create'
    }
);

has 'user_agent' => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    default => sub {
        LWP::UserAgent->new(
            agent => "Atomik/$Atomik::VERSION",
            timeout => 5
        )
    }
);

__PACKAGE__->meta->make_immutable;

no Moose;

# We auto-generate these methods, cause they are... the same.
BEGIN
{
    my $generator = sub {
        my $type = shift;

        eval sprintf(<<'EOSUB', $type, $type, uc $type, ucfirst $type);
            sub %s_get {
                my ($self, %%args) = @_;
                my $uri = $args{uri} || confess "no URI given to %s()";

                my $request = $self->request_create(%%args);
                my $response = $self->send_request( request => $request );

                Atomik::DEBUG( $response->as_string );

                if ( ! $response->is_success ) {
                    confess "Request to $uri failed: " . $response->as_string;
                }

                if ($self->strict_content_type) {
                    my $ct = Atomik::MediaType->from_string($response->content_type);
                    $ct->assert_subtype_of( &Atomik::MediaType::%s );
                }

                return Atomik::%s->from_xml( $response->content );
            }
EOSUB
        confess if $@;
    };

    foreach my $type qw(entry service feed category) {
        $generator->($type);
    }
}

sub entry_create {
    my ($self, %args) = @_;

    my $uri = $args{uri} || confess "no URI given to entry_create()";

    my $headers = delete $args{headers} || {};
    $headers->{'Content-Type'} ||= &Atomik::MediaType::ENTRY;
    if ($args{slug}) {
        $headers->{Slug} ||= $args{slug};
    }

    # If the entry is not an object, then coerce it
    my $entry = delete $args{entry};
    if (! blessed $entry ) {
        $entry = Atomik::Entry->from_any($entry);
    }

    my $request = $self->request_create(
        %args,
        method  => 'POST',
        content => $entry->as_xml,
        headers => $headers,
    );
    my $response = $self->send_request( request => $request );

    if (! $response->is_success ) {
        confess "Request to $uri failed: " . $response->as_string;
    }

    Atomik::DEBUG( $response->as_string );

    if (wantarray) {
        return ( $response->header('Location'), Atomik::Entry->from_xml( $response->content ) );
    } else {
        return $response->header('Location');
    }
}

sub entry_update {
    my ($self, %args) = @_;

    my $uri = $args{uri} || confess "no URI given to entry_update()";
    my $entry = $args{entry} || confess "no entry given to entry_update()";

    # If the entry is not an object, then coerce it
    if (! blessed $entry ) {
        $entry = Atomik::Entry->from_any($entry);
    }

    my $request = $self->request_create(
        %args,
        content => $entry->as_xml,
        method => 'PUT',
    );

    my $content  = $entry->as_xml();
    $request->content_type( (&Atomik::MediaType::ENTRY)->as_string );
    my $response = $self->send_request( request => $request );
    if (! $response->is_success) {
        confess "Request to $uri failed: " . $response->as_string;
    }

    if ($self->strict_content_type) {
        my $ct = Atomik::MediaType->from_string($response->content_type);
        $ct->assert_subtype_of( &Atomik::MediaType::ENTRY );
    }

    if ($self->debug) {
        print STDERR $response->as_string;
    }

    # Some so-called "atom" services don't reply back with a proper
    # xml here. in such cases, we do the best we can, and return a 0E0
    my $result = $response->content ?
        Atomik::Entry->from_xml( $response->content ) : '0E0';
    return $result;
}

sub entry_delete {
    my ($self, %args) = @_;

    my $uri = $args{uri} || confess "no URI given to entry_update()";

    my $request = $self->request_create(
        %args,
        method => 'DELETE',
    );

    $request->content_type( (&Atomik::MediaType::ENTRY)->as_string );
    my $response = $self->send_request( request => $request );
    if (! $response->is_success) {
        confess "Request to $uri failed: " . $response->as_string;
    }

    if ($self->strict_content_type) {
        my $ct = Atomik::MediaType->from_string($response->content_type);
        $ct->assert_subtype_of( &Atomik::MediaType::ENTRY );
    }

    if ($self->debug) {
        print STDERR $response->as_string;
    }

    return 1;
}

sub send_request {
    my ($self, %args) = @_;
    my $request = $args{request};
    if (my $wsse = $self->wsse) {
        $wsse->set_headers( $request );
    }

    if ($self->debug) {
        print STDERR $request->as_string;
    }
    $self->user_agent->request($request);
}

1;

__END__

=head1 NAME

Atomik::Client - An Atompub Client

=head1 SYNOPSIS

  use Atomik::Client;

  my $client = Atomik::Client->new();

  # You need to know the collection URI of whatever you're dealing with
  # before hand. One way to obtain it is by getting the service document
  my $service = $client->service( uri => $service_document_uri );

  foreach my $workspace ($service->workspaces) {
    foreach my $collection ($workspace->collections) {
      $collection->href; # this is a collection URI

      # What this URI is, is not described in the service document
    }
  }

  # if you know the collection URI, you can operate CRUD operations
  my $entry_uri = $client->entry_create(
    uri => $entry_uri,
    entry => $entry_object, 
  );
  # you can receive an Atomik::Entry, if you get the result in
  # list context
  my ($entry_uri, $entry) = $client->entry_create(...);

=head1 METHODS

=head2 new(%args)

  Atomik::Client->new(
    wsse => {
      username => $username,
      
    [ wsse_username => 
    [ use_wsse => $bool ]

=cut