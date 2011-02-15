
use lib '../lib';
use Chunk;
use Name;
use Value;
use Test::More tests => 1;
use strict;
use warnings;

my $snark = Type->new("snark");
$snark->add_param_default(Name->new('p'), Expression->new_constant(13));

my $boojum = Type->new("boojum");
$boojum->add_subchunk(Name->new('s'), $snark, 2);

my $bp = $boojum->param_defs;
is($bp->to_str, "ENV { s[0].p => 13, s[1].p => 13 }", "array param");

