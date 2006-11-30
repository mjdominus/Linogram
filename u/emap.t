#!perl

use lib '../lib', '../lib/testutils';
use Expression;
use Test::More 'no_plan';
require 'exprs.pl';
require 'tuples.pl';

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

for my $i (0 .. $#tuples) {
  for my $t (@{$tuples[$i]}) {
    $COUNT = 0;
    $count->($t, \$COUNT);
    is($COUNT, $i*4-2);
  }
}

$count = Expression::emap('count',
                          { DEFAULT => sub { my ($u, $e, $op, @v) = @_;
                                             my $t = 1; $t += $_ for @v; $t },
                            CON => sub { return 1 },
                            VAR => sub { return 1 },
                            STR => sub { return 1 },
                          },
                         );

for (1..10) {
  for my $e (@{$expr[$_]}) {
    my $COUNT = $count->($e);
    is($COUNT, $_*2-1);
  }
}

print STDERR ">>>>> $#tuples\n";
for my $i (0 .. $#tuples) {
  for my $t (@{$tuples[$i]}) {
    my $COUNT = $count->($t, \$COUNT);
    is($COUNT, $i*4-2);
  }
}


