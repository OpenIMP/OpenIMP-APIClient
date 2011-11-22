package state51::APIClient::Loader;

use Moose;
use MooseX::Types::Moose qw / Str /;
use state51::APIClient;
use YAML ();
use Data::Dumper;
use MooseX::Types::ISO8601;
use Try::Tiny;

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

    my $obj;
    try {
        $obj = $class->new( %init );
    }
    catch {
        warn Dumper( \%init );
        die $_;
    };

    return $obj;
}

sub BUILD {
    my ($self) = @_;
    my $data = YAML::LoadFile($self->schema_file);

    my @class_names = sort { length($b) <=> length($a) } keys %{ $data };

    my $prefix = $self->class_prefix;

    foreach my $class (sort keys(%{ $data })) {
        my $superclass = $data->{$class}->{parent};
        if ($superclass) {
            $superclass = $prefix . $superclass;
        }

        my $meta = Moose::Meta::Class->create("$prefix$class",
            $superclass ? ( superclasses => [ $superclass ] ) : ()
        );
        foreach my $attr (@{ $data->{$class}->{attributes} }) {
            print "building $class / ".$attr->{name}."\n";

            my $type = $attr->{type};
            # XXX extremely crude type munging, should parse properly.
            foreach my $cn (@class_names) {
                if (index($type, $cn)>=0) {
                    $type =~ s/$cn/$prefix$cn/g;
                    last;
                }
            }

            $meta->add_attribute(
                Moose::Meta::Attribute->new(
                    $attr->{name},
                    is => 'ro',
                    isa => $type,
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

