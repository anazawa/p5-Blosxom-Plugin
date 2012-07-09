package Blosxom::Plugin::Request;
use strict;
use warnings;
use base qw/Exporter/;

our @EXPORT = qw( request req );

sub request { __PACKAGE__ }
*req = \&request;

sub method { $ENV{REQUEST_METHOD} || q{} }

1;
