

use Test::More tests => 8;
use lib '../lib', '../lib/testutils';
use lib 'lib', 'lib/testutils';
use Environment;
use Expression;
require 'exprs.pl';

my $t1;

for ([Expression->new_constant(21), Expression->new_constant(21)],
     [$expr[2][1], Expression->new_constant(10)], 
     [$expr[2][9], Expression->new_constant(7)], 
     [$expr[3][0], Expression->new_constant(0)], 
     [$expr[3][6], Expression->new_constant(7)], 
     [$expr[3][3], $t1 = Expression->new('/', 
					 Expression->new('VAR', 'd'),
					 Expression->new_constant(0))],
     [$expr[4][0], Expression->new('-', 
				   Expression->new('/',
						   Expression->new('CON', 4),
						   Expression->new('VAR', 'e')
						  ),
				   Expression->new_constant(3))],
     [Expression->new("TUPLE", { x => $expr[2][1],
				y => $expr[3][3],
			      }),
      Expression->new("TUPLE", { x => Expression->new_constant(10),
				 y => $t1,
			       })],
) {
  my ($before, $after) = @$_;
  my $q = $before->fold_constants;
  is($q->to_str, $after->to_str, $before->to_str . " = " . $after->to_str);
}

