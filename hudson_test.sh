#!/bin/bash

set -x

export TMPDIR=/space/hudson/tmpfs/api-client-$$
export FILE_CACHE_DIR=$TMPDIR
MEMCACHE_SERVERS=
MOGILE_TRACKER=
VARNISH_HOSTS=

mkdir $TMPDIR

echo $WORKSPACE

perl Makefile.PL --skipdeps
make

prove -Ilib --timer -r --formatter TAP::Formatter::JUnit t/ > junit_output.xml
rm -rf $TMPDIR
