use strict;
use warnings;
use Test::More tests => 1;

$INC{'MyComponent.pm'}++;

package MyComponent; {

    my @requires = qw( req1 req2 );

    sub begin {
        my ( $class, $c ) = @_;

        if ( grep !$c->can($_), @requires ) {
            die "Can't apply $class to $c - missing ";
        }

        $c->add_method( bar => sub { 'MyComponent bar' } );
        $c->add_method( baz => sub { 'MyComponent baz' } );

        return;
    }
}

package my_plugin; {
    use parent 'Blosxom::Plugin';
    __PACKAGE__->load_components( '+MyComponent' );

    sub req1 {}
    sub req2 {}
    sub foo { 'my_plugin foo' }
    sub baz { 'my_plugin baz' }
}

package main;

my $plugin = 'my_plugin';
is $plugin->bar, 'MyComponent bar';
is $plugin->baz, 'my_plugin baz';

