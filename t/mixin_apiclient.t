use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Class qw/dir/;
{
    package TestAPIClient;
    use Moose;
    with 'OpenIMP::Mixin::APIClient';
    no Moose;
}

my $i;
lives_ok { $i = TestAPIClient->new(
    uri => 'https://example.com/api/v1/',
    password => 'fred',
    user => 'bloggs',
) };
ok $i && do {
    my $uri;
    lives_ok { $uri = $i->_uri_with_path(['foo', 'bar', dir('/FOO/bar/baz')]) };

    ok $uri;
    use Data::Dumper; warn Dumper($uri);
};

done_testing;

