package Blosxom::Plugin;
use 5.008_009;
use strict;
use warnings;
use Carp qw/croak/;

our $VERSION = '0.00010';

sub load_components {
    my $class  = shift;
    my $prefix = __PACKAGE__;

    my %concrete_method_of;

    while ( @_ ) {
        my $component = do {
            my $class = shift;

            unless ( $class =~ s/^\+// or $class =~ /^$prefix/ ) {
                $class = "$prefix\::$class";
            }

            ( my $file = $class ) =~ s{::}{/}g;
            require "$file.pm";

            $class;
        };

        my $config = ref $_[0] eq 'HASH' ? shift : undef;

        next unless $component->can( 'init' );

        local *add_method = sub {
            my ( $class, $method, $code ) = @_;
            croak 'Not a CODE reference' unless ref $code eq 'CODE';
            $concrete_method_of{ $component }{ $method } = $code;
            return;
        };

        $component->init( $class, $config );
    }

    my ( %has_conflict, %code_of );
    while ( my ($component, $methods) = each %concrete_method_of ) {
        while ( my ($method, $code) = each %{$methods} ) {
            unless ( defined &{"$class\::$method"} ) {
                push @{ $has_conflict{$method} ||= [] }, $component;
                $code_of{ $method } = $code;
            }
        }
    }

    {
        no strict 'refs';
        while ( my ($method, $components) = each %has_conflict ) {
            delete $has_conflict{ $method } if @{ $components } == 1;
            *{ "$class\::$method" } = $code_of{ $method }; # add method
        }
    }

    if ( %has_conflict ) {
        croak join "\n", map {
            "Due to a method name conflict between components " .
            "'" . join( ' and ', sort @{ $has_conflict{$_} } ) . "', " .
            "the method '$_' must be implemented by '$class'";
        } keys %has_conflict;
    }

    return;
}

sub has_method {
    my ( $class, $method ) = @_;
    defined &{ "$class\::$method" };
}

1;

__END__

=head1 NAME

Blosxom::Plugin - Base class for Blosxom plugins

=head1 SYNOPSIS

  package my_plugin;
  use strict;
  use warnings;
  use parent 'Blosxom::Plugin';

  __PACKAGE__->load_components( 'DataSection' );

  sub start {
      my $class = shift;
      my $template = $class->data_section->{'my_plugin.html'};
  }

  1;

  __DATA__

  @@ my_plugin.html

  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <title>My Plugin</title>
  </head>
  <body>
  <h1>Hello, world</h1>
  </body>
  </html>

=head1 DESCRIPTION

Base class for Blosxom plugins.
Inspired by Blosxom 3 which was abandoned to be released.

=head2 BACKGROUND

Blosxom globalizes a lot of variables.
This module assigns them to appropriate namespaces
like 'Request', 'Response' or 'Config'.
In addition, it's intended that Blosxom::Plugin::* namespace will abstract
routines from Blosxom plugins.

=head2 METHODS

=over 4

=item $class->load_components( @comps )

Loads the given components into the current module.
If a module begins with a C<+> character,
it is taken to be a fully qualified class name,
otherwise C<Blosxom::Plugin> is prepended to it.

=item $class->add_method( $method => $coderef )

This method takes a method name and a subroutine reference,
and adds the method to the class.
Available while loading components.

=back

=head1 DEPENDENCIES

L<Blosxom 2.0.0|http://blosxom.sourceforge.net/> or higher.

=head1 SEE ALSO

L<Blosxom::Plugin::Core>,
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
