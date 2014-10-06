package Thingiverse;
use Moo;
use Mojo::DOM;
use Mojo::UserAgent;

sub search{
    my $self = shift;
    my $keyword = shift;

    # Get the thing page
    my $ua = Mojo::UserAgent->new;
    my $page = $ua->get('http://www.thingiverse.com/search' => form => { sa => '', q => $keyword });
    my $dom = Mojo::DOM->new($page->res->body);

    # We will return this
    my @results;

    # Return if there is nothing here
    if( $page->res->body =~ m{THERE IS NOTHING AWESOME HERE} or $page->res->body =~ m{This thing is not yet public} ){ return { error => "site displayed error" } }

    # For each of the search results
    for my $result ( $dom->find("#search-results div.thing")->each ){
        my $thing = {};

        # Get the thing's ID
        $thing->{id} = $result->attr('data-id');

        # Get publication date
        $thing->{published} = $result->at(".thing-pub-time")->text;

        # Get the author
        $thing->{author} = $result->at(".creator-name a")->text;

        # Get the thing's name
        $thing->{name} = $result->at(".thing-name")->text;

        # Get the url for the thin's picture
        $thing->{thing_picture_url} = $result->at(".thing-img-wrapper img")->attr('src');

        # Get the url for the profile picture
        $thing->{profile_picture_url} = $result->at(".profile-img-wrapper img")->attr('src');
        
        push @results, $thing;
    }

    return [@results];

};

sub thing{
    my $self = shift;
    my $id_thing = shift;

    # Get the thing page
    my $ua = Mojo::UserAgent->new;
    my $page = $ua->get('http://www.thingiverse.com/thing:' . $id_thing);
    my $dom = Mojo::DOM->new($page->res->body);

    # We will return this
    my $thing = {};

    # Return if there is nothing here
    if( $page->res->body =~ m{THERE IS NOTHING AWESOME HERE} or $page->res->body =~ m{This thing is not yet public} ){ return { error => "site displayed error" } }

    # Get the object's name
    $thing->{title} = $dom->at('div.thing-header-data h1')->text;

    # Get the author's name
    $thing->{author} = $dom->at('div.thing-header-data h2 a')->text;

    # Get the publication time
    $thing->{time} = $dom->at('div.thing-header-data h2 time')->attr('datetime');

    # Get the description's HTML
    $thing->{description} = $dom->at('#description')->to_string;

    # Get the instruction's HTML
    my $instruction_div = $dom->at('#instructions');
    $thing->{instructions} = $instruction_div ? $instruction_div->to_string : '';

    # Get license
    $thing->{license} = $dom->find('div.license-text a')->[2]->text;
 
    return $thing;
}


1;
