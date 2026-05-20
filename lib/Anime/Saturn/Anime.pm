package Anime::Saturn::Anime;

use strict;
use warnings;
use Moo;

has name => (is => 'rw', required => 1);
has url  => (is => 'rw', required => 1);
has an   => (is => 'rw', required => 1);  # Referrer URL for Cloudflare bypass

1;
