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

$res->redirect( 'http://blosxom.com' );
is $res->header->get( 'Location' ), 'http://blosxom.com';
is $res->header->status, 301;

is $res->location, 'http://blosxom.com';
$res->location( 'http://cpan.org' );
is $res->location, 'http://cpan.org';

$res->content_length( 123 );
is $res->content_length, 123;

$res->content_encoding( 'gzip' );
is $res->content_encoding, 'gzip';
