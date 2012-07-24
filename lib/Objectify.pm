use 5.008001;
use strict;
use warnings;

package Objectify;
# ABSTRACT: Create objects from hashes on the fly
# VERSION

use Class::XSAccessor;
use Sub::Install;

my %CACHE;
my $COUNTER = 0;

sub import {
  my ($class) = @_;
  my $caller = caller;

  Sub::Install::install_sub({
    code => sub {
      my $hr = ref $_[0] eq 'HASH' ? $_[0] : { @_ };
      my ($caller, undef, $line) = caller;
      my $cachekey = join "", keys %$hr;
      if ( ! defined $CACHE{$caller}{$line}{$cachekey} ) {
        my $package = $CACHE{$caller}{$line}{$cachekey} = "Objectified::HASH$COUNTER";
        $COUNTER++;
        no strict 'refs';
        @{$package . '::ISA'} = 'Objectified';
      }
      bless $hr, $CACHE{$caller}{$line}{$cachekey};
    },
    into => $caller,
    as   => 'objectify',
  });
}

package Objectified;

our $AUTOLOAD;

sub can {
  my ($self, $key) = @_;
  $self->$key; # install accessor if not installed
  return $self->SUPER::can($key);
}

sub AUTOLOAD {
  my $self = shift;
  my $method = $AUTOLOAD;
  $method =~ s/.*:://;
  if ( ref $self && exists $self->{$method} ) {
    Class::XSAccessor->import(
      accessors => { $method => $method },
      class => ref $self
    );
  }
  else {
    my $class = ref $self || $self;
    die qq{Can't locate object method "$method" via package "$class"};
  }
  return $self->$method(@_);
}

sub DESTROY {} # because we AUTOLOAD, we need this too

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Objectify;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=2 sts=2 sw=2 et:
