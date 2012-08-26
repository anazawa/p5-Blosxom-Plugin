use strict;
use warnings;
use Test::More tests => 2;
#use Test::Exception;

$INC{'MyComponent.pm'}++;

package MyComponent;

sub init {
    my ( $class, $c ) = @_;
    $c->add_method( foo => \&_foo );
    $c->add_method( bar => \&_bar );
}

sub _foo { 'MyComponent foo' }
sub _bar { 'MyComponent bar' }

package my_plugin;
use parent 'Blosxom::Plugin';
__PACKAGE__->load_components( '+MyComponent' );

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';

#$plugin->instance->add_method( bar => sub { 'add bar()' } );
#$plugin->add_method( bar => sub { 'add bar()' } );
#is $plugin->bar, 'add bar()', 'add method';
is $plugin->bar, 'MyComponent bar', 'add method';

#$plugin->instance->add_method( foo => sub {} );
#$plugin->add_method( foo => sub {} );
is $plugin->foo, 'my_plugin foo', 'cannot override methods';

#my $expected = qr/^Must provide a CODE reference/;
#throws_ok { $plugin->instance->add_method( baz => [] ) } $expected;
#throws_ok { $plugin->add_method( baz => [] ) } $expected;

#$expected = qr/^Method name conflict for "bar"/;
#throws_ok { $plugin->instance->add_method( bar => sub {} ) } $expected;
#throws_ok { $plugin->add_method( bar => sub {} ) } $expected;
