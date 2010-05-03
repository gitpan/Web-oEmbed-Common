#!perl 

use strict;
use Test::More tests => 6;

BEGIN { use_ok 'Web::oEmbed::Common' || print "Bail out!" }

use Web::oEmbed::Common;

my $oembedder = Web::oEmbed::Common->new();

isa_ok( $oembedder, 'Web::oEmbed::Common' );

my $result = $oembedder->embed('http://www.youtube.com/watch?v=Lx7khdLV-fU');

isa_ok( $result, 'Web::oEmbed::Response' );

is( $result->type, "video", "Got a video from YouTube" );

like( $result->thumbnail_url, qr/^http(.*)jpg/sx, "Got a YouTube thumbnail" );

like( $result->html, qr/<object .*? movie /sx, "Got a YouTube embed code" );

1;
