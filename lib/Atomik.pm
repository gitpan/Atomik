# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik.pm 67844 2008-08-05T05:59:28.733654Z daisuke  $

package Atomik;
use strict;
use constant HAVE_LIBXML => eval { require XML::LibXML; 1 } || 0;
our $VERSION = '0.00001';

BEGIN
{
    if (HAVE_LIBXML) {
        require Atomik::LibXML::Entry;
        require Atomik::LibXML::Feed;
        require Atomik::LibXML::Service;
    }
}


1;

__END__

=head1 NAME

Atomik - An Atom/AtomPub Framework

=head1 SYNOPSIS

  use Atomik::Feed;
  my $feed = Atomik::Feed->new();
  
  use Atomik::Client;

  my $client = Atomik::Client->new(
    username => ...,
    password => ...
  );

  my $service = $client->service_get( uri => $service_uri );
  my $feed    = $client->feed_get( uri => $feed_uri );
  my $entry   = $client->entry_get( uri => $entry_uri );
  $client->entry_create(
    uri => $entry_uri,
    entry => $entry
  );

=head1 DESCRIPTION

Atomik is yet another Atom / AtomPub framework. Please note that this module's
APIs and internals are still in flux. I welcome suggestions and patches

=head1 AUTHOR

Daisuke Maki C<< <daisuke@endeworks.jp> >>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

