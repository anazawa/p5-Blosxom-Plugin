package Blosxom::Plugin::DataSection;
use strict;
use warnings;
use Data::Section::Simple;

sub begin {
    my ( $class, $c, $conf ) = @_;
    my $reader = Data::Section::Simple->new( $c );
    my $data = $reader->get_data_section;
    $c->add_method( data_section => sub { $data } );
}

1;
