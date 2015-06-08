#!/usr/bin/env perl

use warnings;
use strict;
use feature 'say';
use List::Itertools 'iter';


sub fibbonachi {
    my ($a, $b) = (0, 1);
    return iter(sub {
        ($a, $b) = ($b, $a + $b);
        return $a;
    })
}

my $iter = fibbonachi;
say $iter->next for 1..10;
