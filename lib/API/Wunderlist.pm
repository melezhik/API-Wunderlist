# ABSTRACT: Wunderlist.com API Client
package API::Wunderlist;

use namespace::autoclean -except => 'has';

use Data::Object::Class;
use Data::Object::Class::Syntax;
use Data::Object::Signatures;

use Data::Object qw(load);
use Data::Object::Library qw(Str);

extends 'API::Client';

# VERSION

our $DEFAULT_URL = "https://a.wunderlist.com";

# ATTRIBUTES

has client_id    => rw;
has access_token => rw;

# CONSTRAINTS

req client_id    => Str;
req access_token => Str;

# DEFAULTS

def identifier => 'API::Wunderlist (Perl)';
def url        => method { load('Mojo::URL')->new($DEFAULT_URL) };
def version    => 1;

# CONSTRUCTION

after BUILD => method {
    my $identifier   = $self->identifier;
    my $client_id    = $self->client_id;
    my $access_token = $self->access_token;
    my $version      = $self->version;
    my $agent        = $self->user_agent;
    my $url          = $self->url;

    $agent->transactor->name($identifier);

    $url->path("/api/v$version");

    return $self;
};

# METHODS

method PREPARE ($ua, $tx, %args) {
    my $headers = $tx->req->headers;
    my $url     = $tx->req->url;

    # default headers
    $headers->header('X-Client-ID' => $self->client_id);
    $headers->header('X-Access-Token' => $self->access_token);
    $headers->header('Content-Type' => 'application/json');
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
API::Wunderlist is derived from L<API::Client> and inherits all of it's
functionality. Please read the documentation for API::Client for more usage
information.

=cut

=attr access_token

    $wunderlist->access_token;
    $wunderlist->access_token('ACCESS_TOKEN');

The access_token attribute should be set to an Access-Token associated with
your Client-ID.

=cut

=attr client_id

    $wunderlist->client_id;
    $wunderlist->client_id('CLIENT_ID');

The client_id attribute should be set to the Client-ID of your application.

=cut

=attr identifier

    $wunderlist->identifier;
    $wunderlist->identifier('IDENTIFIER');

The identifier attribute should be set to a string that identifies your app.

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

