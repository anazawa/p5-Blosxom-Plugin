use strict;
use Test::More tests => 3;

package blosxom;

our $header = {};
our $static_entries = 0;

package foo;
use base 'Blosxom::Plugin';

__PACKAGE__->load_plugins( 'Foo' );

sub start { !$blosxom::static_entries }

sub last {
    my $class = shift;
    $class->res->status( 304 ) if $class->req->method eq 'GET';
    $class->foo;
}

package bar;
use Blosxom::Plugin::Response qw/res/;

sub start { !$blosxom::static_entries }

sub last {
    my $class = shift;
    $class->res->header->set( Bar => 'baz' );
}

package main;

my @plugins = qw( foo bar );
local $ENV{REQUEST_METHOD} = 'GET';

for my $plugin ( @plugins ) {
    ok $plugin->start();
}

for my $plugin ( @plugins ) {
    $plugin->last();
}

is_deeply $blosxom::header, {
    -foo => 'bar',
    -bar => 'baz',
    -status => '304 Not Modified',
};
