use strict;
use warnings;
use Test::More tests => 3;

$INC{'MyComponent.pm'}++;

package MyComponent;

sub begin {
    my ( $class, $c ) = @_;
    $c->add_method( bar => sub { 'MyComponent bar' } );
    $c->add_method( baz => sub { 'MyComponent baz' } );
}

package my_plugin;
use parent 'Blosxom::Plugin';

__PACKAGE__->load_components( '+MyComponent' );

sub foo { 'my_plugin foo' }
sub baz { 'my_plugin baz' }

package main;

my $plugin = 'my_plugin';
is $plugin->foo, 'my_plugin foo';
is $plugin->bar, 'MyComponent bar';
is $plugin->baz, 'my_plugin baz';
