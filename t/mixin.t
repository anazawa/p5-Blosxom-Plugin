use strict;
use warnings;
#use Test::More tests => 1;
use Test::More skip_all => 'deprecated';

$INC{'Foo.pm'}++;
$INC{'Bar.pm'}++;

package Foo;

sub begin {
    my ( $class, $c ) = @_;
    #no warnings 'redefine';
    $c->add_method( foo => \&_foo );
}

sub _foo { 'Foo foo' }

package Bar;

sub begin {
    my ( $class, $c ) = @_;
    no warnings 'redefine';
    $c->add_method( foo => \&_foo );
}

sub _foo { 'Bar foo' }

package my_plugin;
use parent 'Blosxom::Plugin';
#__PACKAGE__->load_components( '+MyComponent' );
__PACKAGE__->load_components( '+Foo', '+Bar' );

#sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';
#is $plugin->foo, 'MyComponent foo';
is $plugin->foo, 'Bar foo';


