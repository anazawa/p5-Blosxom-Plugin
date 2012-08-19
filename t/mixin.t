use strict;
use warnings;
use Test::More tests => 1;

$INC{'MyComponent.pm'}++;

package MyComponent;

sub begin {
    my ( $class, $c ) = @_;
    no warnings 'redefine';
    $c->add_method( foo => \&_foo );
}

sub _foo { 'MyComponent foo' }

package my_plugin;
use parent 'Blosxom::Plugin';
__PACKAGE__->load_components( '+MyComponent' );

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';
is $plugin->foo, 'MyComponent foo';


