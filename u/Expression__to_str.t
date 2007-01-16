

use Test::More tests => 8;
use lib '../lib', '../lib/testutils';
use Environment;
use Expression;
require 'exprs.pl';

my $env = Environment->new(a => 1, b => 2, c => 3);

my ($e1, $e2, $e3) = ($expr[2][2], $expr[2][3], $expr[3][2]);
my $a_sub_i = 
  Expression->new_var(Name->new(["a", 
                                 Expression->new_var(Name->new("i"))
                                ]));

my @tests = 
  ([$e1, "(e * d)"],
   [$e2, "(5 / g)"],
   [$e3, "(f / (b + 2))"],
   [Expression->new('-', $e1, $expr[1][5]), "((e * d) - f)"],
   [Expression->new('TUPLE', { x => $e1, y => $e2  }),
    "{ (e * d), (5 / g) }"],
   [Expression->new('TUPLE', { x => $e1, y => $e2, z => $e3 }),
    "{ (e * d), (5 / g), (f / (b + 2)) }"],
   [Expression->new('TUPLE', { x => $e1, y => $e2, w => $e3 }),
    "{ w => (f / (b + 2)), x => (e * d), y => (5 / g) }"],
   [Expression->new("FUN", "sin", 
                    Expression->new("+", $a_sub_i,
                                    Expression->new_constant(12))),
   "sin(a[i] + 12)"],
  );

for my $t (@tests) {
  my ($e, $x) = @$t;
#  use Data::Dumper;
#  print Data::Dumper::Dumper($e);
  is($e->to_str, $x, $x);
}
