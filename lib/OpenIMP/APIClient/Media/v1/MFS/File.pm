package OpenIMP::APIClient::Media::v1::MFS::File;

use Moose;
use MooseX::Types::Moose qw/ Str /;
use File::Temp qw/ tempfile /;

extends qw/ OpenIMP::APIClient::REST /;

has local_file_path => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_local_file_path',
    predicate => 'has_local_file_path',
);

sub _build_local_file_path {
    my ($self) = @_;

    (undef, my $fn) = tempfile("mediaapi_client-XXXXXXXX", TMPDIR => 1);
    $self->_client->GET_file([$self->__REPRESENTATION__, 'retrieve'], $self->FileSize, $self->SHA1DigestBase64, $fn);
    return $fn;
}


sub DEMOLISH {
    my ($self) = @_;
    if ($self->has_local_file_path) {
        unlink $self->local_file_path or warn $!;
    }
    return;
}

# Invoked by OpenIMP::APIClient::Loader when exploding all the attributes from yaml.
# __PACKAGE__->meta->make_immutable;

1;
