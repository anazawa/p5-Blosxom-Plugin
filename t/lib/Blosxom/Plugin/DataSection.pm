package Blosxom::Plugin::DataSection;
use strict;
use warnings;
use Data::Section::Simple;

sub begin {
    my ( $class, $c, $conf ) = @_;
    my $reader = Data::Section::Simple->new( $c );
    my $method = sub { $reader->get_data_section( $_[1] ) };
    $c->add_method( get_data_section => $method );
}

1;
