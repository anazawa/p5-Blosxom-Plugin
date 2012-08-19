use strict;
use warnings;
use Test::More tests => 3;
use Test::Warn;

package my_plugin;
use parent 'Blosxom::Plugin';

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';

my $expected = 'Subroutine foo redefined';
my $code = sub { 'foo redefined' };
warning_is { $plugin->add_method( foo => $code ) } $expected;
is $plugin->foo, 'foo redefined';

{
    no warnings 'redefine';
    $plugin->add_method( foo => sub { 'foo no warnings' } );
}

is $plugin->foo, 'foo no warnings';
