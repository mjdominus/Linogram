#!perl

BEGIN {$N = 100}                # N tests
use lib '../lib';
use Chunk;
use Expression;
BEGIN { *emap = \&Expression::emap }
use Test::More tests => $N;
use lib '../lib/testutils';
require 'exprs.pl';

# $uses->($expr, [$var])
# Return true if expression uses specified variable
#
my $uses = emap 'uses',  { DEFAULT => sub {
    my ($u, $expr, $op, @v) = @_;
    my ($var, $yep) = @$u;
    for (@v) { return 1 if $_ }
    return 1 if $yep;
    if ($expr->[0] eq "VAR" && $expr->[1] eq $var) {
        return $u->[1] = 1;
    }
    return 0;
} };

# $vars->($expr) 
# return list of vars in the expression
#
sub uniq {
  my %h;
  $h{$_}++ for @{$_[0]};
  wantarray ? sort keys %h : keys %h;
}

# Try out the $vars function; eyeballing seems to make it OK
#
#for my $n (1..10) {
#  for my $expr (@{$expr[$n]}) {
#    my @vars = uniq($vars->($expr));
#    print "# ", $expr->to_str, ":\t@vars\n";
#  }
#}



# given a relation and a topsort of the variables, check to see 
# if it's correct
#
# go through the vars in order.
# make sure the definition of each one is devoid of the others
#
# scan over the variables in order and make sure
# that no "seen" variable appears in the current expression,
# then add the current variable to "seen".
sub tsort_ok {
    my ($rel, @t) = @_;
    my %done;
    for my $var (@t) {
      if (exists $rel->{$var}) {
        my $expr = $rel->{$var};
        for my $var2 ($t) {
          next if $done{$t}; # OK for $expr to use this now
          return 0 if $uses->($expr, [$var2]);
        }
      }
      $done{$var} = 1;
    }
    return 1;
}

sub randelt { $_[rand @_] }

# idea: take some expressions and assign them at random to variables.
# do the tsort.  if there's a cycle, skip the test.
srand 4;
for (1..$N) {
  my %env;
  my $nvars = int(1 + rand(7));
  for (1 .. $nvars) {
    my $v = chr(ord('a') + rand(7));
    redo if exists $env{$v};
    my $size = int(1+rand(10));
    $env{$v} = randelt(@{$expr[$size]});
  }
  my $env = Environment->new(%env);
  my @order = $env->tsort;
  redo unless @order;
  ok(tsort_ok($env, @order));
  1;
}

# Add some tests for cycles
