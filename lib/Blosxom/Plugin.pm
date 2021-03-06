package Blosxom::Plugin;
use 5.008_009;
use strict;
use warnings;
use Carp qw/croak/;

our $VERSION = '0.02003';

sub import {
    my $class     = shift;
    my $component = scalar caller;
    my $stash     = do { no strict 'refs'; \%{"$component\::"} };

    my ( %is_excluded, @requires );

    my %export = (
        init => sub {
            my ( $comp, $plugin ) = @_;

            if ( my @methods = grep { !$plugin->can($_) } @requires ) {
                my $methods = join ', ', @methods;
                croak "Can't apply '$comp' to '$plugin' - missing $methods";
            }

            while ( my ($name, $glob) = each %{$stash} ) {
                if ( defined *{$glob}{CODE} and !$is_excluded{$name} ) {
                    $plugin->add_method( $name => *{$glob}{CODE} );
                }
            }

            return;
        },
        requires => sub { shift; push @requires, @_ },
    );

    { # export mixin methods
        no strict 'refs';
        while ( my ($method, $code) = each %export ) {
            *{ "$component\::$method" } = $code;
        }
    }

    %is_excluded = do {
        map { $_ => 1 } grep { defined *{$stash->{$_}} } keys %{$stash};
    };

    return;
}

my %attribute_of;

sub mk_accessors {
    my $package = shift;
    no strict 'refs';
    while ( my ($field, $default) = splice @_, 0, 2 ) {
        *{"$package\::$field"} = $package->make_accessor($field, $default);
    }
}

sub make_accessor {
    my $package   = shift;
    my $name      = shift;
    my $default   = shift;
    my $attribute = $attribute_of{$package} ||= {};

    if ( ref $default eq 'CODE' ) {
        return sub {
            return $attribute->{$name} = $_[1] if @_ == 2;
            return $attribute->{$name} if exists $attribute->{$name};
            return $attribute->{$name} = $package->$default;
        };
    }
    elsif ( defined $default ) {
        return sub {
            return $attribute->{$name} = $_[1] if @_ == 2;
            return $attribute->{$name} if exists $attribute->{$name};
            return $attribute->{$name} = $default;
        };
    }
    else {
        return sub {
            @_ > 1 ? $attribute->{$name} = $_[1] : $attribute->{$name};
        };
    }

    return;
}

sub end { %{ $attribute_of{$_[0]} } = () if exists $attribute_of{$_[0]} }

sub dump {
    my $package = shift;
    require Data::Dumper;
    local $Data::Dumper::Maxdepth = shift || 1;
    Data::Dumper::Dumper( $attribute_of{$package} );
}

sub component_base_class { __PACKAGE__ }

sub load_components {
    my $package = shift;
    my @args    = @_;
    my $prefix  = $package->component_base_class;

    my ( $component, %is_loaded, %has_conflict, %code_of );

    local *add_component 
        = sub { push @args, ref $_[2] eq 'HASH' ? @_[1, 2] : $_[1] };

    local *add_method = sub {
        my ( $pkg, $method, $code ) = @_;
        unless ( defined &{"$package\::$method"} ) {
            push @{ $has_conflict{$method} ||= [] }, $component;
            $code_of{ $method } = $code;
        }
    };

    while ( @args ) {
        $component = do {
            my $class = shift @args;

            unless ( $class =~ s/^\+// or $class =~ /^$prefix/ ) {
                $class = "$prefix\::$class";
            }

            ( my $file = $class ) =~ s{::}{/}g;
            require "$file.pm";

            $class;
        };

        my $config = ref $args[0] eq 'HASH' ? shift @args : undef;

        $component->init( $package, $config ) if !$is_loaded{$component}++;
    }

    if ( %code_of ) {
        no strict 'refs';
        while ( my ( $method, $components ) = each %has_conflict ) {
            delete $has_conflict{ $method } if @{ $components } == 1;
            *{ "$package\::$method" } = delete $code_of{ $method };
        }
    }

    if ( %has_conflict ) {
        croak join "\n", map {
            "Due to a method name conflict between components " .
            "'" . join( ' and ', sort @{ $has_conflict{$_} } ) . "', " .
            "the method '$_' must be implemented by '$package'";
        } keys %has_conflict;
    }

    return;
}

sub add_attribute {
    my ( $package, $attribute, $builder ) = @_;
    my $accessor = $package->make_accessor( $attribute, $builder );
    $package->add_method( $attribute => $accessor );
}

sub has_method { defined &{"$_[0]::$_[1]"} }

1;

__END__

=head1 NAME

Blosxom::Plugin - Base class for Blosxom plugins

