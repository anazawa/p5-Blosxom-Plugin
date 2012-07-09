use strict;
use Blosxom::Plugin::Response;
use Test::More tests => 4;

{
    package blosxom;
    our $header = {};
    our $output = 'foo';
}

my $res = Blosxom::Plugin::Response->instance;
can_ok $res, qw( body header status content_type cookies );
is $res->body, 'foo';

isa_ok $res->header, 'Blosxom::Header';
is $res->content_type, 'text/html';
