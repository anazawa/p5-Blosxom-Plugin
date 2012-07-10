package Blosxom::Plugin::Request;
use strict;
use warnings;

sub begin {
    my ( $class, $c, $conf ) = @_;
    my $method = sub { __PACKAGE__->instance };
    $c->add_method( $_ => $method ) for qw( request req );
}

my $instance;

sub instance {
    my $class = shift;

    return $class if ref $class;
    return $instance if defined $instance;

    require CGI;

    my %self = (
        cgi => CGI->new,
        env => \%ENV,
        flavour => $blosxom::flavour,
        path_info => {
            full   => $blosxom::path_info,
            yr     => $blosxom::path_info_yr,
            mo_num => $blosxom::path_info_mo_num,
            mo     => $blosxom::path_info_mo,
            da     => $blosxom::path_info_da,
        },
    );

    $instance = bless \%self, $class;
}

sub method       { shift->{cgi}->request_method }
sub content_type { shift->{cgi}->content_type   }
sub referer      { shift->{cgi}->referer        }
sub remote_host  { shift->{cgi}->remote_host    }
sub address      { shift->{cgi}->remote_addr    }
sub user_agent   { shift->{cgi}->user_agent     }

sub cookies {
    my ( $self, $name ) = @_;
    $self->{cgi}->cookie( $name );
}

sub param {
    my ( $self, $key ) = @_;
    $self->{cgi}->param( $key || () );
}

sub path_info { shift->{path_info} }
sub flavour   { shift->{flavour}   }

1;
