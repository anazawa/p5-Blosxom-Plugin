package Blosxom::Plugin::Request;
use strict;
use warnings;
use Blosxom::Plugin::Request::Upload;
use CGI;

sub begin {
    my ( $class, $c ) = @_;
    $c->add_method( $_ => \&instance ) for qw( request req );
}

my $instance;

sub instance {
    my $class = shift;

    return $class if ref $class;
    return $instance if defined $instance;

    my %self = (
        cgi => CGI->new,
        flavour => $blosxom::flavour,
        path_info => {
            full   => $blosxom::path_info,
            yr     => $blosxom::path_info_yr,
            mo_num => $blosxom::path_info_mo_num,
            mo     => $blosxom::path_info_mo,
            da     => $blosxom::path_info_da,
        },
    );

    $instance = bless \%self;
}

sub has_instance { $instance }

sub method       { shift->{cgi}->request_method   }
sub content_type { shift->{cgi}->content_type     }
sub referer      { shift->{cgi}->referer          }
sub remote_host  { shift->{cgi}->remote_host      }
sub address      { shift->{cgi}->remote_addr      }
sub user_agent   { shift->{cgi}->user_agent( @_ ) }
sub protocol     { shift->{cgi}->server_protocol  }
sub user         { shift->{cgi}->remote_user      }

sub cookies {
    my ( $self, $name ) = @_;
    $self->{cgi}->cookie( $name );
}

sub param {
    my ( $self, $key ) = @_;
    $self->{cgi}->param( $key || () );
}

sub uploads {
    my $self  = shift;
    my $field = shift;
    my $cgi = $self->{cgi};

    if ( my $uploads = $self->{uploads}{$field} ) {
        return wantarray ? @{ $uploads } : $uploads->[0];
    } 

    my @uploads;
    for my $filename ( $cgi->param( $field ) ) {
        push @uploads, Blosxom::Plugin::Request::Upload->new(
            filename => "$filename",
            fh       => $filename,
            tempname => $cgi->tmpFileName( $filename ),
            headers  => $cgi->uploadInfo( $filename ),
        );
    }

    $self->{uploads}{$field} = \@uploads;

    wantarray ? @uploads : $uploads[0];
}

sub path_info { shift->{path_info} }
sub flavour   { shift->{flavour}   }

1;

__END__

=head1 NAME

Blosxom::Plugin::Request - Object representing CGI request

=head1 SYNOPSIS

  use Blosxom::Plugin::Request;

  my $request = Blosxom::Plugin::Request->instance;

  my $method = $request->method; # GET
  my $path_info_mo_num = $request->path_info->{mo_num}; # '07'
  my $flavour = $request->flavour; # rss
  my $page = $request->param( 'page' ); # 12
  my $id = $request->cookies( 'ID' ); # 123456

=head1 DESCRIPTION

Object representing CGI request.

=head2 CLASS METHODS

=over 4

=item Blosxom::Plugin::Request->begin

Exports C<instance()> into context class as C<request()>.
C<req()> is an alias.

=item $request = Blosxom::Plugin::Request->instance

Returns a current Blosxom::Header object instance or create a new one.

=item $request = Blosxom::Plugin::Request->has_instance

Returns a reference to any existing instance or C<undef> if none is defined.

=back

=head2 INSTANCE METHODS

=over 4

=item $request->path_info

=item $request->flavour

=item $request->cookies

=item $request->param

=item $request->method

Returns the method used to access your script, usually one of C<POST>,
C<GET> or C<HEAD>.

=item $request->content_type

Returns the content_type of data submitted in a POST, generally
C<multipart/form-data> or C<application/x-www-form-urlencoded>.

=item $request->referer

Return the URL of the page the browser was viewing prior to fetching your
script. Not available for all browsers.

=item $request->remote_host

Returns either the remote host name, or IP address if the former
is unavailable.

=item $request->user_agent

Returns the C<HTTP_USER_AGENT> variable. If you give this method a single
argument, it will attempt to pattern match on it, allowing you to do
something like:

  if ( $request->user_agent( 'Mozilla' ) ) {
      ...
  }

=item $request->address

Returns the remote host IP address, or C<127.0.0.1> if the address is
unavailable (C<REMOTE_ADDR>).

=item $request->user

Returns the authorization/verification name for user verification,
if this script is protected (C<REMOTE_USER>).

=item $request->protocol

Returns the protocol (HTTP/1.0 or HTTP/1.1) used for the current request.

=item $request->uploads

=back

=head1 SEE ALSO

L<Blosxom::Plugin>, L<Plack::Request>, L<Class::Singleton>

=head1 AUTHOR

Ryo Anazawa

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut
