package Blosxom::Plugin;
use 5.008_009;
use strict;
use warnings;

our $VERSION = '0.00007';

__PACKAGE__->load_plugins( qw/Util Request Response/ );

sub interpolate {
    my ( $class, $template ) = @_;

    if ( ref $blosxom::interpolate eq 'CODE' ) {
        return $blosxom::interpolate->( $template );
    }

    return;
}

sub get_template {
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

sub load_plugins {
    my $class = shift;

    while ( @_ ) {
        my $plugin = shift;
        my $config = ref $_[0] eq 'HASH' ? shift : undef;
        $class->load_plugin( $plugin, $config );
    }

    return;
}

sub load_plugin {
    my $class  = shift;
    my $plugin = join '::', __PACKAGE__, shift;
    my $config = ref $_[0] eq 'HASH' ? shift : undef;

    # load class
    ( my $file = $plugin ) =~ s{::}{/}g;
    require "$file.pm";

    if ( $plugin->can('begin') ) {
        $plugin->begin( $class, $config );
    }

    return;
}

sub add_method {
    my $class  = shift;
    my $method = join '::', $class, shift;
    my $code   = shift;

    if ( ref $code eq 'CODE' ) {
        no strict 'refs';
        *$method = $code;
    }

    return;
}

1;

__END__

=head1 NAME

Blosxom::Plugin - Base class for Blosxom plugins

=head1 SYNOPSIS

  package foo;
  use strict;
  use warnings;
  use parent 'Blosxom::Plugin';

  __PACKAGE__->load_plugin( 'DataSection' );

  sub start { !$blosxom::static_entries }

  sub last {
      my $class = shift;
      $class->response->status( 304 );
      my $path_info = $class->request->path_info;
      my $month = $class->util->num2month( 7 ); # Jul
      my $template = $class->data_section->get( 'foo.html' );
      my $interpolated = $class->interpolate( $template );
      my $component = $class->get_template( 'component' );
  }

  1;

  __DATA__

  @@ foo.html

  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <title>Foo</title>
  </head>
  <body>
  <h1>hello, world</h1>
  </body>
  </html>


=head1 DESCRIPTION

Base class for Blosxom plugins.
Inspired by Blosxom 3 which was abandoned to be released.

=head2 METHODS

=over 4

=item $interpolated = $class->interpolte( $template )

A shorcut for

  $interpolated = $blosxom::interpolate->( $template );

=item $template = $class->get_template 

A shortcut for

  $template = $blosxom::template->(
      $blosxom::path_info,
      $class,
      $blosxom::flavour,
  );

=item $template = $class->get_template( $component )

A shortcut for

  $template = $blosxom::template->(
      $blosxom::path_info,
      $component,
      $blosxom::flavour,
  );

=item $template = $class->get_template(path=>$p, component=>$c, flavour=>$f)

A shortcut for

  $template = $blosxom::template->( $p, $c, $f )

=item response, res

Returns a L<Blosxom::Plugin::Response> object.

=item request, req

Returns a L<Blosxom::Plugin::Request> object.

=item util

Returns a L<Blosxom::Plugin::Util> object.

=item load_plugin( $plugin )

=item load_plugins( @plugins )

=item add_method( $method => $coderef )

=back

=head1 DEPENDENCIES

L<Blosxom 2.0.0|http://blosxom.sourceforge.net/> or higher.

=head1 SEE ALSO

L<Amon2>

=head1 ACKNOWLEDGEMENT

Blosxom was originally written by Rael Dohnfest.
L<The Blosxom Development Team|http://sourceforge.net/projects/blosxom/>
succeeded to the maintenance.

=head1 BUGS AND LIMITATIONS

This module is beta state. API may change without notice.

=head1 AUTHOR

Ryo Anazawa <anazawa@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ryo Anzawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
