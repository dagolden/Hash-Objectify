use 5.008001;
use strict;
use warnings;

package Objectify;
# ABSTRACT: Create objects from hashes on the fly
# VERSION

use Sub::Install;

sub import {
  my ($class) = @_;
  my ($caller, $file, $line) = caller;

  Sub::Install::install_sub({
    code => sub { bless $_[0], 'Objectified::HASH' },
    into => $caller,
    as   => 'objectify',
  });
}

package Objectified;

sub can {
  return ref $_[0] && exists $_[0]->{$_[1]};
}

sub AUTOLOAD {
  
}

package Objectified::HASH;
our @ISA = qw/Objectified/;

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
