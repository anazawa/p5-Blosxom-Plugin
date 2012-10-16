package Blosxom::Plugin::Util;
use strict;
use warnings;
use CGI::Header;

sub init {
    my ( $class, $context ) = @_;
    $context->add_method( headers => \&_headers );
}

sub _headers {
    my ( $class, $header ) = @_;
    CGI::Header->new( $header );
}

1;
