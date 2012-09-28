package OpenIMP::APIClient::Media::v1;

use MooseX::Singleton;
use File::ShareDir qw/ module_file /;
use OpenIMP::APIClient::Loader;
use MooseX::Types::Moose qw/ Str /;
use File::Spec;

with qw/ OpenIMP::Mixin::APIClient /;

has config_file => (
    isa => Str,
    is  => 'ro',
    default => '/etc/openimp-api-auth.yml',
);

sub _config_file_local {
    if ($^O eq 'Win32') {
        local $@;
        my $root = eval {"require Win32; Win32::GetFolderPath(Win32::CSIDL_APPDATA);"};
        die "could not find CISDL__APPDATA: $@" unless $root;

        return File::Spec->catfile($root, "openimp-api-auth.yml");
    }
    else {
        return "/etc/openimp-api-auth.yml";
    }
}

around BUILDARGS => sub {
    my ($orig, $class, %args) = shift;

    my $conf = YAML::LoadFile($args{config_file} || "/etc/openimp-api-auth.yml" );
    $args{uri}      ||= $conf->{s51_api}->{uri};
    $args{user}     ||= $conf->{s51_api}->{username};
    $args{password} ||= $conf->{s51_api}->{password};

    return $class->$orig(%args);
};


has loader => (
    isa => 'OpenIMP::APIClient::Loader',
    is  => 'ro',
    default => sub {
        OpenIMP::APIClient::Loader->new(
            class_prefix => 'OpenIMP::APIClient::Media::v1::',
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

    return $self->load_class($self->GET(["licensor", $asset_controller, "release", "upc", $upc]), undef, $self);
}

__PACKAGE__->meta->make_immutable;
