
use lib '../lib';
use Chunk;
use Name;
use Value;
use Test::More tests => 4;

my $s = Type->new("snark");
$s->add_param_default(Name->new('p'), Expression->new_constant(13));
my %sp = $s->my_subchunks;
is_deeply(\%sp, { }, "snark");

my $b = Type->new("boojum");
$b->add_subchunk('s', $s);
my %bp = $b->my_subchunks;
is_deeply(\%bp, { s => $s }, "single nested param");

my $a = Type->new("greatboojum");
$a->add_subchunk('b', $b);
my %ap = $a->my_subchunks;
is_deeply(\%ap, { 'b' => $b }, "double nested param");

my $f = Type->new("foojum");
$f->add_subchunk('s', $s, 2);
my %fp = $f->my_subchunks;
is_deeply(\%fp, { "s" => $s }, "single nested param array");

