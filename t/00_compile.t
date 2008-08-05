use strict;
use Test::More;
BEGIN { require Test::UseAllModules };
if ($@) {
    plan(skip_all => "Test::UsEAllModules required for testing compilation: $@");
} else {
    Test::UseAllModules::all_uses_ok();
}