use strict;
use warnings;
use Test::More tests => 1;

$INC{'Foo.pm'}++;
$INC{'Bar.pm'}++;

package Foo;

sub init {
    my ( $class, $c ) = @_;
    $c->add_method( foo => \&_foo );
}

sub _foo { 'Foo foo' }

package Bar;

sub init {
    my ( $class, $c ) = @_;
    $c->add_method( foo => \&_foo );
}

sub _foo { 'Foo foo' }

package my_plugin;
use parent 'Blosxom::Plugin';

__PACKAGE__->load_components( '+Foo', '+Bar' );

package main;

ok 1;

