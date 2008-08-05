use strict;
use lib("t/lib");
use Test::More;
use Test::Atomik
    tests => 9,
    network => 1,
    env_requires => [
        qw( ENTRY_COLLECTION_URL )
    ]
;

BEGIN
{
    use_ok("Atomik::Client");
}

{
    my $client = Atomik::Client->new();
    my ($entry_uri, $entry) = $client->entry_create(
        uri   => $ENV{ ENTRY_COLLECTION_URL },
        entry => \<<EOXML,
<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <title>Atom-Powered Robots Run Amok</title>
  <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
  <updated>2003-12-13T18:30:02Z</updated>
  <author><name>John Doe</name></author>
  <content>Some text.</content>
</entry>
EOXML
    );

    ok($entry_uri);
    ok($entry);
    isa_ok($entry, &Atomik::HAVE_LIBXML ? "Atomik::LibXML::Entry" : "Hoge");

    my ($edit) = grep { ($_->rel || '') eq 'edit' } $entry->links;
    ok( $edit );
    is( $edit->href => '.' );

    my $got_entry = $client->entry_get( uri => $entry_uri );

    ok( $got_entry, "Accessed entry $entry_uri" );
    isa_ok($entry, &Atomik::HAVE_LIBXML ? "Atomik::LibXML::Entry" : "Hoge");

    $entry->content( "New text" );

SKIP: {
    skip("Unimplemented", 1);
    my $updated_entry = $client->entry_update( uri => $entry_uri, entry => $entry );

    is( $updated_entry->content, "New text" );
}
}

