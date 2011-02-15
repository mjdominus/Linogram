
use lib '../lib';
use Chunk;
use Name;
use Value;
use Test::More tests => 10;

my $s = Type->new("snark");
$s->add_param_default(Name->new('p'), Expression->new_constant(13));
is_deeply([$s->my_subchunks], [], "snark");
is_deeply([$s->all_leaf_subchunks], [], "snark");

my $N = Type::Scalar->new();
$s->add_subchunk('n', $N);
is_deeply([$s->my_subchunks], [ n => $N ], "snark");
is_deeply([$s->all_leaf_subchunks], [ "n" ], "snark");

my $b = Type->new("boojum");
$b->add_subchunk('s', $s);
is_deeply([$b->my_subchunks], [ s => $s ], "single nested param");
is_deeply([$b->all_leaf_subchunks], [ "s.n" ], "single nested param");

my $a = Type->new("greatboojum");
$a->add_subchunk('b', $b);
is_deeply([$a->my_subchunks], [ 'b' => $b ], "double nested param");
is_deeply([$a->all_leaf_subchunks], [ "b.s.n" ], "double nested param");

my $f = Type->new("foojum");
$f->add_subchunk('s', $s, 2);
is_deeply([$f->my_subchunks], [ "s" => $s ], "single nested param array");
is_deeply([$f->all_leaf_subchunks], [ "s.n" ], "single nested param array");

