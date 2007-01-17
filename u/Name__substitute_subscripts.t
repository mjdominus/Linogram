use lib '../lib', '../lib/testutils';
use lib './lib', './lib/testutils';
use vars '@names';
require 'names.pl';

use Test::More tests => 18;

use Environment;
my $env = Environment->new(i => 4, j => 3, 
		'b.i' => 5, 'b.j' => 6
	);

for my $i (0 .. 17) {
  my $b = $names[$i];
  my $a = $b->substitute_subscripts($env);
  my $bstr = $b->to_str;
  my $astr = $a->to_str;
  my $xstr = $bstr;
  $xstr =~ s/b\.i/5/g;
  $xstr =~ s/b\.j/6/g;
  $xstr =~ s/i/4/g;
  $xstr =~ s/j/3/g;
  is($astr, $xstr, $bstr);
}

