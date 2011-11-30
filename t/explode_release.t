#!/usr/bin/env perl

use strict;
use warnings;

use state51::APIClient::Media::v1;
use YAML qw/ LoadFile /;
use FindBin;
use File::Spec;
use Test::More;
use File::ShareDir qw/ module_file /;

my $misc_dir = File::Spec->catdir("$FindBin::Bin", "misc");

my $loader = state51::APIClient::Loader->new(
    class_prefix => 'state51::APIClient::Media::v1::',
    schema_file => module_file('state51::APIClient::Media::v1', 'mediaapi.yaml'),
);

my $obj = $loader->load_class(LoadFile(File::Spec->catfile($misc_dir, "nmc_5023363017725.yaml")));

isa_ok($obj, 'state51::APIClient::Media::v1::MFS::Metadata::Release');
isa_ok($obj, 'state51::APIClient::REST');


my $track1 = $obj->find_track(1, 1);
isa_ok($track1, 'state51::APIClient::Media::v1::MFS::Metadata::Track');
is($track1->TrackNumber, 1);
is($track1->VolumeNumber, 1);

my $track4 = $obj->find_track(4, 1);
isa_ok($track4, 'state51::APIClient::Media::v1::MFS::Metadata::Track');
is($track4->TrackNumber, 4);
is($track4->VolumeNumber, 1);

is(scalar(@{ $track1->files }), 9);
isa_ok($track1->files->[0], 'state51::APIClient::Media::v1::MFS::File::Audio');
is($track1->files->[0]->__LOADED__, 1);
is($track1->files->[0]->__REPRESENTATION__, "/filestore/478181073");

done_testing();

