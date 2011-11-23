package state51::APIClient::Media::v1::MFS::Metadata::Release;

use Moose;

extends qw/ state51::APIClient::REST /;

sub find_track {
    my ($self, $track, $vol) = @_;

    foreach my $t (@{ $self->tracks }) {
        return $t if ($t->TrackNumber == $track && $t->VolumeNumber == $vol);
    }

    die "Could not find volume $vol track $track";
}

# Invoked by state51::APIClient::Loader when exploding all the attributes from yaml.
# __PACKAGE__->meta->make_immutable;

1;
