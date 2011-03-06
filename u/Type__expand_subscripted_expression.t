
use lib '../lib';
use Type;
use Type::Scalar;
use Expression;
use Environment;
use Test::More tests=> 4;

my $a_sub_i = 
  Expression->new_var(Name->new(["a", 
                                 Expression->new_var(Name->new("i"))
                                ]));

my $a_type = Type::Scalar->new("number");
my $t = Type->new("demo type 1");
$t->add_subchunk("a", $a_type, Expression->new_constant(3));

my @c = $t->expand_subscripted_expression($a_sub_i, Environment->empty);

is(scalar(@c), 3, "three expressions");
for (0..2) {
  is($c[$_]->to_str, "a[$_]", "a[$_]?");
}
