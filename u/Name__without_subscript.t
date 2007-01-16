
use Test::More tests => 12;

use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
require 'names.pl';
use Name;
use Expression;

my @results = 
  ($names[0], $names[0], $names[0],
   $names[3], $names[3], $names[3],
   $names[6], $names[6], $names[6],
   $names[9], $names[9], $names[9],
  );

for my $i (0 .. 11) {
  my $ws = $names[$i]->without_subscript;
  is_deeply($ws, $results[$i], $names[$i]->to_str . " => " . $ws->to_str);
}

