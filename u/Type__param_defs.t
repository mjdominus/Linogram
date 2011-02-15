
use lib '../lib';
use Chunk;
use Name;
use Value;
use Test::More tests => 3;

my $s = Type->new("snark");
$s->add_param_default(Name->new('p'), Expression->new_constant(13));
my $sp = $s->param_defs;
is($sp->to_str, "ENV { p => 13 }", "single param");

my $b = Type->new("boojum");
$b->add_subchunk(Name->new('s'), $s);
my $bp = $b->param_defs;
is($bp->to_str, "ENV { s.p => 13 }", "single nested param");

my $f = Type->new("foojum");
$f->add_subchunk(Name->new('s'), $s, 2);
my $fp = $f->param_defs;
is($fp->to_str, "ENV { s.p => 13 }", "array of nested param");
