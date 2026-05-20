package Anime::Saturn::Scraper;

use strict;
use warnings;
use Moo;
use HTTP::Tiny;
use HTML::TreeBuilder;
use URI;
use URI::Escape;

our $BASE_URL = 'https://www.animesaturn.tv';

has http_client => (
    is      => 'lazy',
    builder => '_build_http_client',
);

sub _build_http_client {
    my ($self) = @_;
    return HTTP::Tiny->new(
        agent => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    );
}

sub search_anime {
    my ($self, $input) = @_;
    my $search_url = "$BASE_URL/animelist?search=" . uri_escape($input);
    
    my $response = $self->http_client->get($search_url);
    die "Failed to fetch $search_url: $response->{status}\n" unless $response->{success};
    
    my $tree = HTML::TreeBuilder->new_from_content($response->{content});
    my @available;
    
    for my $node ($tree->look_down('_tag', 'a', 'class', qr/\bbadge-archivio\b/)) {
        my $href = $node->attr('href');
        push @available, $href if defined $href;
    }
    
    $tree->delete;
    return \@available;
}

sub fetch_anime {
    my ($self, $input) = @_;
    my $search_url = "$BASE_URL/anime/$input";
    
    my $response = $self->http_client->get($search_url, {
        headers => { Referer => $search_url },
    });
    die "Failed to fetch $search_url: $response->{status}\n" unless $response->{success};
    
    my $tree = HTML::TreeBuilder->new_from_content($response->{content});
    my @episodes;
    
    for my $node ($tree->look_down('_tag', 'a', 'class', qr/\bbtn\s+btn-dark\s+mb-1\b/)) {
        my $href = $node->attr('href');
        push @episodes, $href if defined $href;
    }
    
    $tree->delete;
    return \@episodes;
}

sub plot_anime {
    my ($self, $input) = @_;
    my $plot_url = "$BASE_URL/anime/$input";
    
    my $response = $self->http_client->get($plot_url);
    die "Failed to fetch $plot_url: $response->{status}\n" unless $response->{success};
    
    my $tree = HTML::TreeBuilder->new_from_content($response->{content});
    my $the_plot = '';
    
    for my $node ($tree->look_down('_tag', qr/\bid\b/, 'id', 'trama')) {
        my $full_trama = $node->look_down('_tag', qr/\bid\b/, 'id', 'full-trama');
        if ($full_trama) {
            $the_plot = $full_trama->as_text;
            last;
        }
    }
    
    $tree->delete;
    return $the_plot;
}

sub fetch_episodes {
    my ($self, $episode_url, $anime_name) = @_;
    
    my $response = $self->http_client->get($episode_url);
    die "Failed to fetch $episode_url: $response->{status}\n" unless $response->{success};
    
    my $tree = HTML::TreeBuilder->new_from_content($response->{content});
    my ($ep_url, $name, $media_url);
    
    # Find the watch episode URL
    my $card_link = $tree->look_down('_tag', 'div', 'class', qr/\bcard-body\b/);
    if ($card_link) {
        my $link = $card_link->look_down('_tag', 'a');
        $ep_url = $link->attr('href') if $link;
    }
    
    return undef unless $ep_url;
    
    # Fetch the episode page to get the video URL
    $response = $self->http_client->get($ep_url, {
        headers => { Referer => $episode_url },
    });
    die "Failed to fetch $ep_url: $response->{status}\n" unless $response->{success};
    
    $tree->delete;
    $tree = HTML::TreeBuilder->new_from_content($response->{content});
    
    # Get episode name
    my $text_white = $tree->look_down('_tag', qr/\bclass\b/, 'class', qr/\btext-white\b/);
    $name = $text_white->as_text if $text_white;
    $name = "episode" unless defined $name && length $name;
    
    # Check for MP4 source
    my $source = $tree->look_down('_tag', 'source');
    if ($source) {
        $media_url = $source->attr('src');
        if ($media_url) {
            $tree->delete;
            return Anime::Saturn::Anime->new(
                name => $name,
                url  => $media_url,
                an   => "$BASE_URL/anime/$anime_name",
            );
        }
    }
    
    # Look for m3u8 in script tags
    my @scripts = $tree->look_down('_tag', 'script');
    for my $script (@scripts) {
        my $content = $script->as_text || '';
        if ($content =~ /(https:\/\/[^']+\.m3u8)/) {
            $media_url = $1;
            last;
        }
    }
    
    $tree->delete;
    
    if ($media_url) {
        return Anime::Saturn::Anime->new(
            name => $name,
            url  => $media_url,
            an   => "$BASE_URL/anime/$anime_name",
        );
    }
    
    return undef;
}

1;
