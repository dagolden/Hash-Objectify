use 5.008001;
use strict;
use warnings;

package Objectify;

# ABSTRACT: Create objects from hashes on the fly
# VERSION

use Carp;
use Class::XSAccessor;
use Sub::Install;
use Scalar::Util qw/blessed/;

my %CACHE;
my $COUNTER = 0;

sub import {
  my ($class) = @_;
  my $caller = caller;

  Sub::Install::install_sub(
    {
      code => sub {
        my ( $ref, $package ) = @_;
        my $type = ref $ref;
        unless ( $type eq 'HASH' ) {
          $type
            = $type eq '' ? "a scalar value"
            : blessed($ref) ? "an object of class $type"
            :                 "a reference of type $type";
          croak "Error: Can't objectify $type";
        }
        if ( defined $package ) {
          no strict 'refs';
          @{ $package . '::ISA' } = 'Objectified'
            unless $package->isa('Objectified');
        }
        else {
          my ( $caller, undef, $line ) = caller;
          my $cachekey = join "", keys %$ref;
          if ( !defined $CACHE{$caller}{$line}{$cachekey} ) {
            no strict 'refs';
            $package = $CACHE{$caller}{$line}{$cachekey} = "Objectified::HASH$COUNTER";
            $COUNTER++;
            @{ $package . '::ISA' } = 'Objectified';
          }
          else {
            $package = $CACHE{$caller}{$line}{$cachekey};
          }
        }
        bless {%$ref}, $package;
      },
      into => $caller,
      as   => 'objectify',
    }
  );
}

package Objectified;

our $AUTOLOAD;

sub can {
  my ( $self, $key ) = @_;
  $self->$key; # install accessor if not installed
  return $self->SUPER::can($key);
}

sub AUTOLOAD {
  my $self   = shift;
  my $method = $AUTOLOAD;
  $method =~ s/.*:://;
  if ( ref $self && exists $self->{$method} ) {
    Class::XSAccessor->import(
      accessors => { $method => $method },
      class     => ref $self
    );
  }
  else {
    my $class = ref $self || $self;
    die qq{Can't locate object method "$method" via package "$class"};
  }
  return $self->$method(@_);
}

sub DESTROY { } # because we AUTOLOAD, we need this too

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Objectify;

  # turn a hash reference into an object with accessors
  
  $object = objectify { foo => 'bar', wibble => 'wobble' };
  print $object->foo;

  # objectify with a specific class name

  $object = objectify { foo => 'bar' }, "Foo::Response";
  print ref $object; # "Foo::Response"

=head1 DESCRIPTION

Objectify turns a hash reference into a simple object with accessors for each
of the keys.

One application of this module could be to create lightweight response objects
without the extra work of setting up an entire response class.

=head1 USAGE

=head2 objectify

  $object = objectify $hashref
  $object = objectify $hashref, $classname;

  $object->$key;          # accessor
  $object->$key($value);  # mutator

The C<objectify> function copies the hash reference (shallow copy), and blesses
it into the given classname.  If no classname is given, a meaningless,
generated package name is used instead.  In either case, the object will
inherit from the C<Objectified> class, which provides generates accessors on
demand for any key in the hash.

As an optimization, a generated classname will be the same for any given
C<objectify> call if the keys of the input are the same.  (This avoids
excessive accessor generation.)

The first time a method is called on the object, an accessor will be dynamically
generated if the key exists.  If the key does not exist, an exception is thrown.
Note: deleting a key I<after> calling it as an accessor will not cause subsequent
calls to throw an exception; the accessor will merely return undef.

Objectifying with a "real" classname that does anything other than inherit from
C<Objectify> may lead to surprising behaviors from method name conflict.  You
probably don't want to do that.

Objectifying anything other than an unblessed hash reference is an error.  This
is true even for objects based on blessed hash references, since the correct
semantics are not universally obvious.  If you really want C<Objectify> for
access to the keys of a blessed hash, you should make an explicit, shallow copy:

  my $copy = objectified {%$object};

=cut

# vim: ts=2 sts=2 sw=2 et:
