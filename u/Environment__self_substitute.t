#!perl

use Test::More tests => 40;
use lib 'lib', '../lib';
use Expression;
use Environment;

sub V { Expression->new_var(Name->new(@_)) }
sub C { Expression->new_constant(@_) }

{
  for my $tsort ([qw(a b)], [qw(b a)]) {
    my ($a, $b) = @$tsort;
    my $n = int(rand(10));
    my $e = Environment->new($a => V($b),
			     $b => C($n),);
    $e->self_substitute();
    is($e->lookup('a')->to_str, $n, "[@$tsort] a=$n");
    is($e->lookup('b')->to_str, $n, "[@$tsort] b=$n");
  }
}

{
  for my $tsort ([qw(a b c)], [qw(a c b)], [qw(b a c)], 
		 [qw(b c a)], [qw(c a b)], [qw(c b a)]) {
    my ($a, $b, $c) = @$tsort;
    my $n = int(rand(10));
    my $e = Environment->new($a => V($b),
			     $b => V($c),
			     $c => C($n),);
    $e->self_substitute();
    is($e->lookup('a')->to_str, $n, "[@$tsort] a=$n");
    is($e->lookup('b')->to_str, $n, "[@$tsort] b=$n");
    is($e->lookup('c')->to_str, $n, "[@$tsort] c=$n");
  }
}

# Test compound expresisons and constant folding
{
  for my $tsort ([qw(a b c)], [qw(a c b)], [qw(b a c)], 
		 [qw(b c a)], [qw(c a b)], [qw(c b a)]) {
    my ($a, $b, $c) = @$tsort;
    my $n = int(rand(10));
    my $e = Environment->new($a => Expression->new('+', V($b), V($c)),
			     $b => Expression->new('+', V($c), C(1)),
			     $c => C($n),);
    $e->self_substitute();
    is($e->lookup($a)->fold_constants->to_str, 2*$n+1, "[@$tsort] a=$n");
    is($e->lookup($b)->fold_constants->to_str, $n+1, "[@$tsort] b=$n");
    is($e->lookup($c)->fold_constants->to_str, $n, "[@$tsort] c=$n");
  }
}

