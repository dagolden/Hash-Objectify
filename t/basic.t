use 5.006;
use strict;
use warnings;
use Test::More 0.96;

use Objectify;

can_ok("main", 'objectify');

my $obj = objectify { foo => 'bar', baz => 'bam' };

like( ref $obj, qr/Objectified/, "C<objectify HASH> returns object" );

done_testing;
# COPYRIGHT
