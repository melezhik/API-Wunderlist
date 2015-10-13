package swat::api::wunderlist;
1;

package main;

sub client_id { $ENV{client_id}}
sub access_token { $ENV{access_token}}
sub identifier { $ENV{identifier}}

my $wunderlist = API::Wunderlist->new(
    client_id    => client_id(),
    access_token => access_token(),
    identifier   => identifier(),
    url => 'https://a.wunderlist.com',
);

$wunderlist->debug(0);
$wunderlist->fatal(0);

$wunderlist->user_agent->proxy->http($ENV{http_proxy}) if $ENV{http_proxy};
$wunderlist->user_agent->proxy->https($ENV{https_proxy}) if $ENV{https_proxy};


sub wunderlist_client { $wunderlist }

1;

