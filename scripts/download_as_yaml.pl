#!/usr/bin/env perl

use strict;
use warnings;

use OpenIMP::APIClient::Media::v1;
use YAML qw/ DumpFile /;

DumpFile("nmc_example.yaml", OpenIMP::APIClient::Media::v1->instance->GET(["licensor/577538050016/release/upc/5023363017725"]));
DumpFile("nmc_example_file.yaml", OpenIMP::APIClient::Media::v1->instance->GET(["filestore/478181073"]));
DumpFile("nmc_example_encoding.yaml", OpenIMP::APIClient::Media::v1->instance->GET(["/encoding/wav_44_16_2"]));

