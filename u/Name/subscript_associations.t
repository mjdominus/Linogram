
use Test::More tests => 18;

use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
require 'names.pl';  
use Name;
use Expression;

my @results = 
  ([], [], [[$names[0], $parts{ni}]],
   [], [], [[$names[3], $parts{ni}]],
   [], [], [[$names[6], $parts{ni}]],
   [], [], [[$names[9], $parts{ni}]],
   [[$names[0], $parts{nbi}]],
   [[$names[3], $parts{nbi}]],
   [[$names[6], $parts{nbi}]],
   [], [], [[$names[15], $parts{nbi}]],
  );

for my $n (@names) {
  my @s = $n->subscript_associations;
  is_deeply(\@s, shift(@results), $n->to_str);
}

