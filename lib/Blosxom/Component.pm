package Blosxom::Component;
use strict;
use warnings;

my %attribute_of;

sub mk_accessors {
    my $class = shift;
    while ( @_ ) {
        my $name = shift;
        my $default = ref $_[0] eq 'CODE' ? shift : undef;
        $attribute_of{ $class }{ $name } = $default;
    }
}

sub init {
    my $class  = shift;
    my $caller = shift;
    my $stash  = do { no strict 'refs'; \%{"$class\::"} };

    # NOTE: use keys() instead
    while ( my ($name, $glob) = each %{$stash} ) {
        if ( defined *{$glob}{CODE} and $name ne 'init' ) {
            $caller->add_method( $name => *{$glob}{CODE} );
        }
    }

    if ( my $attribute = $attribute_of{$class} ) {
        while ( my ($name, $default) = each %{$attribute} ) {
            my $accessor = $caller->make_accessor( $name, $default );
            $caller->add_method( $name => $accessor );
        }
    }

    return;
}

1;

__END__

=head1 NAME

Blosxom::Component - Base class for Blosxom components

=head1 SYNOPSIS

  package MyComponent;
  use parent 'Blosxom::Component';

=head1 DESCRIPTION

Base class for Blosxom components.

=head2 METHODS

=over 4

=item $class->mk_accessors

  __PACKAGE__->mk_accessors(qw/foo bar baz/);

=item $class->init

  sub init {
      my ( $class, $caller, $config ) = @_;
      # do something
      $class->SUPER::init( $caller );
  }

=back

=head1 SEE ALSO

L<Blosxom::Plugin>, L<Role::Tiny>

=head1 AUTHOR

Ryo Anazawa

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

