package Blosxom::Plugin::Foo;
use strict;
use warnings;
use base qw/Exporter/;

our @EXPORT = qw( foo );

sub foo {
    my $class = shift;
    $class->response->header->set( Foo => 'bar' );
}

1;
