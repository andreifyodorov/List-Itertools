# List-Itertools
## Python itertools in Perl

Unlike other languages Perl doesn't operate typed values or objects. 
It operates scalars, lists, hashes, globs, code and refs, which I will colloboratively call whatnots.
Whatnots that are blessed and ```can('next')``` are considered iterators.
Arrayrefs and iterators are considered iterables.
Everything else tries to be as pytonic as possible.