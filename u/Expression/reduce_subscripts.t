

use Test::More tests => 32;
use lib '../lib', '../lib/testutils';
use lib 'lib', 'lib/testutils';
use Expression;
use Name;
use Chunk;

sub CON { Expression->new_constant(@_) }

my $number = Type::Scalar->new("number");
my $t = Type->new("snark");
$t->add_subchunk("four", $number, CON(4));
$t->add_subchunk("three", $number, CON(3));
$t->set_closure("CLOSED");

sub elt {
  my $i = shift;
  Expression->new_var(Name->new(["four", CON($i)]));
}

use Environment;
my $mt = Environment->empty;

for my $j (-2..6) {
    my $expr = elt($j);
    my $jm4 = $j % 4;
    my $a = $expr->reduce_subscripts([$t, $mt]);
    isa_ok($a, "Expression", "CLOSED [$j]");
    is($a->to_str, 
       "four[$jm4]", 
       "CLOSED [$j] => four[$jm4]");
}

{
  my $tupl = Expression->new("TUPLE",
                             { 'x' => elt(-2),
                               'y' => elt(1),
                               'z' => elt(5),
                             },
                            );
  my $x = Expression->new("TUPLE",
                          { 'x' => elt(2),
                            'y' => elt(1),
                            'z' => elt(1),
                          },
                         );
  my $a = $tupl->reduce_subscripts([$t, $mt]);
  is_deeply($a, $x, "CLOSED tuple reduction");
}


$t->set_closure("OPEN");

for my $j (-2..6) {
  my $expr = elt($j)->reduce_subscripts([$t, $mt]);

  my $a = $expr && $expr->to_str;
  my $x = 0 <= $j && $j < 4 ? "four[$j]" : undef;
  if ($x) {
    isa_ok($expr, "Expression", "OPEN [$j]");
  }

  is($a, $x, "OPEN [$j] => " . ($x||"undef"));
}

