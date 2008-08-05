# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/Service.pm 67814 2008-08-05T03:10:41.547446Z daisuke  $

package Atomik::Service;
use Moose::Role;
use Atomik;

no Moose;

foreach my $type qw(file xml string any) {
    my $code = sprintf( <<'EOSUB', $type, $type );
        sub from_%s {
            my $class = shift;
            if (&Atomik::HAVE_LIBXML) {
                return Atomik::LibXML::Service->from_%s( @_ );
            } else {
                confess "not implemented";
            }
        }
EOSUB
    eval $code;
    confess $@ if $@;
}

1;