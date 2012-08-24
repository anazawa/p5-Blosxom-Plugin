use strict;
use warnings;
use Test::More tests => 1;
use Test::Exception;

package my_plugin;
use parent 'Blosxom::Plugin';

package main;

my $plugin = 'my_plugin';

$plugin->instance->add_method( foo => sub { 'foo' } );

my $expected = qr/^Can't locate object method "bar" via package "my_plugin"/;
throws_ok { $plugin->bar } $expected;
