use strict;
use Test::More;

BEGIN
{
    if (! $ENV{ HB_USERNAME } || ! $ENV{ HB_PASSWORD } ) {
        plan(skip_all => "Set HB_USERNAME and HB_PASSWORD to run these tests");
    } else {
        plan(tests => 2);
    }

    use_ok("Atomik::Client");
}

my $client = Atomik::Client->new(
    wsse => {
        username => $ENV{HB_USERNAME},
        password => $ENV{HB_PASSWORD},
    },
    debug    => $ENV{ATOMIK_DEBUG},
);
$client->user_agent->timeout(60);

#{
#    my $feed = $client->feed_get( uri => "http://b.hatena.ne.jp/atom/feed" );
#    ok($feed);
#}

{
    my $entry = Atomik::Entry->new();
    $entry->title( 'Atomik Test (' . __FILE__ . ')');
    $entry->add_links(
        Atomik::Link->new(
            rel => "related",
            type => "text/html",
            href => "http://search.coan.org/dist/Atompub"
        )
    );
    $entry->summary("[atomik] Atomik Test");

    my ($entry_uri) = $client->entry_create(
        uri => "http://b.hatena.ne.jp/atom/post",
        entry => $entry
    );

    ok($entry_uri);

    $entry->title('Atomik Test #edit');
    $client->entry_update(
        uri => $entry_uri,
        entry => $entry
    );

    $client->entry_delete(
        uri => $entry_uri
    );
}