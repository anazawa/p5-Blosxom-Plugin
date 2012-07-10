package Blosxom::Plugin::Util;
use strict;
use warnings;

sub begin {
    my ( $class, $c, $config ) = @_;
    my $method = sub { __PACKAGE__->instance };
    $c->add_method( util => $method );
}

my $instance;

sub instance {
    my $class = shift;

    return $class if ref $class;
    return $instance if defined $instance;

    my %self = (
        month2num => \%blosxom::month2num,
        num2month => \@blosxom::num2month,
    );

    $instance = bless \%self, $class;
}

sub month2num { shift->{month2num}->{ $_[0] } }
sub num2month { shift->{num2month}->[ $_[0] ] }

1;
