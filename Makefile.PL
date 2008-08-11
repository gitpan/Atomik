use strict;
use inc::Module::Install;

name('Atomik');

all_from('lib/Atomik.pm');

requires 'Moose';
requires 'DateTime';
requires 'Digest::SHA1';
requires 'LWP::UserAgent';
requires 'MIME::Base64';
requires 'MooseX::DOM', '0.00003';

test_requires('Test::UseAllModules');
test_requires('Test::More');
test_requires('Test::Moose');
auto_include;
WriteAll;