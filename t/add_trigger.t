use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
#use Test::More tests => 1;
use Test::More skip_all => 'obsolete';

my $plugin = 'add_trigger';
require "$FindBin::Bin/plugins/$plugin";

is $plugin->start( 'foo' ), 'Foo';
