use strict;
use warnings;
#use Test::More tests => 2;
use Test::More skip_all => 'deprecated';

package blosxom;

our $blog_title = "My Weblog";

our $interpolate = sub {
    package blosxom;
    my $template = shift;
    $template =~ s/(\$\w+(?:::)?\w*)/"defined $1 ? $1 : ''"/gee;
    $template;
};

our %template = (
    html => {
        render => 'This is $blog_title',
    },
);

our $template = sub {
    my ( $path, $component, $flavour ) = @_;
    $template{$flavour}{$component};
};

package render;
#use parent 'Blosxom::Plugin';
#__PACKAGE__->load_components('Core');
use parent 'Blosxom::Plugin::Core';

sub start { 1 }

package main;

my $plugin = 'render';
ok $plugin->start;
is $plugin->render( 'render.html' ), 'This is My Weblog';
