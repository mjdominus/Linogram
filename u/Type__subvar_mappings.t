
use lib '../lib';
use Type;
use Type::Scalar;
use Expression;
use Environment;

use Test::More tests=> 8;

my $mt = Environment->empty;

sub CON { Expression->new_constant(@_) }

my $a_sub_i = 
  Expression->new_var(Name->new(["a", 
                                 Expression->new_var(Name->new("i"))
                                ]));

{ my $a_type = Type::Scalar->new("number");
  my $t = Type->new("demo type 1");
  $t->add_subchunk("a", $a_type, CON(37));
  
  my %h = $t->subvar_mappings($a_sub_i, $mt);

  is(scalar(keys %h), 1, "one key");
  my ($k, $v) = each %h;
  is($k, "i", "key is subvar i");
  is_deeply($v, [0, 36, 'CLOSED']);
}

{
  my $x_type = Type::Scalar->new("number");
  my $a_type = Type::Scalar->new("number");
  my $t = Type->new("demo type 2");
  $t->add_subchunk("a", $a_type, CON(37)); # array
  $t->add_subchunk("x", $x_type);     # scalar

  my $sin_of_x = Expression->new("FUN", "sin", 
                                 Expression->new_var("x"));

  my $sin_of_0 = Expression->new("FUN", "sin", 
                                 Expression->new_constant(0));

  # sin(a[i] + 12)
  my $sin_of_sum = 
    Expression->new("FUN", "sin", 
                    Expression->new("+", $a_sub_i,
                                    Expression->new_constant(12)));

  
  { my %h = $t->subvar_mappings($sin_of_x, $mt);
    is(scalar(keys %h), 0, "no keys");
  }

  { my %h = $t->subvar_mappings($sin_of_0, $mt);
    is(scalar(keys %h), 0, "no keys");
  }

  { my %h = $t->subvar_mappings($sin_of_sum, $mt);
    is(scalar(keys %h), 1, "one key");
    my ($k, $v) = each %h;
    is($k, "i", "key is subvar i");
    is_deeply($v, [0, 36, 'CLOSED']);
  }
}




