use strict;
use Test::More (tests => 5);
use Test::Moose;

BEGIN
{
    use_ok("Atomik::Entry");
}

{
    my $entry = Atomik::Entry->from_xml( <<EOXML );
<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <title>Atom-Powered Robots Run Amok</title>
  <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
  <updated>2003-12-13T18:30:02Z</updated>
  <author><name>John Doe</name></author>
  <content>Some text.</content>
</entry>
EOXML

    ok($entry);
    does_ok($entry, 'Atomik::Entry');
    isa_ok($entry, &Atomik::HAVE_LIBXML ? 'Atomik::LibXML::Entry' : 'Atomik::Hoge');
    is( $entry->title, "Atom-Powered Robots Run Amok" );
}