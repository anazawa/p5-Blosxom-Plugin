package Blosxom::Plugin::Core;
use strict;
use warnings;

sub begin {
    my ( $class, $c, $conf ) = @_;
    $c->load_components( qw/Util Request Response DataSection/ );
    $c->add_method( render => \&_render );
    $c->add_method( get_template => \&_get_template );
    return;
}

sub _get_template {
    my $class = shift;
    my %args  = @_ == 1 ? ( component => shift ) : @_;

    $args{component} ||= $class;
    $args{path}      ||= $class->request->path_info;
    $args{flavour}   ||= $class->request->flavour;

    if ( ref $blosxom::template eq 'CODE' ) {
        return $blosxom::template->( @args{qw/path component flavour/} );
    }

    return;
}

sub _render {
    my ( $class, $basename ) = @_;

    if ( ref $blosxom::interpolate eq 'CODE' ) {
        if ( my ($component, $flavour) = $basename =~ /(.*)\.([^.]*)/ ) {
            return $blosxom::interpolate->(
                $class->get_template(
                    component => $component,
                    flavour   => $flavour,
                )
            );
        }
    }

    return;
}

1;
