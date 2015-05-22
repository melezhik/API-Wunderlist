# ABSTRACT: Perl 5 API wrapper for Wunderlist
package API::Wunderlist;

use API::Wunderlist::Class;

extends 'API::Wunderlist::Client';

use Carp ();
use Scalar::Util ();

# VERSION

has identifier => (
    is       => 'rw',
    isa      => STRING,
    default  => 'API::Wunderlist (Perl)',
);

has client_id => (
    is       => 'rw',
    isa      => STRING,
    required => 1,
);

has access_token => (
    is       => 'rw',
    isa      => STRING,
    required => 1,
);

has version => (
    is       => 'rw',
    isa      => INTEGER,
    default  => 1,
);

method AUTOLOAD () {
    my ($package, $method) = our $AUTOLOAD =~ /^(.+)::(.+)$/;
    Carp::croak "Undefined subroutine &${package}::$method called"
        unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

    # return new resource instance dynamically
    return $self->resource($method, @_);
}

method BUILD () {
    my $identifier   = $self->identifier;
    my $client_id    = $self->client_id;
    my $access_token = $self->access_token;
    my $version      = $self->version;
    my $agent        = $self->user_agent;
    my $url          = $self->url;

    $agent->transactor->name($identifier);

    $url->path("/api/v$version");

    return $self;
}

method PREPARE ($ua, $tx, %args) {
    my $headers = $tx->req->headers;
    my $url     = $tx->req->url;

    # default headers
    $headers->header('X-Client-ID' => $self->client_id);
    $headers->header('X-Access-Token' => $self->access_token);
    $headers->header('Content-Type' => 'application/json');
}

method action ($method, %args) {
    $method = uc($method || 'get');

    # execute transaction and return response
    return $self->$method(%args);
}

method create (%args) {
    # execute transaction and return response
    return $self->POST(%args);
}

method delete (%args) {
    # execute transaction and return response
    return $self->DELETE(%args);
}

method fetch (%args) {
    # execute transaction and return response
    return $self->GET(%args);
}

method resource (@segments) {
    # build new resource instance
    my $instance = __PACKAGE__->new(
        debug        => $self->debug,
        fatal        => $self->fatal,
        retries      => $self->retries,
        timeout      => $self->timeout,
        user_agent   => $self->user_agent,
        identifier   => $self->identifier,
        client_id    => $self->client_id,
        access_token => $self->access_token,
        version      => $self->version,
    );

    # resource locator
    my $url = $instance->url;

    # modify resource locator if possible
    $url->path(join '/', $self->url->path, @segments);

    # return resource instance
    return $instance;
}

method update (%args) {
    # execute transaction and return response
    return $self->PUT(%args);
}

1;

=encoding utf8

=head1 SYNOPSIS

    use API::Wunderlist;

    my $wunderlist = API::Wunderlist->new(
        client_id    => 'CLIENT_ID',
        access_token => 'ACCESS_TOKEN',
        identifier   => 'APPLICATION NAME',
    );

    $wunderlist->debug(1);
    $wunderlist->fatal(1);

    my $list = $wunderlist->lists('12345');
    my $results = $list->fetch;

    # after some introspection

    $list->update( ... );

=head1 DESCRIPTION

