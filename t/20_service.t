use strict;
use lib("t/lib");
use Test::More;
use Test::Atomik
    tests => 3,
    network => 1,
    env_requires => [
        qw(SERVICE_DOCUMENT_URL)
    ]
;

BEGIN
{
    use_ok("Atomik::Client");
}

{
    my $client = Atomik::Client->new();
    my $service = $client->service_get( uri => $ENV{ SERVICE_DOCUMENT_URL } );

    ok($service);
    isa_ok($service, &Atomik::HAVE_LIBXML ? "Atomik::LibXML::Service" : "Hoge");
}