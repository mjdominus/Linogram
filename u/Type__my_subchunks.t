
use lib '../lib';
use Expression;
use Test::More;
use Type;
use Type::Array;
use Type::Scalar;

my $num = Type::Scalar->new("number");
{
  my $ar = Type::Array->new($num, Expression->new('CON', 4));
  my %sc = $ar->my_subchunks();
  is(keys(%sc), 4, "array of 4 numbers has 4 subchunks");
}
{
  my $env = Environment->new(p => Expression->new('CON', 2));
  my $ar = Type::Array->new($num, Expression->new('VAR', 'p'));
  my %sc = $ar->my_subchunks($env);
  is(keys(%sc), 2, "array of p=2 numbers has 2 subchunks");
}

done_testing;

