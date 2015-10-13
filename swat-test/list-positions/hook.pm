use API::Wunderlist;
use swat::api::wunderlist;
use Data::Dumper;

my $c = wunderlist_client()->list_positions;
my $results = $c->fetch;

my $resp = (ref $results)."\n";

$resp.= Dumper($results);


set_response($resp);

