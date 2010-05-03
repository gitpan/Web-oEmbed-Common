#!perl 

use strict;
use Test::More tests => 3;

BEGIN { use_ok 'Web::oEmbed::Common' || print "Bail out!" }

use Web::oEmbed::Common;

my $oembedder = Web::oEmbed::Common->new();

isa_ok( $oembedder, 'Web::oEmbed::Common' );

my $result = $oembedder->embed('http://www.youtube.com/watch?v=Lx7khdLV-fU');

like( $result->html, qr/<object .*? movie /sx, "Got a YouTube embed code" );

1;
