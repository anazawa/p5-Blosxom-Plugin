package Blosxom::Plugin::AddTrigger;
use strict;
use warnings;

sub begin {
    my ( $class, $c, $config ) = @_;

    $c->add_trigger(
        'around', 'start' => sub {
            my $orig = shift;
            ucfirst $orig->( @_ );
        },
    );

    return;
}

1;
