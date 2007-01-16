

use Test::More tests => 27;
use lib '../lib', '../lib/testutils';
use lib 'lib', 'lib/testutils';
use Name;
use Chunk;
use Expression;
sub CON { Expression->new_constant(@_) }

use Environment;
my $mt = Environment->empty;

my $number = Type::Scalar->new("number");
my $t = Type->new("snark");
$t->add_subchunk("four", $number, CON(4));
$t->add_subchunk("three", $number, CON(3));
$t->set_closure("CLOSED");

my $b = Type->new("boojum");
$b->add_subchunk("s", $t);

for my $j (-2..6) {
  {
    my $n = Name->new(["four", Expression->new_constant($j)])
      ->reduce_subscripts($t, $mt);

    my $jm4 = $j % 4;
    my $a = $n && $n->to_str;
    is($a,
       "four[$jm4]",
       "CLOSED [$j] => four[$jm4]");
  }

  {
    my $n = Name->new("s", ["four", CON($j)])
                ->reduce_subscripts($b, $mt);
    my $jm4 = $j % 4;
    my $a = $n && $n->to_str;
    is($a,
       "s.four[$jm4]",
       "CLOSED [$j] => s.four[$jm4]");
  }

}


$t->set_closure("OPEN");

for my $j (-2..6) {
  my $n = Name->new(["four", CON($j)])
              ->reduce_subscripts($t, $mt);
  my $a = $n && $n->to_str;
  my $x = 0 <= $j && $j < 4 ? "four[$j]" : undef;

  is($a, $x, "OPEN [$j] => " . ($x || "undef"));
}

