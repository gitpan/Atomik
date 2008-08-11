use strict;
use lib("t/lib");
use Test::More;
use Test::Atomik
    tests => 5,
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
    isa_ok($service, "Atomik::Service");

    my @workspaces = $service->workspaces ;
    my $count = ($service->as_xml() =~ /<workspace>/g);
    is(scalar @workspaces, $count, "should $count workspaces" );

    my $ok = 0;
    foreach my $workspace ( @workspaces ) {
        $ok++ if $workspace->isa( "Atomik::Workspace" );
    }
    is($ok, $count, "every workspace is a proper object");
}