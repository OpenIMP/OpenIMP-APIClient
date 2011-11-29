package state51::APIClient::Media::v1;

use MooseX::Singleton;
use File::ShareDir qw/ module_file /;
use state51::APIClient::Loader;
use MooseX::Types::Moose qw/ Str /;

with qw/ state51::Mixin::APIClient /;

has config_file => (
    isa => Str,
    is  => 'ro',
    default => '/etc/state51-api-auth.yml',
);

around BUILDARGS => sub {
    my ($orig, $class, %args) = shift;

    my $conf = YAML::LoadFile($args{config_file} || "/etc/state51-api-auth.yml" );
    $args{uri}      ||= $conf->{s51_api}->{uri};
    $args{user}     ||= $conf->{s51_api}->{username};
    $args{password} ||= $conf->{s51_api}->{password};

    return $class->$orig(%args);
};


has loader => (
    isa => 'state51::APIClient::Loader',
    is  => 'ro',
    default => sub {
        state51::APIClient::Loader->new(
            class_prefix => 'state51::APIClient::Media::v1::',
            schema_file => module_file(__PACKAGE__, 'mediaapi.yaml'),
        );
    },
    lazy => 1,
    handles => {
        load_class => 'load_class'
    },
);

sub get_release {
    my ($self, $asset_controller, $upc) = @_;

    return $self->load_class($self->GET(["licensor", $asset_controller, "release", "upc", $upc]));
}

__PACKAGE__->meta->make_immutable;
