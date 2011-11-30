package state51::APIClient::REST;

use Moose;
use MooseX::Types::Moose qw/ Bool /;

has __REPRESENTATION__ => (
    is => 'ro',
    isa => 'Str',
    documentation => 'The relative URI of the object represented.',
    writer => '_set___REPRESENTATION__',
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
    documentation => "Becomes true when this object has been loaded on the fly after a unset attribute was read."
);

sub _load {
    my ($self) = @_;
    return if $self->__LOADED__();
    warn "inflating from ".$self->__REPRESENTATION__;
    my $hash = $self->_client->GET([$self->__REPRESENTATION__]);
    $self->_loader->load_class($hash, $self, $self->_client);
    $self->__LOADED__(1);
    return;
}

__PACKAGE__->meta->make_immutable;
1;
