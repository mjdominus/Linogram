
use Test::More tests => 12;

use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
use vars '@names';
require 'names.pl';
use Name;
use Expression;

for my $i (0 .. 11) {
  my $n = $names[$i];
  my $copy = $n->copy;
  is_deeply($copy, $n, $n->to_str);
}

