use strict;
use warnings;
#use Test::More tests => 4;
use Test::More skip_all => 'deprecated';

package my_plugin;
use parent 'Blosxom::Plugin';

sub foo { 'my_plugin foo' }

package main;

my $plugin = 'my_plugin';
ok $plugin->has_method( 'foo' );
ok !$plugin->has_method( 'bar' );

ok exists $my_plugin::{foo};
ok !exists $my_plugin::{bar};
