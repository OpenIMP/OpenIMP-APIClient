package state51::APIClient::REST;

use Moose;

has __REPRESENTATION__ => (
    is => 'ro',
    isa => 'Str',
    documentation => 'The URI of the object represented.',
);

__PACKAGE__->meta->make_immutable;
1;
