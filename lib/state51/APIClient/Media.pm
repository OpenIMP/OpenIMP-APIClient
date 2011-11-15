package state51::APIClient::Media;

use MooseX::Singleton;
use YAML ();

with qw/ state51::Mixin::APIClient /;

has class_prefix => (
    isa => Str,
    is  => 'ro',
    default => 'state51::APIClient::Media::v1',
);

sub BUILDARGS {
    my ($self) = shift;
    my $args = $self->SUPER::BUILDARGS(@_);

    my $conf = YAML::LoadFile("/etc/state51-api-auth.yml");
    $args->{uri}      ||= $conf->{s51_api}->{uri};
    $args->{user}     ||= $conf->{s51_api}->{username};
    $args->{password} ||= $conf->{s51_api}->{password};

    return $args;
}

sub BUILD {

}

__PACKAGE__->meta->make_immutable;

