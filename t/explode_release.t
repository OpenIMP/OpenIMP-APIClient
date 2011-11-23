#!/usr/bin/env perl

use strict;
use warnings;

use state51::APIClient::Media;
use YAML qw/ LoadFile /;
use FindBin;
use File::Spec;
use Test::More;
use File::ShareDir qw/ module_file /;

my $misc_dir = File::Spec->catdir("$FindBin::Bin", "misc");

my $loader = state51::APIClient::Loader->new(
    class_prefix => 'state51::APIClient::Media::v1::',
    schema_file => module_file('state51::APIClient::Media', 'mediaapi.yaml'),
);

my $obj = $loader->load_class(LoadFile(File::Spec->catfile($misc_dir, "nmc_5023363017725.yaml")));

isa_ok($obj, 'state51::APIClient::Media::v1::MFS::Metadata::Release');
isa_ok($obj, 'state51::APIClient::REST');

is($obj->foo, 'hello');

done_testing();

