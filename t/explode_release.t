#!/usr/bin/env perl

use strict;
use warnings;

use state51::APIClient::Media;
use YAML qw/ LoadFile /;
use FindBin;
use File::Spec;
use Test::More;

my $misc_dir = File::Spec->catdir("$FindBin::Bin", "misc");


my $obj = state51::APIClient::Media->instance->load_class(LoadFile(File::Spec->catfile($misc_dir, "nmc_5023363017725.yaml")));

isa_ok($obj, 'state51::APIClient::Media::v1::MFS::Metadata::Release');
isa_ok($obj, 'state51::APIClient::REST');

done_testing();

