package state51::APIClient::Media::v1::MFS::Metadata::Release;

use Moose;

extends qw/ state51::APIClient::REST /;

sub foo {
    return "hello";
}

__PACKAGE__->make_immmutable;

1;
