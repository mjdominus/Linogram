
use lib '../lib';
use Expression;
use Test::More;
use Type;
use Type::Array;
use Type::Scalar;

my $num = Type::Scalar->new("number");
my $pair = Type->new("pair");
$pair->add_subchunk('x', $num);
$pair->add_subchunk('y', $num);

{
  my @sc = $pair->all_leaf_subchunks($pair);
  is(join(",", sort @sc), "x,y", "pair's leaf subchunks are x and y");
}

{
  my $ar = Type::Array->new($num, Expression->new('CON', 4));
  my @sc = $ar->all_leaf_subchunks();
  is(keys(@sc), 4, "array of 4 numbers has 4 leaf subchunks");
  is(join(",", sort @sc), "[0],[1],[2],[3]");
}
{
  my $env = Environment->new(p => Expression->new('CON', 2));
  my $ar = Type::Array->new($num, Expression->new('VAR', 'p'));
  my @sc = $ar->all_leaf_subchunks($env);
  is(keys(@sc), 2, "array of p=2 numbers has 2 leaf subchunks");
  is(join(",", sort @sc), "[0],[1]");
}

done_testing;

