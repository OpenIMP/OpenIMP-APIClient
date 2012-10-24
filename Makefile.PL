use 5.010001;
use ExtUtils::MakeMaker;
use FindBin;
use strict;
use warnings;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'OpenIMP::APIClient',
    VERSION_FROM      => 'lib/OpenIMP/APIClient.pm', # finds $VERSION
    PREREQ_PM         => {
        'Digest::SHA1' => 0,
        'Moose' => 0,
        'MooseX::Types::GTIN' => 0,
        'MooseX::Types::Moose' => 0,
        'MooseX::Types::URI' => 0,
        'Method::Signatures::Simple' => 0,
        'LWP::UserAgent' => 0,
        'JSON' => 0,
        'MooseX::Getopt' => 0,
        'Try::Tiny' => 0,
        'namespace::autoclean' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::MockObject' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/OpenIMP/APIClient.pm', # retrieve abstract from module
       AUTHOR         => 'Dave Lambley <davel@openimp.com>') : ()),

    META_MERGE => {
        resources => {
            repository => "https://github.com/davel/MogileFS-Plugin-RandomWrites",
        },
    },
);

# Requires Pod::Markdown
system("pod2markdown < $FindBin::Bin/lib/OpenIMP/APIClient.pm > $FindBin::Bin/README.md");
