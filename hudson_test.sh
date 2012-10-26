#!/bin/bash

set -x

export RUNNING_IN_HUDSON="1"
export TMPDIR="/space/hudson/tmpfs/api-client-$$"
export FILE_CACHE_DIR="$TMPDIR"
export MEMCACHE_SERVERS=""
export MOGILE_TRACKER=""
export VARNISH_HOSTS=""

mkdir $TMPDIR

echo $WORKSPACE

perl Makefile.PL --skipdeps
make

prove -Ilib --timer -r --formatter TAP::Formatter::JUnit t/ > junit_output.xml
rm -rf $TMPDIR
