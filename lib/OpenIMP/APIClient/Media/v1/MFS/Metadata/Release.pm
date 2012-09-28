package OpenIMP::APIClient::Media::v1::MFS::Metadata::Release;

use Moose;

extends qw/ OpenIMP::APIClient::REST /;

sub find_track {
    my ($self, $track, $vol) = @_;

    foreach my $t (@{ $self->tracks }) {
        return $t if ($t->TrackNumber == $track && $t->VolumeNumber == $vol);
    }

    die "Could not find volume $vol track $track";
}

# Invoked by OpenIMP::APIClient::Loader when exploding all the attributes from yaml.
# __PACKAGE__->meta->make_immutable;

1;
