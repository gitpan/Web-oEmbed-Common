#!perl 

use strict;
use Test::More tests => 5;

BEGIN { use_ok 'Web::oEmbed::Common' || print "Bail out!" }

use Web::oEmbed::Common;

my $oembedder = Web::oEmbed::Common->new();

isa_ok( $oembedder, 'Web::oEmbed::Common' );

my $result = $oembedder->embed('http://xkcd.com/730/');

isa_ok( $result, 'Web::oEmbed::Response' );

is( $result->type, "photo", "Got a photo from XKCD" );

like( $result->url, qr/circuit_diagram/, "Found expected filename" );

1;
