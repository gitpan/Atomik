use strict;
use Test::More (tests => 17);
use Test::Moose;
use Scalar::Util qw(blessed);

BEGIN
{
    use_ok("Atomik::Feed");
}

{
    my $feed = Atomik::Feed->from_file( "t/data/atom-full.xml" );
    ok($feed);

    ok($feed->updated, "2006-08-10T02:43:00Z");

    my $count = 0;
    my %data = (
        "http://blog.jrock.us/articles/Catalyst%20+%20Cache.pod" => {
            title => "Catalyst + Cache",
            id => "urn:guid:8D9B9CBE-27DB-11DB-B6C2-F007B8516AA5",
            modified => "2006-08-09T19:07:58Z",
            summary => undef,
            author => Atomik::Author->new(
                name => "Jonathan T. Rockway",
                email => 'jon@jroc.us'
            )
        },
        "http://blog.jrock.us/articles/Quantum%20Physics%20and%20the%20Template%20Toolkit.pod" => {
            title => "Quantum Physics and the Template Toolkit",
            id => "urn:guid:BB054AF0-2601-11DB-9738-946FBD312859",
            modified => "2006-08-07T10:44:20Z",
            author => Atomik::Author->new(
                name => "Jonathan T. Rockway",
                email => 'jon@jroc.us'
            )
        }
    );

    foreach my $entry ($feed->entries) {
        isa_ok $entry, 'Atomik::Entry', "entry from entries() is $entry";

        my @links = $entry->links;
        my $main_link = $links[0];

        my $data = $data{ $main_link->href };

        foreach my $method qw(title id modified created summary author) {
            my $expected = $data->{$method};
            my $value = $entry->$method();
            if (blessed $expected) {
                isa_ok( $value, blessed $expected, "$method is $value " . ( $expected || "(null)") );
            } else {
                is( $value, $expected, "$method is " . ($value || '(null)') . " " . ( $expected || "(null)") );
            }
        }
    }
}
