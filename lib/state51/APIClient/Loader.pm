package state51::APIClient::Loader;

use Moose;
use MooseX::Types::Moose qw / Str /;
use state51::APIClient;
use YAML ();
use Data::Dumper;
use MooseX::Types::ISO8601;
use Try::Tiny;
use state51::Types;

has class_prefix => (
    isa => Str,
    is  => 'ro',
    required => 1,
    default => 'state51::APIClient::Media::v1::',
);

has schema_file => (
    isa => Str,
    is  => 'ro',
    required => 1,
);

sub load_class {
    my ($self, $hash) = @_;

    my $class = $hash->{__CLASS__} or die "No __CLASS__ element.  Have: ".Dumper($hash);
    $class = $self->class_prefix.$class;

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
        elsif ((ref($val) eq 'HASH') && $val->{__REPRESENTATION__}) {
            # TODO!  Add some magic logic to load the referenced class.
            return;
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
        my @r = ( $crunch_value->($hash->{$k}) );
        if (@r) {
            $init{$k} = $r[0]
        }
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
        $superclass ||= 'state51::APIClient::REST';

        my $meta;
        try {
            Class::MOP::load_class("$prefix$class");
            $meta = "$prefix$class"->meta;
        };

        $meta ||= Moose::Meta::Class->create("$prefix$class",
            superclasses => [ $superclass ],
        );

        if (scalar($meta->superclasses) != 1) {
            die "erk, wrong number of superclasses";
        }
        if (($meta->superclasses)[0] ne $superclass) {
            die "erk, wrong superclass";
        }

        foreach my $attr (@{ $data->{$class}->{attributes} }) {
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

