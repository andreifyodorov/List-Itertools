#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use List::Itertools qw(iter is_iter list chain chain_from_iterable);


plan tests => 12;

my @list = ([1, 2, 3], ['x', undef, 'z'], [10, 20, 30, 40]);
my @flat_list = map { @$_ } @list;

my @test = (
    [ 'chain', sub { chain(@_) } ],
    [ 'chain_from_iterable from array', sub { chain_from_iterable(\@_) } ],
    [ 'chain_from_iterable from iterator', sub { chain_from_iterable(iter(\@_)) } ],
);

for (my $iter = iter(\@test); my ($name, $code) = $iter->next_tuple(); ) {
    ok(is_iter($code->(@list)), "$name is iterator");

    cmp_deeply(list($code->(@list)), \@flat_list, "$name concatenates arrays");

    my @iterators = map { iter($_) } @list;
    cmp_deeply(list($code->(@iterators)), \@flat_list, "$name concatenates iterators");

    my $i = 0;
    my @iterables = map { $i++ % 2 ? iter($_) : $_ } @list;
    cmp_deeply(list($code->(@iterables)), \@flat_list, "$name concatenates mixed");
}