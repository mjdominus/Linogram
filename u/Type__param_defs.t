
use lib '../lib';
use Type;
use Expression;
use Environment;
use Type;
use Type::Array;
use Type::Scalar;

use Test::More;

my $num = Type::Scalar->new("number");
my $top = Type->new("top");
$top->add_subchunk('x', $num);
$top->add_subchunk('y', $num);
$top->add_param_default(Name->new('a3'), Expression->new_constant(3));

my $mid1 = Type->new("mid1", $top);
my $mid2 = Type->new("mid2", $top);
$mid2->add_param_default(Name->new('b6'), Expression->new_constant(6));

{
  my $e = $top->param_defs;
  is(join(",", sort keys %$e), "a3", "top type has param a3");
}
{
  my $e = $mid1->param_defs;
  is(join(",", sort keys %$e), "a3", "inheriting type 1 has param a3");
}
{
  my $e = $mid2->param_defs;
  is(join(",", sort keys %$e), "a3,b6", "inheriting type 2 has params a3 and b6");
}

done_testing;



