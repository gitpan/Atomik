#line 1
package Test::Moose;

use strict;
use warnings;

use Sub::Exporter;
use Test::Builder;

use Moose::Util 'does_role', 'find_meta';

our $VERSION   = '0.55';
our $AUTHORITY = 'cpan:STEVAN';

my @exports = qw[
    meta_ok
    does_ok 
    has_attribute_ok
];

Sub::Exporter::setup_exporter({
    exports => \@exports,
    groups  => { default => \@exports }
});

## the test builder instance ...

my $Test = Test::Builder->new;

## exported functions

sub meta_ok ($;$) {
    my ($class_or_obj, $message) = @_;
    
    $message ||= "The object has a meta";
    
    if (find_meta($class_or_obj)) {
        return $Test->ok(1, $message)
    }
    else {
        return $Test->ok(0, $message);  
    }
}

sub does_ok ($$;$) {
    my ($class_or_obj, $does, $message) = @_;
    
    $message ||= "The object does $does";
    
    if (does_role($class_or_obj, $does)) {
        return $Test->ok(1, $message)
    }
    else {
        return $Test->ok(0, $message);  
    }
}

sub has_attribute_ok ($$;$) {
    my ($class_or_obj, $attr_name, $message) = @_;
    
    $message ||= "The object does has an attribute named $attr_name";
    
    my $meta = find_meta($class_or_obj);    
    
    if ($meta->find_attribute_by_name($attr_name)) {
        return $Test->ok(1, $message)
    }
    else {
        return $Test->ok(0, $message);  
    }    
}

1;

__END__

#line 167

