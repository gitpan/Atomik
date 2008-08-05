# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Client/RequestFactory.pm 67588 2008-07-31T05:00:38.496278Z daisuke  $

package Atomik::Client::RequestFactory;
use Moose;

__PACKAGE__->meta->make_immutable;

no Moose;

sub create {
    my ($self, %args) = @_;

    if (! $args{uri}) {
        confess "parameter 'uri' is required";
    }

    my $method = $args{method} || 'GET';
    my $request =  HTTP::Request->new($method => $args{uri});

    if (my $h = $args{headers}) {
        $request->headers->header(%$h);
    }

    if (my $c = $args{content}) {
        $request->content($c);
    }

    return $request;
}

1;