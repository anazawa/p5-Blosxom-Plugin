package Blosxom::Plugin::DataSection;
use strict;
use warnings;
use Data::Section::Simple;

sub begin {
    my $class  = shift;
    my $c      = shift;
    my $reader = Data::Section::Simple->new( $c );
    my $data   = $reader->get_data_section;

    while ( my ($basename, $template) = each %{ $data } ) {
        if ( my ($component, $flavour) = $basename =~ /(.*)\.([^.]*)/ ) {
            $blosxom::template{$flavour}{$component} = $template;
        }
    }

    $c->add_method( data_section => sub { $data } );

    return;
}

1;