=head1 SYNOPSIS

  package my_plugin;
  use strict;
  use warnings;
  use parent 'Blosxom::Plugin';

  # generates a class attribute called foo()
  __PACKAGE__->mk_accessors( 'foo' );

  # does Blosxom::Component::DataSection
  __PACKAGE__->load_components( 'DataSection' );

  sub start {
      my $class = shift;

      $class->foo( 'bar' );
      my $value = $class->foo; # => "bar"

      my $template = $class->get_data_section( 'my_plugin.html' );
      # <!DOCTYPE html>
      # ...

      # merge __DATA__ into Blosxom default templates
      $class->merge_data_section_into( \%blosxom::template );

      return 1;
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

This module enables Blosxom plugins to create class attributes
and load additional components.

Blosxom never creates instances of plugins,
and so they can't have instance attributes.
This module creates class attributes instead,
and always undefines them after all output has been processed.

Components will abstract routines from Blosxom plugins.
It's intended that they will be shared on CPAN.

=head2 METHODS

=over 4

=item $class->mk_accessors( @fields )

=item $class->mk_accessors( $field => \&default, ... )

This creates class attributes for each named field given
in C<@fields>. Attributes can have default values which is not generated
until the field is read. C<&default> is called as a method on the class
with no additional parameters.

  package my_plugin;
  use parent 'Blosxom::Plugin';
  use Path::Class::File;

  __PACKAGE__->mk_accessors(
      'path' => undef,
      'file' => sub {
          my $class = shift; # => "my_plugin"
          Path::Class::File->new( $class->path );
      },
  );

  sub start {
      my $class = shift;

      $class->path( '/path/to/entry.txt' );
      my $path = $class->path; # => "/path/to/entry.txt"

      # file() is a Path::Class::File object
      my $basename = $class->file->basename; # => "entry.txt"

      return 1;
  }

=item $class->load_components( @components )

=item $class->load_components( $component => \%configuration, ... )

Loads the given components into the current module.
Components can be configured by the loaders.
If a module begins with a C<+> character,
it is taken to be a fully qualified class name,
otherwise C<Blosxom::Component> is prepended to it.

  __PACKAGE__->load_components( '+MyComponent' => \%config );

This method calls C<init()> method of each component.
C<init()> is called as follows:

  MyComponent->init( 'my_plugin', \%config )

If multiple components are loaded in a single call, then if any of their
provided methods clash, an exception is raised unless the class provides
the method.

=item $class->add_method( $method_name => $coderef )

This method takes a method name and a subroutine reference,
and adds the method to the class.
Available while loading components.
If a method is already defined on the class, that method will not be added.

  package MyComponent;

  sub init {
      my ( $class, $caller, $config ) = @_;
      $caller->add_method( 'foo' => sub { ... } );
  }

=item $class->add_attribute( $attribute_name )

=item $class->add_attribute( $attribute_name, \&default )

This method takes an attribute name, and adds the attribute to the class.
Available while loading components.
Attributes can have default values which is not generated
until the attribute is read.
C<&default> is called as a method on the class with no additional arguments.

  sub init {
      my ( $class, $caller ) = @_;
      $caller->add_attribute( 'foo' );
      $caller->add_attribute( 'bar' => sub { ... } );
  }

=item $bool = $class->has_method( $method_name )

Returns a Boolean value telling whether or not the class defines the named
method. It does not include methods inherited from parent classes.

  my $requires = 'bar';

  sub init {
      my ( $class, $context ) = @_;
      unless ( $context->has_method($requires) ) {
          die "Cannot apply '$class' to '$context'";
      }
  }

=item $class->end

Undefines class attributes generated by C<mk_accessors()>
or C<add_attribute()>.
Since C<end()> is one of recognized hooks,
it's guaranteed that Blosxom always invokes this method.

  sub end {
      my $class = shift;
      # do something
      $class->SUPER::end;
  }

=item $class->dump( $max_depth )

This method uses L<Data::Dumper> to dump the class attributes.
You can pass an optional maximum depth, which will set
C<$Data::Dumper::Maxdepth>. The default maximum depth is 1.

=back

=head1 DEPENDENCIES

L<Blosxom 2.0.0|http://blosxom.sourceforge.net/> or higher.

=head1 SEE ALSO

L<Blosxom::Plugin::Web>,
L<Amon2>,
L<Moose::Manual::Roles>,
L<MooseX::Role::Parameterized::Tutorial>

=head1 ACKNOWLEDGEMENT

Blosxom was originally written by Rael Dohnfest.
L<The Blosxom Development Team|http://sourceforge.net/projects/blosxom/>
succeeded to the maintenance.

=head1 BUGS AND LIMITATIONS

There are no known bug in this module. Please report problems to
ANAZAWA (anazawa@cpan.org). Patches are welcome.

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
