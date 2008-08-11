# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/WSSE.pm 67913 2008-08-06T02:30:36.602415Z daisuke  $

package Atomik::WSSE;
use Moose;
use Moose::Util::TypeConstraints;
use DateTime;
use Digest::SHA1 ();
use MIME::Base64 ();

coerce 'Atomik::WSSE'
    => from 'HashRef'
    => via {
        return Atomik::WSSE->new(%$_)
    }
;

has 'username' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'password' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub nonce {
    Digest::SHA1::sha1( Digest::SHA1::sha1(time(), {}, rand(), $$) )
}

sub set_headers {
    my ($self, $request) = @_;

    my $nonce   = $self->nonce;
    my $encoded = MIME::Base64::encode_base64($nonce, '');
    my $now     = DateTime->now(time_zone => 'UTC')->iso8601;
    my $digest  = MIME::Base64::encode_base64(
        Digest::SHA1::sha1($nonce, $now, $self->password || ''), ''
    );
    $request->header('X-WSSE', sprintf
      qq(UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"),
      $self->username || '', $digest, $encoded, $now);
    $request->header('Authorization', 'WSSE profile="UsernameToken"');
}

1;

