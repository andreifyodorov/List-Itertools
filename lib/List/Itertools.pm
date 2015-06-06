#!/usr/bin/env perl

package List::Itertools;

use strict;
use warnings;
use Carp::Always;

use constant STOP_ITERATION => __PACKAGE__ . '::Exceptions::StopIteration';
use constant NOT_ITERABLE => __PACKAGE__ . '::Exceptions::NotIterable';

use Try::Tiny;
use Scalar::Util 'blessed';
use Exception::Class (
    STOP_ITERATION, { description => 'Iterator exhausted' },
    NOT_ITERABLE, { description => 'Whatnot is not iterable' }
);


use Exporter 'import';
our @EXPORT_OK = (qw{iter catch_stop for_each imap chain});


sub iter_array {
    my $list = shift;
    my $i = 0;
    return bless sub {
        while (1) {
            defined($list)
                ? $i < @$list ? return $list->[$i++] : undef($list)
                : STOP_ITERATION->throw;
        }
    } => __PACKAGE__;
}


sub range($;$$) {
    # TODO
}

sub catch_stop(&) {
    my $code = shift;
    return catch {
        die $_ unless blessed $_ && $_->can('rethrow');
        $_->rethrow unless $_->isa(STOP_ITERATION);
        return $code->();
    }
}


sub next() {
    my $iter = shift;
    try { return $iter->() } catch_stop { return () };
}


sub is_iter { blessed $_[0] && $_[0]->can('next') }


sub iter {
    return $_[0] if is_iter($_[0]);
    return iter_array($_[0]) if ref $_[0] eq 'ARRAY';
    NOT_ITERABLE->throw;
}


sub imap(&;@) {
    my $code = shift;
    my $iter = iter(shift);
    return bless sub {
        local $_ = $iter->();
        return $code->();
    } => __PACKAGE__;
}


sub for_each {
    my $whatnot = shift;
    my $code = shift;
    for (my $iter = imap { $code->() } $whatnot; $iter->next; ) {}
}


sub list {
    my $iter = $_;
    return [@$iter] if ref($iter) eq 'ARRAY';
    my @rv;
    while (my ($x) = $iter->next) {
        push(@rv, $x)
    }
    return \@rv;
}


sub chain {
    my $iters = \@_;
    my $iter;
    return bless sub {
        while (1) {
            unless ($iter) {
                STOP_ITERATION->throw unless @$iters;
                $iter = shift(@$iters);
                $iter = iter($iter) unless is_iter($iter);
            }
            my $rv;
            try { $rv = $iter->(); 1; } catch_stop { undef($iter) } or next;
            return $rv;
        }
    } => __PACKAGE__;
}


sub chain_from_iterable {
    # TODO
}


sub izip {
    # TODO
}


sub izip_longest_from_iterable {
    # TODO: filler option
    my @iters = @_;
}

1;