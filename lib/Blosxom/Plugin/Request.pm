package Blosxom::Plugin::Request;
use strict;
use warnings;
use CGI;
use CGI::Cookie;

sub init {
    my ( $class, $c, $conf ) = @_;
    $c->add_method( request => sub { __PACKAGE__->instance } );
}

my $instance;

sub instance {
    my $class = shift;
    return $instance if defined $instance;
    $instance = bless {}, $class;
}

sub method { $ENV{REQUEST_METHOD} || q{} }

sub cookies {
    my $self = shift;
    $self->{cookies} ||= CGI::Cookie->fetch;
}

sub param {
    my ( $self, $key ) = @_;
    CGI::param( $key || () );
}

1;
