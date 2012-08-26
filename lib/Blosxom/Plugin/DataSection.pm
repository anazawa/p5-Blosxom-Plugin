package Blosxom::Plugin::DataSection;
use strict;
use warnings;
use parent 'Data::Section::Simple';

sub init {
    my ( $class, $c ) = @_;
    $c->add_method( data_section => \&_data_section );
}

my %instance_of;

sub _data_section {
    my $class = shift;
    $instance_of{ $class } ||= __PACKAGE__->new( $class );
}

sub new {
    my $self = shift->SUPER::new( @_ );
    $self->{template} = $self->SUPER::get_data_section || +{};
    $self;
}

sub get_data_section {
    my ( $self, $name ) = @_;
    $name ? $self->{template}->{$name} : $self->{template};
}

sub get { shift->get_data_section(@_) }

sub merge {
    my ( $self, @basenames ) = @_;
    for my $basename ( @basenames || keys %{ $self->{template} } ) {
        if ( my ($component, $flavour) = $basename =~ /(.*)\.([^.]*)/ ) {
            my $template = $self->{template}->{$basename};
            $blosxom::template{ $flavour }{ $component } = $template;
        }
    }
}

1;

__END__

=head1 NAME

Blosxom::Plugin::DataSection - Read data from __DATA__

=head1 SYNOPSIS

  my $template = $class->data_section->{'foo.html'};

=head1 DESCRIPTION

This module extracts data from C<__DATA__> section of the plugin
and merges them into Blosxom default templates.

=head1 SEE ALSO

L<Blosxom::Plugin>

=head1 AUTHOR

Ryo Anazawa <anazawa@cpan.org>

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
