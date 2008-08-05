# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/t/lib/Test/Atomik.pm 67843 2008-08-05T05:55:30.094900Z daisuke  $

package Test::Atomik;
use strict;
use IO::Socket::INET;

sub import {
    my ($class, %args) = @_;

    Test::More->export_to_level(1);

    my $skip;

    if ($args{network}) {
        my $socket = IO::Socket::INET->new(
            PeerAddr => 'search.cpan.org',
            PeerPort => 80
        );
        if (! $socket) {
            $skip = "No network available";
            goto SKIP_TESTS;
        }
    }

    if (my $names = $args{env_default}) {
        while (my ($name, $default) = each %$names) {
            if (! exists $ENV{$name}) {
                $ENV{$name} = $default;
            }
        }
    }

    if (my $names = $args{env_requires}) {
        foreach my $name (@$names) {
            if (! exists $ENV{$name}) {
                $skip = "required environment variable $name is not set";
                goto SKIP_TESTS;
            }
        }
    }

    Test::More::plan(tests => $args{tests});
    return;

SKIP_TESTS:
    Test::More::plan(skip_all => $skip);
}

1;
