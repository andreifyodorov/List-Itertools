#!/usr/bin/env perl

package List::Itertools;

use 5.014;
use strict;
use warnings;
use Carp::Always;
use Data::Dumper 'Dumper';

use constant STOP_ITERATION => __PACKAGE__ . '::Exceptions::StopIteration';
use constant NOT_ITERABLE => __PACKAGE__ . '::Exceptions::NotIterable';

use Try::Tiny;
use Scalar::Util 'blessed';
use Exception::Class (
    STOP_ITERATION, { description => 'Iterator exhausted' },
    NOT_ITERABLE, { description => 'Whatnot is not iterable' }
);


use Exporter 'import';
our @EXPORT_OK = qw(
    STOP_ITERATION
    NOT_ITERABLE
    iter
    is_iter
    catch_stop
    for_each
    list
    imap
    igrep
    count
    range
    chain
    chain_from_iterable
    izip
    izip_from_iterable
    izip_longest
    izip_longest_from_iterable
    groupby
    product
    product_from_iterable
);


sub iter_code($) { bless $_[0] => __PACKAGE__ }


sub iter_array($) {
    my $list = shift;
    my $i = 0;
    return iter_code(sub {
        while (1) {
            defined($list)
                ? $i < @$list ? return $list->[$i++] : undef($list)
                : STOP_ITERATION->throw;
        }
    });
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
    # TODO: throw something if it's not iter
    try { return $iter->() } catch_stop { return () };
}


sub next_tuple() {
    if (my ($tuple) = &next(@_)) {
        return @$tuple;
    }
    else {
        return ();
    }
}


sub is_iter($) { blessed($_[0]) && $_[0]->can('next') }


sub iter($) {
    my $whatnot = shift;
    @_ and die(sprintf("iter requires 1 parameter %d given", @_));
    return $whatnot if is_iter($whatnot);
    return iter_code($whatnot) if ref($whatnot) eq 'CODE';
    return iter_array($whatnot) if ref($whatnot) eq 'ARRAY';
    NOT_ITERABLE->throw;
}


sub imap(&$) {
    my $code = shift;
    my $iter = iter(shift);
    iter_code(sub {
        local $_ = $iter->();
        return $code->();
    });
}


sub igrep(&$) {
    my $code = shift;
    my $iter = iter(shift);
    iter_code(sub {
        while (1) {
            local $_ = $iter->();
            return $_ if $code->();
        }
    });
}


sub for_each($&) {
    my $whatnot = shift;
    my $code = shift;
    for (my $iter = imap { $code->() } $whatnot; $iter->next; ) {}
}


sub list($) {
    my $iter = shift;
    return [@$iter] if ref($iter) eq 'ARRAY';
    my @rv;
    for_each $iter, sub { push(@rv, $_) };
    return \@rv;
}


sub count(;$$) {
    my ($firstval, $step) = @_;
    $step //= 1;
    my $nextval = $firstval // 0;
    return iter_code(sub {
        my $rv = $nextval;
        $nextval += $step;
        return $rv;
    });
}


sub range($;$$) {
    my ($start, $stop, $step) = @_ == 1 ? (0, shift) : @_;
    $step //= 1;
    die "Step arguent must not be zero" unless $step;
    my $iter = count($start, $step);
    return iter_code(sub {
        my $rv = $iter->next;
        STOP_ITERATION->throw if $rv > $stop;
        return $rv;
    });
}


sub chain_from_iterable($) {
    my $iters = iter(shift);
    my $iter;
    return iter_code(sub {
        while (1) {
            $iter = iter($iters->()) unless $iter;
            my $rv;
            try { $rv = $iter->() or 1 } catch_stop { undef($iter) } or next;
            return $rv;
        }
    });
}


sub chain { chain_from_iterable(\@_) }


sub izip_from_iterable($) {
    my $iterables = list(imap { iter($_) } shift);
    return iter_code(sub { return [ map { $_->() } @$iterables ] });
}


sub izip { izip_from_iterable(\@_) }


sub izip_longest_from_iterable($) {
    my $iterables = list(imap { iter($_) } shift);
    my $filler = shift;
    my $exhausted = 0;
    return iter_code(sub {
        my @rv;
        foreach my $iter (@$iterables) {
            push(
                @rv,
                try {
                    $iter->() if $iter
                }
                catch_stop {
                    undef($iter);
                    $exhausted++;
                    return $filler;
                }
            );
        }
        STOP_ITERATION->throw if $exhausted == @$iterables;
        return \@rv;
    });
}


sub izip_longest { izip_longest_from_iterable(\@_) }


sub _equal {
    # In the contrast of proper programming languages,
    # Perl's equality operators do not produce binary relation,
    # as a result of camparison could be one of these three:
    # false, true, and true with warning.
    my ($a, $b) = @_;
    return defined($a) && defined($b) && $a eq $b || !defined($a) && !defined($b);
    # If someone somewhere does actually dream in Perl,
    # as Larry Wall once claimed he does, that should be an effing nightmare.
}


sub groupby(&$) {
    my $keyfunc = shift;
    my $iter = iter(shift);
    my ($tgtkey, $currkey, $curritem, $warmedup);
    my $next = sub {
        local $_ = $curritem = $iter->();
        $currkey = $keyfunc->();
    };
    return iter_code(sub {
        if ($warmedup) {
            $next->() while _equal($tgtkey, $currkey);
        }
        else {
            $next->();
            $warmedup = 1;
        }
        $tgtkey = $currkey;
        return [$tgtkey => iter_code(sub {
            state $exhausted;
            STOP_ITERATION->throw if $exhausted;
            my $rv = $curritem;
            $exhausted = try { !_equal($tgtkey, $next->()) } catch_stop { 1 };
            return $rv;
        })];
    });
}


sub product_from_iterable($) {
}


sub product {
}


1;