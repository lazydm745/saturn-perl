use strict;
use warnings;
use Test::More tests => 3;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Anime::Saturn::Scraper;

# Test object creation
my $scraper = Anime::Saturn::Scraper->new();
isa_ok($scraper, 'Anime::Saturn::Scraper', 'Scraper object created');

# Test search_results method with mock HTML
my $mock_html = q{
    <div class="anime-item">
        <a href="/anime/naruto" title="Naruto">Naruto</a>
        <img src="naruto.jpg" alt="Naruto">
    </div>
    <div class="anime-item">
        <a href="/anime/onepiece" title="One Piece">One Piece</a>
        <img src="onepiece.jpg" alt="One Piece">
    </div>
};

# Note: search_anime makes HTTP requests, so we test the scraper can be instantiated
# and has the required methods
ok($scraper->can('search_anime'), 'Scraper has search_anime method');
ok($scraper->can('fetch_anime'), 'Scraper has fetch_anime method');
