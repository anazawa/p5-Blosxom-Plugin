package Blosxom::Plugin::Default;
use strict;
use warnings;

sub begin {
    my ( $class, $c, $conf ) = @_;

    $c->load_plugins(qw/Util Request Response/);

    $c->add_methods(
        render       => \&_render,
        get_template => \&_get_template,
    );

    return;
}

sub _render {
    my ( $class, $template ) = @_;

    if ( ref $blosxom::interpolate eq 'CODE' ) {
        return $blosxom::interpolate->( $template );
    }

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

1;
