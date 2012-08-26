use strict;
use warnings;
use FindBin;
use Test::More tests => 4;

{
    package blosxom;
    our %template;
}

my $plugin = 'data_section';

require_ok "$FindBin::Bin/plugins/$plugin";
ok $plugin->start;

my $expected = "hello, world\n";
is $plugin->data_section->get( 'data_section.html' ), $expected;

$plugin->data_section->merge;
is $blosxom::template{html}{data_section}, $expected;

