#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Try::Tiny;

use List::Itertools qw(chain);


plan tests => 1

{
    cmp_deeply(
        chain([1, 2, 3], ['x', undef, 'z'], [10, 20, 30, 40]),
        [[1, 'x', 10], [2, undef, 20], [3, 'z', 30], [undef, undef, 40]]
    );
}
