package state51::APIClient::Media;

use MooseX::Singleton;
use File::ShareDir qw/ module_file /;
use state51::APIClient;
use state51::APIClient::Loader;

has loader => (
    isa => 'state51::APIClient::Loader',
    is  => 'ro',
    default => sub {
        state51::APIClient::Loader->new(
            config_file => '/etc/state51-api-auth.yml',
            class_prefix => 'state51::APIClient::Media::v1::',
            schema_file => module_file('state51::APIClient', 'mediaapi.yaml'),

        );
    },
    lazy => 1,
    handles => {
        load_class => 'load_class'
    },
);

__PACKAGE__->meta->make_immutable;
