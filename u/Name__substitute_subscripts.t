use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
use vars '@names';
require 'names.pl';

use Test::More tests => 12;

use Environment;
my $env = Environment->new(i => 4, j => 3);

for my $i (0 .. 11) {
  my $b = $names[$i];
  my $a = $b->substitute_subscripts($env);
  my $bstr = $b->to_str;
  my $astr = $a->to_str;
  my $xstr = $bstr;
  $xstr =~ s/i/4/g;
  $xstr =~ s/j/3/g;
  is($astr, $xstr, $bstr);
}

