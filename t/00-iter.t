#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Try::Tiny;

use List::Itertools qw(STOP_ITERATION NOT_ITERABLE iter is_iter catch_stop for_each list);


plan tests => 9;


ok((try { iter(1) and 0 } catch { $_->isa(NOT_ITERABLE) }), 'iter requires iterable');

{
    my $iter = iter([]);
    ok((try { $iter->() and 0 } catch { $_->isa(STOP_ITERATION)}), 'iterator throws STOP_ITERATION');
    ok(is_iter($iter), 'iterator is iterator');
}

my @list = (1..10, undef, 10..20);

{
    my @result;
    for (my $iter = iter(\@list); my ($x) = $iter->next; ) {
        push(@result, $x);
    }
    cmp_deeply(\@result, \@list, 'iterator from list iterated with next');
}

{
    my @result;
    my @list = ([1, 2], [2, 3], [3, 4]);
    for (my $iter = iter(\@list); my ($a, $b) = $iter->next_tuple; ) {
        push(@result, [$a, $b]);
    }
    cmp_deeply(\@result, \@list, 'iterator from list iterated with next_tuple');
}


{
    my $iter = iter(\@list);
    my $i = 0;
    ok((try{ $iter->() } catch_stop { @list == ++$i }), 'catch_stop cathes stop of iteration');
}

{
    my @result;
    for_each \@list, sub { push(@result, $_) };
    cmp_deeply(\@result, \@list, 'for_each iterates lists');
}

{
    my $iter = iter(\@list);
    my @result;
    for_each $iter, sub { push(@result, $_) };
    cmp_deeply(\@result, \@list, 'for_each iterates iterator');
}

{
    cmp_deeply(list(iter(\@list)), \@list, 'list from iterator');
}