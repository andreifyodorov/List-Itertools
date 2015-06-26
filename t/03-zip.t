#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Try::Tiny;

use List::Itertools qw(
    iter is_iter list izip izip_from_iterable izip_longest izip_longest_from_iterable
);


plan tests => 24;


my @list = ([1, 2, 3], ['x', undef, 'z'], [10, 20, 30, 40]);
my @result = ([1, 'x', 10], [2, undef, 20], [3, 'z', 30]);
my @result_longest = (@result, [undef, undef, 40]);
my @test = (
    ['izip', sub { izip(@_) }, \@result],
    ['izip_from_iterable from array', sub { izip_from_iterable(\@_) }, \@result],
    ['izip_from_iterable from iterator', sub { izip_from_iterable(iter(\@_)) }, \@result],
    ['izip_longest', sub { izip_longest(@_) }, \@result_longest],
    ['izip_longest_from_iterable from array', sub { izip_longest_from_iterable(\@_) }, \@result_longest],
    ['izip_longest_from_iterable from iterator', sub { izip_longest_from_iterable(iter(\@_)) }, \@result_longest]
);

for (my $iter = iter(\@test); my ($name, $code, $result) = $iter->next_tuple(); ) {
    ok(is_iter($code->(@list)), "$name is iterator");

    cmp_deeply(list($code->(@list)), $result, "$name zips arrays");

    my @iterators = map { iter($_) } @list;
    cmp_deeply(list($code->(@iterators)), $result, "$name zips iterators");

    my $i = 0;
    my @iterables = map { $i++ % 2 ? iter($_) : $_ } @list;
    cmp_deeply(list($code->(@iterables)), $result, "$name zips mixed");
}
