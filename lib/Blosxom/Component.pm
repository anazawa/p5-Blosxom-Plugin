package Blosxom::Component;
use strict;
use warnings;

sub init {
    my ( $class, $caller ) = @_;
    my $stash = do { no strict 'refs'; \%{"$class\::"} };
    while ( my ($method_name, $glob) = each %{$stash} ) {
        if ( defined *{$glob}{CODE} and $method_name !~ /^_/ ) {
            $caller->add_method( $method_name => *{$glob}{CODE} );
        }
    }
}

1;
