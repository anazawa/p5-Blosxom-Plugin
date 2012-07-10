package Blosxom::Plugin::Response;
use strict;
use warnings;
use base qw/Exporter/;
use Blosxom::Header;

our @EXPORT_OK = qw( response );

sub response { __PACKAGE__->instance }

sub init {
    my ( $class, $c, $conf ) = @_;
    $c->add_method( response => \&response );
}

{
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
}

1;
