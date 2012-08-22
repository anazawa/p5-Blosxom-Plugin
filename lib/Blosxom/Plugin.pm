package Blosxom::Plugin;
use 5.008_009;
use strict;
use warnings;
use Carp qw/carp croak/;

our $VERSION = '0.00009';

sub load_components {
    my $class  = shift;
    my $prefix = __PACKAGE__;

    while ( @_ ) {
        my $component = do {
            my $class = shift;

            # If a mofule name begins with a + character,
            # considers it a fully qualified class name.
            unless ( $class =~ s/^\+// or $class =~ /^$prefix/ ) {
                $class = "$prefix\::$class";
            }

            # load class
            ( my $file = $class ) =~ s{::}{/}g;
            require "$file.pm";

            $class;
        };
    
        my $config = ref $_[0] eq 'HASH' ? shift : undef;

        $component->begin( $class, $config );
    }

    return;
}

my %method_of;
our $AUTOLOAD;

sub AUTOLOAD {
    my $class = shift;
    my $method = $method_of{$AUTOLOAD};
    return $class->$method( @_ ) if $method;
    ( my $name = $AUTOLOAD ) =~ s/.*:://;
    croak qq{Can't locate object method "$name" via package "$class"};
}

sub add_method {
    my ( $class, $method, $code ) = @_;

    croak "Must provide a code reference" unless ref $code eq 'CODE';

    my $entry = "$class\::$method";
    return if defined &{$entry};

    if ( $method_of{$entry} && warnings::enabled('redefine') ) {
        carp "Subroutine $entry redefined";
    }

    $method_of{$entry} = $code;

    return;
}

sub has_method {
    my ( $class, $method ) = @_;
    my $slot = "$class\::$method";
    defined &{$slot} || exists $method_of{$slot};
}

sub can {
    my ( $class, $method ) = @_;
    $class->SUPER::can($method) || $method_of{"$class\::$method"};
}

sub dump {
    require Data::Dumper;
    local $Data::Dumper::Terse = 1;
    Data::Dumper::Dumper( \%method_of );
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

  __PACKAGE__->load_components( 'DataSection' );

  sub start {
      my $class = shift;
      my $template = $class->data_section->{'foo.html'};
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

  my_plugin->add_method( foo => \&_foo );

The above is equivalent to:

  no strict 'refs';
  *{ "my_plugin" . '::' . "foo" } = \&_foo;

To re-install a method, use C<no warnings 'redefine'> directive.

=item $class->has_method( $method )

Returns a boolean indicating whether or not the class defines
the named method. It does not include methods inherited from
parent classes.

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
