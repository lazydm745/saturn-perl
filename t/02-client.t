use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Anime::Saturn::Scraper;

# Test object creation
my $scraper = Anime::Saturn::Scraper->new();
isa_ok($scraper, 'Anime::Saturn::Scraper', 'Scraper object created');

# Test that http_client is available
isa_ok($scraper->http_client, 'HTTP::Tiny', 'HTTP client is HTTP::Tiny instance');
