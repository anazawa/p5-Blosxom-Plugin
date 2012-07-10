package Blosxom::Plugin::Response;
use strict;
use warnings;
use Blosxom::Header;

sub begin {
    my ( $class, $c, $conf ) = @_;
    my $method = sub { __PACKAGE__->instance };
    $c->add_method( $_ => $method ) for qw( response res );
}

my $instance;

sub instance {
    my $class = shift;
    return $instance if defined $instance;
    $instance = bless {}, $class;
}

sub header {
    my $self = shift;
    $self->{header} ||= Blosxom::Header->instance;
}

sub status       { shift->header->status( @_ ) }
sub content_type { shift->header->type( @_ )   }
sub cookies      { shift->header->cookie( @_ ) }

sub content_length {
    my $header = shift->header;
    return $header->set( Content_Length => shift ) if @_;
    $header->get( 'Content-Length' );
}

sub content_encoding {
    my $header = shift->header;
    return $header->set( Content_Encoding => shift ) if @_;
    $header->get( 'Content-Encoding' );
}

sub location {
    my $header = shift->header;
    return $header->set( Location => shift ) if @_;
    $header->get( 'Location' );
}

sub redirect {
    my $header = shift->header;
    $header->set( Location => shift );
    $header->status( shift || 301 );
}

sub body { $blosxom::output }

1;
