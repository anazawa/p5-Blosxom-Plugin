package Blosxom::Plugin::Response;
use strict;
use warnings;
use base qw/Exporter/;
use Blosxom::Header;

our @EXPORT = qw( response res );

sub response { __PACKAGE__->instance }
*res = \&response;

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

    sub body { $blosxom::output }
}

1;
