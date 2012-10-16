package Blosxom::Plugin::Config;
use strict;
use warnings;

my %type_of = (
    blog_title          => 'SCALAR',
    blog_description    => 'SCALAR',
    blog_language       => 'SCALAR',
    blog_encoding       => 'SCALAR',
    datadir             => 'SCALAR',
    url                 => 'SCALAR',
    depth               => 'SCALAR',
    num_entries         => 'SCALAR',
    file_extension      => 'SCALAR',
    default_flavour     => 'SCALAR',
    show_future_entries => 'SCALAR',
    plugin_dir          => 'SCALAR',
    plugin_state_dir    => 'SCALAR',
    static_dir          => 'SCALAR',
    static_password     => 'SCALAR',
    static_flavours     => 'ARRAY',
    static_entries      => 'SCALAR',
);

sub init {
    my ( $class, $context ) = @_;
    $context->add_method( config => \&_config );
}

sub _conifig {}

1;
