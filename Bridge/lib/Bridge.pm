package Bridge;
use Dancer ':syntax';
use JSON::DWIW;
use Thingiverse;

our $VERSION = '0.1';

my $server = Thingiverse->new();

hook 'before' => sub{
    header('Access-Control-Allow-Origin' => '*'); 
};

any '/' => sub {
    template 'index';
};

any '/search/:keyword' => sub {
    return JSON::DWIW->to_json($server->search(param("keyword")));
};

any '/thing/:id_thing' => sub {
    return JSON::DWIW->to_json($server->thing(param("id_thing")));
};

true;
