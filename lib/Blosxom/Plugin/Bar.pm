package Blosxom::Plugin::Bar;
use strict;
use warnings;

sub init {
    my ( $class, $c, $conf ) = @_;
    $c->add_method( bar => sub { $conf } );
};

1;
