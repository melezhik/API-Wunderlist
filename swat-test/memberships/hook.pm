use API::Wunderlist;
use swat::api::wunderlist;
use Data::Dumper;

my $c = wunderlist_client()->memberships;
my $results = $c->fetch;

my $resp = (ref $results)."\n";

$resp.= Dumper($results);


set_response($resp);

