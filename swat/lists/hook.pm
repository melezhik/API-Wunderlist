use API::Wunderlist;
use swat::api::wunderlist;

my $wunderlist = API::Wunderlist->new(
    client_id    => client_id(),
    access_token => access_token(),
    identifier   => identifier(),
    url => 'https://a.wunderlist.com',
);

$wunderlist->debug(0);
$wunderlist->fatal(0);

my $list = $wunderlist->lists;

my $results = $list->fetch;
use Data::Dumper;


my $r;

for my $k (sort keys %{$results->[0]}){
    $r.=$k.' : '.($results->[0]->{$k})."\n"
}

set_response($r);
