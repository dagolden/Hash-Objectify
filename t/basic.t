use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use Test::Fatal;

use Objectify;

can_ok("main", 'objectify');

my $obj = objectify { foo => 'bar', baz => 'bam' };

like( ref $obj, qr/Objectified/, "C<objectify HASHREF> returns object" );

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

my $obj2 = objectify foo => 'bar', baz => 'bam';

like( ref $obj2, qr/Objectified/, "C<objectify LIST> returns object" );

isnt( ref $obj, ref $obj2, "objectified objects from different spots are different classes" );

for my $key ( qw/foo baz/ ) {
  can_ok( $obj2, $key );
}

# XXX what should objectify $obj do?

done_testing;
# COPYRIGHT
