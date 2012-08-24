package Blosxom::Plugin;
use 5.008_009;
use strict;
use warnings;
use Carp qw/croak/;
use Scalar::Util qw/blessed/;

our $VERSION = '0.00009';

my %instance_of;

sub instance {
    my $class = blessed $_[0] || $_[0];
    $instance_of{ $class } ||= bless {}, $class;
}

sub has_instance { $instance_of{ blessed $_[0] || $_[0] } }

sub load_components {
    my $self   = shift->instance;
    my $prefix = __PACKAGE__;

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

        $component->init( $self, $config );
    }

    return;
}

sub add_method {
    my ( $self, $method, $code ) = @_;
    croak qq{Method name conflict for "$method"} if exists $self->{$method};
    croak 'Must provide a CODE reference' unless ref $code eq 'CODE';
    $self->{ $method } = $code;
    return;
}

sub can {
    my ( $invocant, $method ) = @_;
    $invocant->SUPER::can( $method ) || $invocant->instance->{ $method };
}

sub AUTOLOAD {
    my $invocant = shift;
    ( my $slot = our $AUTOLOAD ) =~ s/.*:://;
    my $method = $invocant->instance->{ $slot };
    return $invocant->$method( @_ ) if ref $method eq 'CODE';
    my $class = blessed $invocant || $invocant;
    croak qq{Can't locate object method "$slot" via package "$class"};
}

sub DESTROY {
    my $self = shift;
    delete $instance_of{ blessed $self };
    return;
}

sub dump {
    require Data::Dumper;
    my $self = shift;
    local $Data::Dumper::Terse = 1;
    Data::Dumper::Dumper( $self );
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

  package my_plugin;
  use parent 'Blosxom::Plugin';
  __PACKAGE__->add_method( foo => sub { 'my_plugin foo' } );
  warn __PACKAGE__->foo; # my_plugin foo

If a method is already defined on a class, that method will not be
added.
If any of added methods clash, an exception is raised unless the class
provides a method.

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
