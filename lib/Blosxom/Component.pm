package Blosxom::Component;
use strict;
use warnings;

my %attribute_of;

sub mk_accessors {
    my $class = shift;
    while ( @_ ) {
        my $field = shift;
        my $default = ref $_[0] eq 'CODE' ? shift : undef;
        $attribute_of{ $class }{ $field } = $default;
    }
}

sub init {
    my ( $class, $caller ) = @_;

    my $namespace = do { no strict 'refs'; \%{"$class\::"} };
    while ( my ($method, $glob) = each %{$namespace} ) {
        if ( defined *{$glob}{CODE} and $method ne 'init' ) {
            $caller->add_method( $method => *{$glob}{CODE} );
        }
    }

    if ( my $attributes = $attribute_of{$class} ) {
        while ( my ($field, $default) = each %{$attributes} ) {
            $caller->add_attribute( $field => $default );
        }
    }

    return;
}

1;
