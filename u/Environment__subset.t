
use lib "../lib";
use Environment;
use Name;

use Test::More tests => 19;

{
  my $name = Name->new("foo", "x");

  my $env = Environment->new("foo" => 3,
			     "foo.x" => 4,
			     "foo.x.y" => 5,
			     "foo.x.y.z" => 10,
			     "foo.xardoz" => 9,
			     "bar" => 6,
			     "bar.x" => 7,
			     "bar.x.y" => 8,
			  );

  my $sub = $env->subset($name);

  is(scalar (keys %$sub), 2, "two keys");
  for my $n ("y", "y.z") {
    ok($sub->has_var($n), "has $n");
    is($sub->lookup($n), $env->lookup("foo.x.$n"), "values match");
  }
}

use Expression;
{
  my $env = Environment->new("foo" => 3,
			     "foo[3].x" => 4,
			     "foo[3].x.y" => 5,
			     "foo[3].x.y.z" => 10,
			     "foo[3].xardoz" => 9,
			     "foo[4].x" => 11,
			     "foo[4].x.y" => 12,
			     "foo[4].x.y.z" => 13,
			     "foo[4].xardoz" => 14,
			     "bar" => 6,
			     "bar.x" => 7,
			     "bar.x.y" => 8,
			  );

  {
    my $name = Name->new(["foo", Expression->new_constant(3)]);
    my $sub = $env->subset($name);

    is(scalar (keys %$sub), 4, "four keys");
    for my $n ("x", "x.y", "x.y.z", "xardoz") {
      ok($sub->has_var($n), "has $n");
      is($sub->lookup($n), $env->lookup("foo[3].$n"), "values match");
    }
  }

  {
    my $name = Name->new(["foo", Expression->new_constant(3)], "x");
    my $sub = $env->subset($name);

    is(scalar (keys %$sub), 2, "two keys");
    for my $n ("y", "y.z") {
      ok($sub->has_var($n), "has $n");
      is($sub->lookup($n), $env->lookup("foo[3].x.$n"), "values match");
    }
  }

}


