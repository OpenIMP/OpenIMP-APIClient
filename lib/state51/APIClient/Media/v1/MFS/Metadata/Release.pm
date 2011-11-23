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

__PACKAGE__->make_immmutable;

1;
