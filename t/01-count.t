#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use List::Itertools qw(is_iter count range list);


plan tests => 3;

{
    my $counter = count();
    ok(is_iter($counter), 'count is iter');
    cmp_deeply([map {$counter->next()} 0..10], [0..10], 'count');
    
}

{
    my $counter = count(10);
    cmp_deeply([map {$counter->next()} 0..10], [10..20], 'count from 10');
    
}

{
    my $counter = count(undef, 3);
    cmp_deeply([map {$counter->next()} 0..10], [map {$_ * 3} 0..10], 'count with step 3');
    
}

{
    my $range = range(10);
    ok(is_iter($range), 'range is iterator');
    cmp_deeply(list($range), [0..10], 'range to 10');
}

{
    my $range = range(5, 10);
    cmp_deeply(list($range), [5..10], 'range from 5 to 10');
}

{
    my $range = range(0, 9, 3);
    cmp_deeply(list($range), [map {$_ * 3} 0..3], 'range from 0 to 9 with step 3');
}

{
    my $range = range(0, 10, 3);
    cmp_deeply(list($range), [map {$_ * 3} 0..3], 'range from 0 to 10 with step 3');
}