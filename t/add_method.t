use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

package my_plugin;
use parent 'Blosxom::Plugin';

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';

$plugin->instance->add_method( bar => sub { 'add bar()' } );
is $plugin->bar, 'add bar()', 'add method';

$plugin->instance->add_method( foo => sub {} );
is $plugin->foo, 'my_plugin foo', 'cannot override methods';

my $expected = qr/^Must provide a CODE reference/;
throws_ok { $plugin->instance->add_method( baz => [] ) } $expected;

$expected = qr/^Method name conflict for "bar"/;
throws_ok { $plugin->instance->add_method( bar => sub {} ) } $expected;
