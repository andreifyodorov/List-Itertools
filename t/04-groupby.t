#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use Data::Dumper 'Dumper';

use Test::More;
use Test::Deep;
use List::Itertools qw(iter is_iter imap list groupby);


plan tests => 12;

my @list = (
    {key => undef, payload => 1},
    {key => undef, payload => 2},
    {key => '', payload => 3},
    {key => 'foo', payload => 1},
    {key => 'bar', payload => 1},
    {key => 'bar', payload => 2},
    {key => 'bar', payload => 3},
    {key => 'foo', payload => 1},
    {key => 'bar', payload => 4},
);

my @result = (
    [undef, [
        {key => undef, payload => 1},
        {key => undef, payload => 2},
    ]],
    ['', [
        {key => '', payload => 3},
    ]],
    [foo => [
        {key => 'foo', payload => 1},
    ]],
    [bar => [
        {key => 'bar', payload => 1},
        {key => 'bar', payload => 2},
        {key => 'bar', payload => 3},
    ]],
    [foo => [
        {key => 'foo', payload => 1},
    ]],
    [bar => [
        {key => 'bar', payload => 4},
    ]],
);

my @keys = map $_->[0], @result;

my @test = (
    ['from array', sub { $_[0] }],
    ['from iterator', sub { iter($_[0]) }]
);

for (my $iter = iter(\@test); my ($whence, $code) = $iter->next_tuple; ) {
    {
        my $group = groupby {$_->{key}} $code->(\@list);
        ok(is_iter($group), "groupby $whence is iter");

        my @got;
        {
            my $element = $group->next;
            ok(
                ref($element) eq 'ARRAY' && scalar @$element == 2,
                "groupby $whence element is pair"
            );

            my ($key, $grouped) = @$element;
            ok(!ref($key), "groupby $whence 1st item is scalar");
            ok(is_iter($grouped), "groupby $whence 2nd item is iter");

            push(@got, [$key => list($grouped)]);
        }

        while (my ($key, $grouped) = $group->next_tuple) {
            push(@got, [$key => list($grouped)]);
        }

        cmp_deeply(\@result, \@got, "groupby $whence sequental traversal");
    }

    {
        my $group = groupby {$_->{key}} $code->(\@list);
        cmp_deeply(\@keys, list(imap { $_->[0] } $group), "groupby $whence key traversal");
    }

}
