use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use Test::Fatal;

use Objectify;

can_ok("main", 'objectify');

my $obj = objectify { foo => 'bar', baz => 'bam' };

like( ref $obj, qr/Objectified/, "C<objectify HASH> returns object" );

is( $obj->foo, 'bar', "foo accessor reads" );
$obj->foo("wibble");
is( $obj->foo, 'wibble', "foo accessor writes" );

for my $key ( qw/foo baz/ ) {
  can_ok( $obj, $key );
}

like(
  exception { $obj->badkey },
  qr/Can't locate.*badkey/,
  "unknown accessor throws exception"
);


done_testing;
# COPYRIGHT