This distribution provides an object-oriented thin-client library for
interacting with the Wunderlist (L<https://wunderlist.com/>) API. For usage and
documentation information visit L<https://developer.wunderlist.com/documentation>.

=cut

=head1 THIN CLIENT

A thin-client library is advantageous as it has complete API coverage and
can easily adapt to changes in the API with minimal effort. As a thin-client
library, this module does not map specific HTTP requests to specific routines,
nor does it provide parameter validation, pagination, or other conventions
found in typical API client implementations, instead, it simply provides a
simple and consistent mechanism for dynamically generating HTTP requests.
Additionally, this module has support for debugging and retrying API calls as
well as throwing exceptions when 4xx and 5xx server response codes are
returned.

=cut

=head2 Building

    my $list = $wunderlist->lists('12345');

    $list->action; # GET /lists/12345
    $list->action('head'); # HEAD /lists/12345
    $list->action('patch'); # PATCH /lists/12345

Building up an HTTP request object is extremely easy, simply call method names
which correspond to the API's path segments in the resource you wish to execute
a request against. This module uses autoloading and returns a new instance with
each method call. The following is the equivalent:

=head2 Chaining

    my $list = $wunderlist->resource('lists', '12345');

    # or

    my $lists = $wunderlist->lists;
    my $list  = $lists->resource('12345');

    # then

    $list->action('put', %args); # PUT /lists/12345

Because each call returns a new API instance configured with a resource locator
based on the supplied parameters, reuse and request isolation are made simple,
i.e., you will only need to configure the client once in your application.

=head2 Fetching

    my $lists = $wunderlist->lists;

    # query-string parameters

    $lists->fetch( query => { ... } );

    # equivalent to

    my $lists = $wunderlist->resource('lists');

    $lists->action( get => ( query => { ... } ) );

This example illustrates how you might fetch an API resource.

=head2 Creating

    my $lists = $wunderlist->lists;

    # content-body parameters

    $lists->create( data => { ... } );

    # query-string parameters

    $lists->create( query => { ... } );

    # equivalent to

    $wunderlist->resource('lists')->action(
        post => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might create a new API resource.

=head2 Updating

    my $lists = $wunderlist->lists;
    my $list  = $lists->resource('12345');

    # content-body parameters

    $list->update( data => { ... } );

    # query-string parameters

    $list->update( query => { ... } );

    # or

    my $list = $wunderlist->lists('12345');

    $list->update(...);

    # equivalent to

    $wunderlist->resource('lists')->action(
        put => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might update a new API resource.

=head2 Deleting

    my $lists = $wunderlist->lists;
    my $list  = $lists->resource('12345');

    # content-body parameters

    $list->delete( data => { ... } );

    # query-string parameters

    $list->delete( query => { ... } );

    # or

    my $list = $wunderlist->lists('12345');

    $list->delete(...);

    # equivalent to

    $wunderlist->resource('lists')->action(
        delete => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might delete an API resource.

=cut

=head2 Transacting

    my $lists = $wunderlist->resource('lists', '12345');

    my ($results, $transaction) = $lists->action( ... );

    my $request  = $transaction->req;
    my $response = $transaction->res;

    my $headers;

    $headers = $request->headers;
    $headers = $response->headers;

    # etc

This example illustrates how you can access the transaction object used
represent and process the HTTP transaction.

=cut

=attr access_token

    $wunderlist->access_token;
    $wunderlist->access_token('ACCESS_TOKEN');

The access_token parameter should be set to an Access-Token associated with your Client-ID.

=cut

=attr client_id

    $wunderlist->client_id;
    $wunderlist->client_id('CLIENT_ID');

The client_id parameter should be set to the Client-ID of your application.

=cut

=attr identifier

    $wunderlist->identifier;
    $wunderlist->identifier('IDENTIFIER');

The identifier parameter should be set to a string that identifies your app.

=cut

=attr debug

    $wunderlist->debug;
    $wunderlist->debug(1);

The debug attribute if true prints HTTP requests and responses to standard out.

=cut

=attr fatal

    $wunderlist->fatal;
    $wunderlist->fatal(1);

The fatal attribute if true promotes 4xx and 5xx server response codes to
exceptions, a L<API::Wunderlist::Exception> object.

=cut

=attr retries

    $wunderlist->retries;
    $wunderlist->retries(10);

The retries attribute determines how many times an HTTP request should be
retried if a 4xx or 5xx response is received. This attribute defaults to 0.

=cut

=attr timeout

    $wunderlist->timeout;
    $wunderlist->timeout(5);

The timeout attribute determines how long an HTTP connection should be kept
alive. This attribute defaults to 10.

=cut

=attr url

    $wunderlist->url;
    $wunderlist->url(Mojo::URL->new('https://a.wunderlist.com'));

The url attribute set the base/pre-configured URL object that will be used in
all HTTP requests. This attribute expects a L<Mojo::URL> object.

=cut

=attr user_agent

    $wunderlist->user_agent;
    $wunderlist->user_agent(Mojo::UserAgent->new);

The user_agent attribute set the pre-configured UserAgent object that will be
used in all HTTP requests. This attribute expects a L<Mojo::UserAgent> object.

=cut

=method action

    my $result = $wunderlist->action($verb, %args);

    # e.g.

    $wunderlist->action('head', %args);    # HEAD request
    $wunderlist->action('options', %args); # OPTIONS request
    $wunderlist->action('patch', %args);   # PATCH request


The action method issues a request to the API resource represented by the
object. The first parameter will be used as the HTTP request method. The
arguments, expected to be a list of key/value pairs, will be included in the
request if the key is either C<data> or C<query>.

=cut

=method create

    my $results = $wunderlist->create(%args);

    # or

    $wunderlist->POST(%args);

The create method issues a C<POST> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method delete

    my $results = $wunderlist->delete(%args);

    # or

    $wunderlist->DELETE(%args);

The delete method issues a C<DELETE> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method fetch

    my $results = $wunderlist->fetch(%args);

    # or

    $wunderlist->GET(%args);

The fetch method issues a C<GET> request to the API resource represented by the
object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method update

    my $results = $wunderlist->update(%args);

    # or

    $wunderlist->PUT(%args);

The update method issues a C<PUT> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=resource avatars

    $wunderlist->avatars;

The avatars method returns a new instance representative of the API
I<Avatar> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/avatar>.

=cut

=resource file_previews

    $wunderlist->previews;

The file_previews method returns a new instance representative of the API
I<Preview> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/file_preview>.

=cut

=resource files

    $wunderlist->files;

The files method returns a new instance representative of the API
I<File> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/file>.

=cut

=resource folders

    $wunderlist->folders;

The folders method returns a new instance representative of the API
I<Folder> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/folder>.

=cut

=resource lists

    $wunderlist->lists;

The lists method returns a new instance representative of the API
I<List> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/list>.

=cut

=resource memberships

    $wunderlist->memberships;

The memberships method returns a new instance representative of the API
I<Membership> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/membership>.

=cut

=resource notes

    $wunderlist->notes;

The notes method returns a new instance representative of the API
I<Note> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/note>.

=cut

=resource positions

    $wunderlist->list_positions;

The positions method returns a new instance representative of the API
I<Positions> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/positions>.

=cut

=resource reminders

    $wunderlist->reminders;

The reminders method returns a new instance representative of the API
I<Reminder> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/reminder>.

=cut

=resource subtasks

    $wunderlist->subtasks;

The subtasks method returns a new instance representative of the API
I<Subtask> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/subtask>.

=cut

=resource task_comments

    $wunderlist->task_comments;

The task_comments method returns a new instance representative of the API
I<Task Comment> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/task_comment>.

=cut

=resource tasks

    $wunderlist->tasks;

The tasks method returns a new instance representative of the API
I<Task> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/task>.

=cut

=resource uploads

    $wunderlist->uploads;

The uploads method returns a new instance representative of the API
I<Upload> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/upload>.

=cut

=resource users

    $wunderlist->users;

The users method returns a new instance representative of the API
I<User> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/user>.

=cut

=resource webhooks

    $wunderlist->webhooks;

The webhooks method returns a new instance representative of the API
I<Webhooks> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://developer.wunderlist.com/documentation/endpoints/webhooks>.

=cut

