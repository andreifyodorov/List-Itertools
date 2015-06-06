#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Try::Tiny;

use List::Itertools qw(iter catch_stop for_each);


plan tests => 2;

{
    my $iter = iter([]);

    ok(
        (
            try {
                $iter->();
                0;
            }
            catch {
                $_->isa('List::Itertools::Exceptions::StopIteration')
            }
        ),
        'iterator throws StopIteration'
    );

    ok($iter->is_iter, 'iterator is iterator');
}


{
    my $list = [1..10, undef, 10..20];
    my @result;
    for (my $iter = iter($list); my ($x) = $iter->next(); ) {
        push(@result, $x);
    }
    cmp_deeply(\@result, $list, 'iterator from list');
}


{
    my $iter = iter([1..10]);
    my $i = 0;
    ok((try{ $iter->() } catch_stop { 10 == ++$i }), 'catch_stop cathes stop of iteration');
}

{
    my $list = [1..10, undef, 10..20];
    my @result;
    for_each $list, sub { push(@result, $_) };
    cmp_deeply(\@result, $list, 'for_each iterates lists');
}

{
    my $list = [1..10, undef, 10..20];
    my $iter = iter($list);
    my @result;
    for_each $iter, sub { push(@result, $_) };
    cmp_deeply(\@result, $list, 'for_each iterates iterator');
}