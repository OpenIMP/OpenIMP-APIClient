#!/usr/bin/env perl

use strict;
use warnings;

use state51::APIClient::Media;
use YAML qw/ DumpFile /;

DumpFile("nmc_example.yaml", state51::APIClient::Media->instance->loader->GET(["licensor/577538050016/release/upc/5023363017725"]));

