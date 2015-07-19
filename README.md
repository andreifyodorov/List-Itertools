# List::Itertools
## Best way to iterate an array is to make it an iterable

    for (my $iter = iter(\@array); my ($x) = $iter->next; ) {
      ...
    }

## Python itertools in Perl

Solving certain data processing tasks via iterator alghorithms is modern mainstream. It takes some time to learn, but is a clear, straightforward, easy to design, and efficient way. Perl naturally lacks this paradigm. There are some attempts to fill this void, but they seem more like abandoned reinventions, whereas existing Python approach to iterators is coherent and well-known amongst programmers. 

Unlike Python, Perl doesn't operate typed values or objects. 
It operates scalars, lists, hashes, typeglobs and refs including coderefs, which I will all together call whatnots.
Whatnots that are blessed and ```can('next')``` are considered iterators.
Arrayrefs, coderefs and iterators are considered iterables.
Under these terms everything else tries to be as pythonic as possible.
