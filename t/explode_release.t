#!/usr/bin/env perl

use strict;
use warnings;

use OpenIMP::APIClient::Media::v1;
use YAML qw/ LoadFile /;
use FindBin;
use File::Spec;
use Test::More;
use Test::MockObject;
use File::ShareDir qw/ module_file /;

my $misc_dir = File::Spec->catdir("$FindBin::Bin", "misc");

my $loader = OpenIMP::APIClient::Loader->new(
    class_prefix => 'OpenIMP::APIClient::Media::v1::',
    schema_file => module_file('OpenIMP::APIClient::Media::v1', 'mediaapi.yaml'),
);

my $invocations = 0;
my $return;

my $pretend_api = Test::MockObject->new();
$pretend_api->mock('GET', sub {
    $invocations++;
    return $return;
});

my $obj = $loader->load_class(LoadFile(File::Spec->catfile($misc_dir, "nmc_5023363017725.yaml")), undef, $pretend_api);

isa_ok($obj, 'OpenIMP::APIClient::Media::v1::MFS::Metadata::Release');
isa_ok($obj, 'OpenIMP::APIClient::REST');


my $track1 = $obj->find_track(1, 1);
isa_ok($track1, 'OpenIMP::APIClient::Media::v1::MFS::Metadata::Track');
is($track1->TrackNumber, 1);
is($track1->VolumeNumber, 1);

my $track4 = $obj->find_track(4, 1);
isa_ok($track4, 'OpenIMP::APIClient::Media::v1::MFS::Metadata::Track');
is($track4->TrackNumber, 4);
is($track4->VolumeNumber, 1);

is(scalar(@{ $track1->files }), 9);
isa_ok($track1->files->[0], 'OpenIMP::APIClient::Media::v1::MFS::File::Audio');
is($track1->files->[0]->__REPRESENTATION__, "/filestore/478181073");
isa_ok($track1->files->[0]->encoding, 'OpenIMP::APIClient::Media::v1::MFS::Metadata::Encoding');
is($track1->files->[0]->encoding->__LOADED__, 0, 'not loaded fully yet');
is($track1->files->[0]->encoding->Name, 'wav_44_16_2');
ok($track1->files->[0]->encoding->has_Name);
ok(!$track1->files->[0]->encoding->has_Bitrate);
is($track1->files->[0]->encoding->__LOADED__, 0, 'still not fully loaded');

is($invocations, 0);
$return = LoadFile(File::Spec->catfile($misc_dir, "nmc_example_encoding.yaml"));

is($track1->files->[0]->encoding->Bitrate, 1411);

is($invocations, 1);
is($track1->files->[0]->encoding->__LOADED__, 1, 'now loaded');
is($track1->files->[0]->encoding->Codec, 'PCM');
is($invocations, 1, 'only one HTTP request');

done_testing();

