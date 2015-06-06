#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Try::Tiny;

use List::Itertools qw(izip_longest);


plan tests => 1

{
    cmp_deeply(
        list(izip_logest([1, 2, 3], ['x', undef, 'z'], [10, 20, 30, 40])),
        [[1, 'x', 10], [2, undef, 20], [3, 'z', 30], [undef, undef, 40]]
    );
}
