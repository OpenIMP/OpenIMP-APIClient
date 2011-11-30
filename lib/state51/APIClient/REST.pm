package state51::APIClient::REST;

use Moose;
use MooseX::Types::Moose qw/ Bool /;

has __REPRESENTATION__ => (
    is => 'ro',
    isa => 'Str',
    documentation => 'The URI of the object represented.',
);

has _client => (
    is => 'ro',
    does => 'state51::Mixin::APIClient',
);

has _loader => (
    is => 'ro',
    isa => 'state51::APIClient::Loader',
);

has __LOADED__ => (
    is => 'rw',
    isa => Bool,
    default => 0,
);

sub _load {
    my ($self) = @_;
    return if $self->__LOADED__();
    my $hash = $self->_client->GET_uri($self->__REPRESENTATION__);
    $self->_loader->load_class($hash, $self, $self->_api_client);
    return;
}

__PACKAGE__->meta->make_immutable;
1;
