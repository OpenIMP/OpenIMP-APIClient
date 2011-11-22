package state51::APIClient::Loader;

use Moose;
use MooseX::Types::Moose qw / Str /;
use state51::APIClient;
use YAML ();
use Data::Dumper;
use MooseX::Types::ISO8601;

with qw/ state51::Mixin::APIClient /;

has class_prefix => (
    isa => Str,
    is  => 'ro',
    required => 1,
    default => 'state51::APIClient::Media::v1::',
);

has config_file => (
    isa => Str,
    is  => 'ro',
);

has schema_file => (
    isa => Str,
    is  => 'ro',
    required => 1,
);

sub BUILDARGS {
    my ($self) = shift;
    my $args = $self->SUPER::BUILDARGS(@_);

    my $conf = YAML::LoadFile($args->{config_file});
    $args->{uri}      ||= $conf->{s51_api}->{uri};
    $args->{user}     ||= $conf->{s51_api}->{username};
    $args->{password} ||= $conf->{s51_api}->{password};

    return $args;
}

sub load_class {
    my ($self, $hash) = @_;

    my $class = $hash->{__CLASS__} or die "No __CLASS__ element.  Have: ".Dumper($hash);
    $class = $self->class_prefix.$class;

    print "building a $class\n";
    if ($class eq 'state51::APIClient::Media::v1::MFS::Metadata::Recording') {
        print Dumper($hash);
    }

    my %init;

    my $crunch_value; $crunch_value = sub {
        my ($val) = @_;

        if (!ref($val)) {
            return $val;
        }
        elsif (ref($val) eq 'ARRAY') {
            return [
                map { $crunch_value->($_) } @{ $val }
            ];
        }
        elsif ((ref($val) eq 'HASH') && $val->{__CLASS__}) {
            return $self->load_class($val);
        }
        elsif (ref($val) eq 'HASH') {
            return {
                map { $_ => $crunch_value->($val->{$_}) }
                keys %{ $val }
            }
        }
        else {
            die "Cannot make sense of $val";
        }
    };


    foreach my $k (keys %{ $hash }) {
        $init{$k} = $crunch_value->($hash->{$k});
    }

    return $class->new( %init );
}

sub BUILD {
    my ($self) = @_;
    my $data = YAML::LoadFile($self->schema_file);

    foreach my $class (keys(%{ $data })) {
        my $meta = Moose::Meta::Class->create($self->class_prefix.$class);
        print $meta->instance_metaclass."\n";
        foreach my $attr (@{ $data->{$class}->{attributes} }) {
            print "building $class / ".$attr->{name}."\n";
            $meta->add_attribute(
                Moose::Meta::Attribute->new(
                    $attr->{name},
                    is => 'ro',
                    isa => $attr->{type},
                    documentation => $attr->{documentation},
                )
            );
        }
        $meta->add_method( meta => sub { $meta } );
        $meta->make_immutable();
    }

    return;
}

__PACKAGE__->meta->make_immutable;

