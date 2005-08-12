#!perl

use lib '../lib', '../lib/testutils';
use Expression;
use Test::More 'no_plan';
require 'exprs.pl';

my $COUNT;
my $count = Expression::emap('count', 
                             { DEFAULT => sub { my ($sref) = $_[0]; ++$$sref } }
                            );

for (1..10) {
  for my $e (@{$expr[$_]}) {
    $COUNT = 0;
    $count->($e, \$COUNT);
    is($COUNT, $_*2-1);
  }
}

$count = Expression::emap('count',
                          { DEFAULT => sub { my ($u, $e, $op, @v) = @_;
                                             my $t = 1; $t += $_ for @v; $t }},
                          );

for (1..10) {
  for my $e (@{$expr[$_]}) {
    my $COUNT = $count->($e);
    is($COUNT, $_*2-1);
  }
}
