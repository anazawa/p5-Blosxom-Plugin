use strict;
use Blosxom::Plugin::Request;
use Test::More tests => 8;

my $plugin = 'Blosxom::Plugin::Request';
my $req = $plugin->instance;
isa_ok $req, $plugin;
can_ok $req, qw( method cookies );

is $req->method, q{};
local $ENV{REQUEST_METHOD} = 'GET';
is $req->method, 'GET';

local $ENV{HTTP_COOKIE} = 'foo=123; bar=qwerty; baz=wibble; qux=a1';
is $req->cookies->{bar}->value, 'qwerty';

local $ENV{QUERY_STRING} = 'game=chess&game=checkers&weather=dull';
is $req->param( 'game' ), 'chess';
my @got = sort $req->param( 'game' );
is_deeply \@got, [ 'checkers', 'chess' ];
@got = sort $req->param;
is_deeply \@got, [ 'game', 'weather' ];
