use strict;
use Test::More (tests => 7);

BEGIN
{
    use_ok("Atomik::MediaType");
}

{
    my $mt = Atomik::MediaType->new(
        type => "application",
        subtype => "atomsvc+xml",
    );
    ok($mt);
    isa_ok($mt, "Atomik::MediaType");
    is($mt->type, "application");
    is($mt->subtype, "atomsvc+xml");
    is($mt->subtype_major, "atomsvc");
    is($mt->subtype_minor, "xml");
}