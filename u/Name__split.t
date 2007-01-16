
use Test::More tests => 4;

use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
use vars '@names';
require 'names.pl';
use Name;
use Expression;

my $c12 = Expression->new('CON', 12);
my $vi  = Expression->new('VAR', my $ni = Name->new("i"));
my @x = (Name->new("x"), 
         Name->new(["x", $c12]), 
         Name->new(["x", $vi]), 
        );

my @res = (undef, $x[0], $x[1], $x[2]);

sub str {
  $_[0] ? $_[0]->to_str : "UNDEF";
}

for my $i (0..11) {
  my $n = $names[$i];
  my ($f, $a) = $n->split;
  next unless $f eq "fred";
  my $x = shift @res;
  is_deeply($a, $x, str($a) . " is " . str($x));
}

