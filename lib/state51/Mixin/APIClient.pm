package state51::Mixin::APIClient;
use Moose::Role;
use MooseX::Types::Moose qw/Str Int/;
use MooseX::Types::URI qw/Uri/;
use Method::Signatures::Simple;
use LWP::UserAgent;
use JSON qw/from_json/;
use HTTP::Request::Common ();
use Data::Dumper;
use MooseX::Getopt ();
use Try::Tiny;
use namespace::autoclean;

MooseX::Getopt::OptionTypeMap->add_option_type_to_map( $_, '=s' )
    foreach (
        Uri,
        'Path::Class::Dir',
        'Path::Class::File',
    );

has uri => ( isa => Uri, required => 1, coerce => 1, is => 'ro' );
has user => ( isa => Str, required => 1, is => 'ro', documentation => 'Your api username', );
has password => ( isa => Str, required => 1, is => 'ro', documentation => 'Your api password', );

has _ua => ( isa => 'LWP::UserAgent', is => 'ro', lazy_build => 1, traits => [qw/NoGetopt/] );

method _build__ua () {
    my $ua = LWP::UserAgent->new;
    $ua->agent("API Client platform Mixin for $0");
    $ua->timeout(120);
    my $res = $ua->get($self->uri);
    Carp::confess("Did not get an authorization_required (401) response from "
        . $self->uri . " - instead got " . $res->code)
        unless $res->code == 401;
    my ($realm) = $res->header('WWW-Authenticate') =~ /realm="([^"]+)"/;
    $ua->credentials($self->uri->host_port, $realm, $self->user, $self->password);
    $res = $ua->get($self->uri);
    die("Did not get an OK response with auth, bad credentials? " . Dumper($res))
        unless $res->code == 200;
    return $ua;
}

method GET ($path) {
    return $self->GET($self->_uri_with_path(@$path));
}

method GET_uri ($uri) {
    my $req = HTTP::Request::Common::GET( $uri );
    $req->header('Accept' => 'application/json');
    $req->header('Content-Type' => 'application/x-www-form-urlencoded');
    $self->_parse_response($self->_ua->request( $req ) )
}

method POST ($path, @p) {
    my $req = HTTP::Request::Common::POST( $self->_uri_with_path(@$path), \@p );
    $req->header('Accept' => 'application/json');
    $req->header('Content-Type' => 'application/x-www-form-urlencoded');
    $self->_parse_response($self->_ua->request( $req ) )
}

method PUT ($path, @p) {
    my $req = HTTP::Request::Common::PUT( $self->_uri_with_path(@$path), @p );
    $req->header('Accept' => 'application/json');
    $self->_parse_response($self->_ua->request( $req ) )
}

has _depth => ( isa => Int, is => 'rw', default => 0, required => 1 );

method _parse_response ($res) {
    if ($res->code =~ /^30\d$/) {
        $self->_depth($self->_depth + 1);
        die("Appears to be recursing through redirects " . Dumper($res)) if $self->_depth > 2;
        my $location = $res->header('Location');
        die("Response was 30X without Location header: " . Dumper($res)) unless $location;
                      # FIXME
        return $self->GET([$location]);
    }
    $self->_depth(0);
    die("Response not an expected status " . Dumper($res)) unless $res->code =~ /^[42]0\d$/;
    my $data;
    try { $data = from_json($res->content) }
    catch { die Dumper $res };
    return $data;
}

method _uri_with_path (@path) {
    return $path[0] if $path[0] =~ /^http/;
    my @current = $self->uri->path_segments;
    my $uri = $self->uri->clone;
    $uri->path_segments(grep { defined $_ && length $_ } map { $_ . '' } @current, @path);
    return $uri;
}

1;

