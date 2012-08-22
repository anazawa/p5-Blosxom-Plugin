use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

package my_plugin;
use parent 'Blosxom::Plugin';

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';

$plugin->add_method( bar => sub { 'bar method' } );
ok $plugin->can('bar'), 'add method';

$plugin->add_method( foo => sub { 'foo redefined' } );
is $plugin->foo, 'my_plugin foo', 'cannot override methods';

my $expected = qr/^Not a CODE reference/;
throws_ok { $plugin->add_method( 'bar' ) } $expected;

$expected = qr/^Method name conflict for "bar"/;
throws_ok { $plugin->add_method( bar => sub {} ) } $expected;
