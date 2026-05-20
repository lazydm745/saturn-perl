use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Anime::Saturn::Anime;

# Test object creation with required attributes
my $anime = Anime::Saturn::Anime->new(
    name => 'Test Anime',
    url  => 'http://example.com/video.mp4',
    an   => 'http://example.com/referer',
);
isa_ok($anime, 'Anime::Saturn::Anime', 'Anime object created');

# Test that attributes are set correctly
is($anime->name, 'Test Anime', 'Name attribute is correct');
