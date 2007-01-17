
# If there are N items in names.pl, then there should be
# N * (N+2) tests here.  e.g. if 12 names in names.pl, then 168 tests.
use Test::More tests => 360;
use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
require 'names.pl';

use Expression;
my @vars = map Expression->new("VAR", $_), @names;
my @svars = map [$_->all_subscript_associations], @names;


for my $i (0 .. $#names) {
  for my $j (0 .. $#names) {
    my $op = (qw(+ - * /))[($i + $j) % 4];
    my $exp = Expression->new($op, $vars[$i], $vars[$j]);
    my $sa = $exp->subscript_associations;
    matches($sa, union($svars[$i], $svars[$j]), $exp->to_str);
  }
}

my $c34 = Expression->new("CON", 34);
for my $i (0 .. $#names) {
  for my $rev (0 .. 1) {
    my $op = (qw(+ - * /))[($i*2+$rev) % 4];
    my $exp = $rev ? Expression->new($op, $vars[$i], $c34) 
                   : Expression->new($op, $c34, $vars[$i]);
    my $sa = $exp->subscript_associations;
    matches($sa, $svars[$i], $exp->to_str);
  }
}

# arguments are arrays of [x, y] pairs
# merge the arrays, perhaps eliminating duplicates
sub union {
  [map @$_, @_];
}

# $a and $x are arrayrefs; each is an array of [a, b] pairs
# each represents a SET of such pairs.
sub matches {
  my ($a, $x, $msg) = @_;
  my %x;
  my $BAD = 0;
  my @apair_used;
 XPAIR:
  for my $xpair (@$x) {
    for my $i (0 .. $#$a) {
      if (pairmatch($a->[$i], $xpair)) {
        $apair_used[$i] = 1;
        next XPAIR;
      }
    }
    my ($x0, $x1) = ($xpair->[0]->to_str, $xpair->[1]->to_str);
    warn "# [$x0, $x1] missing from output\n";
    $BAD++;
  }

 APAIR_I:
  for my $i (0 .. $#$a) {
    next if $apair_used[$i];
    for my $j (0 .. $i-1) {
      next APAIR_I if pairmatch($a->[$i], $a->[$j]);
    }
    my ($a0, $a1) = ($a->[$i][0]->to_str, $a->[$i][1]->to_str);
    warn "# [$a0, $a1] appears in output, why?\n";
    $BAD++;
  }

  ok($BAD == 0, $msg);
}


sub pairmatch {
  my ($x, $a) = @_;
  ref($x) eq "ARRAY" or die;
  ref($a) eq "ARRAY" or die;
  @$x == 2 or die;
  @$a == 2 or die;
  $x->[0]->to_str eq $a->[0]->to_str
  and
  $x->[1]->to_str eq $a->[1]->to_str;
}

