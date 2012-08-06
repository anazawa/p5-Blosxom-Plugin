package Blosxom::Plugin::Util;
use strict;
use warnings;

sub begin {
    my ( $class, $c ) = @_;
    $c->add_method( util => \&instance );
}

my $instance;

sub instance {
    return $instance ||= bless {
        month2num   => \%blosxom::month2num,
        num2month   => \@blosxom::num2month,
    };
}

sub has_instance { $instance }

sub month2num { shift->{month2num}->{ $_[0] } }
sub num2month { shift->{num2month}->[ $_[0] ] }

sub encode_html {
    my ( $self, $str ) = @_;

    unless ( exists $self->{encode_html} ) {
        if ( blosxom->can( 'blosxom_html_escape' ) ) {
            $self->{encode_html} = \&blosxom::blosxom_html_escape;
        }
        else { # for Blosxom 2.0
            $self->{encode_html} = sub {
                my $str = shift;
                $str =~ s/&/&amp;/g;
                $str =~ s/>/&gt;/g;
                $str =~ s/</&lt;/g;
                $str =~ s/"/&quot;/g;
                $str =~ s/'/&apos;/g;
                $str;
            };
        }
    }

    $self->{encode_html}->( $str );
}

1;

__END__

=head1 NAME

Blosxom::Plugin::Util - Utility class for Blosxom plugins

=head1 SYNOPSIS

  use Blosxom::Plugin::Util;

  my $util = Blosxom::Plugin::Util->instance;

  my $num = $util->month2num( 'Jul' ); # '07'
  my $month = $util->num2month( 7 ); # 'Jul'

=head1 DESCRIPTION

Utility class for Blosxom plugins.

=head2 METHODS

=over 4

=item Blosxom::Plugin::Util->begin

Exports C<instance()> into context class as C<util()>.

=item $util = Blosxom::Plugin::Util->instance

Returns a current Blosxom::Plugin::Util object instance or create a new one.

=item $util = Blosxom::Plugin::Util->has_instance

Returns a reference to any existing instance or C<undef> if none is defined.

=item $util->num2month

=item $util->month2num

=item $util->encode_html

=back

=head1 SEE ALSO

L<Blosxom::Plugin>, L<Class::Singleton>

=head1 AUTHOR

Ryo Anazawa

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut

