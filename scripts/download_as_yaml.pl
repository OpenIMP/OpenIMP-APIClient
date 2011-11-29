#!/usr/bin/env perl

use strict;
use warnings;

use state51::APIClient::Media::v1;
use YAML qw/ DumpFile /;

DumpFile("nmc_example.yaml", state51::APIClient::Media::v1->instance->GET(["licensor/577538050016/release/upc/5023363017725"]));
DumpFile("nmc_example_file.yaml", state51::APIClient::Media::v1->instance->GET(["filestore/478181073"]));

