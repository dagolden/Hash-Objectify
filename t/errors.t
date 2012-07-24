use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use Test::Fatal;

use Hash::Objectify;

my $obj1 = bless {}, "Foo";

like(
  exception { objectify $obj1 },
  qr/Error: Can't objectify an object of class Foo/,
  "C<objectify OBJECT> is fatal"
);

like(
  exception { objectify [] },
  qr/Error: Can't objectify a reference of type ARRAY/,
  "C<objectify ARRAYREF> is fatal"
);

like(
  exception { objectify "Bar" },
  qr/Error: Can't objectify a scalar value/,
  "C<objectify SCALAR> is fatal"
);

done_testing;
# COPYRIGHT
