
use lib '../lib';
use Chunk;
use Expression;
sub C { Expression->new_constant(@_) }
use Name;
sub N { Name->new(@_) }
use Test::More tests => 6;

{
  my $s = Type->new("snark");
  $s->add_param_default(N("n"), C(3));
  $s->add_param_default(N("d"), undef);

  ok($s->is_param(N("n")), "n is a param");
  ok(! $s->is_param(N("m")), "m is not a param");
  ok($s->is_param(N("d")), "d is a defaultless param");

  my $b = Type->new("boojum", $s);
  
  ok($b->is_param(N("n")), "extends: n is a param");
  ok(! $b->is_param(N("m")), "extends: m is not a param");
  ok($b->is_param(N("d")), "extends: d is a defaultless param");
}
 
