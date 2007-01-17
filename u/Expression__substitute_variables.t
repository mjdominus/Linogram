

use Test::More tests => 13;
use Environment;
use Expression;
use Name;

my $env = Environment->new(a => 1, b => 2, c => 3);

my $e1 = Expression->new('*', 
			 Expression->new('VAR', Name->new('a')),
			 Expression->new('VAR', Name->new('b')));
my $f1 = Expression->new('*', 
			 Expression->new('CON', 1),
			 Expression->new('CON', 2));

my $e2 = Expression->new('*', 
			 Expression->new('CON', 3),
			 Expression->new('VAR', Name->new('w')));
my $f2 = $e2;

my $e3 = Expression->new('+', $e1, $e2);
my $f3 = Expression->new('+', $f1, $f2);

my $e4 = Expression->new('TUPLE', { x => $e1, y => $e2, z => $e3 });
my $f4 = Expression->new('TUPLE', { x => $f1, y => $f2, z => $f3 });

my $e5 = Expression->new('*', 
			 Expression->new('CON', 3),
			 Expression->new('VAR', Name->new(['w', $e1])));
my $f5 = Expression->new('*', 
			 Expression->new('CON', 3),
			 Expression->new('VAR', Name->new(['w', $f1])));

my $e6 = Expression->new('FUN', 'sin', $e1);
my $f6 = Expression->new('FUN', 'sin', $f1);

for ([$e1, $f1], [$e2, $f2], [$e3, $f3], [$e4, $f4], [$e5, $f5],
     [$e6, $f6],) {
  my ($before, $after) = @$_;
  my $x = $before->copy;
  my $q = $x->substitute_variables(Environment->empty);
  is($q->to_str, $before->to_str, $before->to_str);

  $q = $x->substitute_variables($env);
  is($q->to_str, $after->to_str, $after->to_str);
}

{
  my $t2i = Expression->new('VAR', Name->new('t2', 'i'));

  my $e7 = Expression->new('-',
			   Expression->new('VAR',
					   Name->new('t2', ['e', $t2i], 'start')),
			   Expression->new('VAR',
					   Name->new('t2', ['v', $t2i])));
  my $c = Expression->new('CON', 3);
  my $f7 = Expression->new('-',
			   Expression->new('VAR',
					   Name->new('t2', ['e', $c], 'start')),
			   Expression->new('VAR',
					   Name->new('t2', ['v', $c])));


  my $env = Environment->new("t2.i", $c);
  my $res = $e7->copy->substitute_variables($env);
  
  is($res->to_str, $f7->to_str, $e7->to_str);
}
			 


