
use lib '../lib';
use Chunk;
use Expression;
sub C { Expression->new_constant(@_) }
use Test::More tests => 6;

{
  my $s = Type->new("snark");
  $s->add_param_default("n", C(3));
  $s->add_param_default("d", undef);

  ok($s->is_param("n"), "n is a param");
  ok($s->is_param("m"), "m is not a param");
  ok($s->is_param("d"), "d is a defaultless param");

  my $b = Type->new("boojum", $s);
  
  ok($s->is_param("n"), "extends: n is a param");
  ok($s->is_param("m"), "extends: m is not a param");
  ok($s->is_param("d"), "extends: d is a defaultless param");
}
 
