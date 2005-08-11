
package Value;
use Carp 'croak';
use strict;

my %op = ("add" => 
	  {
           "CHUNK,CHUNK"     => 'add_chunks',
           "CHUNK,CONSTANT"   => 'add_chunk_con',
           "CHUNK,TUPLE"      => 'add_chunk_tuple',
           "TUPLE,TUPLE"       => 'add_tuples',
           "TUPLE,CONSTANT"    => undef,
           "CONSTANT,CONSTANT" => 'add_constants',
           "STRING,STRING"     => 'concat_strings',
	   NAME => "Addition",
          },
	  "mul" => 
	  {
	   NAME => "Multiplication",
	   "CHUNK,CONSTANT"   => 'mul_chunk_con',
           "TUPLE,CONSTANT" => 'mul_tuple_con',
           "CONSTANT,CONSTANT" => 'mul_constants',
	  },
	 );

sub kindof { $_[0]->{WHAT} }

sub negate { $_[0]->scale(-1) }
sub reciprocal { die "Nonlinear division" }

sub add { $_[0]->op("add", $_[1]) }
sub sub { $_[0]->op("add", $_[1]->negate) }
sub mul { $_[0]->op("mul", $_[1]) }
sub div { $_[0]->op("mul", $_[1]->reciprocal) }

sub op {
  my ($self, $op, $operand) = @_;
  my ($k1, $k2) = ($self->kindof, $operand->kindof);
  my $method;
  if ($method = $op{$op}{"$k1,$k2"}) {
    $self->$method($operand);
  } elsif ($method = $op{$op}{"$k2,$k1"}) {
    $operand->$method($self);
  } else {
    my $name = $op{$op}{NAME} || "'$op'";
    die "$name of '$k1' and '$k2' not defined";
  }
}

################################################################


package Expression; 

my %eval_op = ( '+' => sub { $_[0] + $_[1] },
		'-' => sub { $_[0] - $_[1] },
		'*' => sub { $_[0] * $_[1] },
		'/' => sub { $_[0] / $_[1] },
		'CON' => "special case",
		'VAR' => "special case",
		'FUN' => "special case",
		'STR' => "special case",
		'TUPLE' => "special case",
	      );

sub new {
  my ($base, $op, @args) = @_;
  my $class = ref $base || $base;
  unless (exists $eval_op{$op}) {
    die "Unknown operator '$op' in expression '$op @args'\n";
  }
  bless [ $op, @args ] => $class;
}

sub new_constant {
  my ($base, $val) = @_;
  $base->new('CON', $val);
}

sub new_string {
  my ($base, $val) = @_;
  $base->new('STR', $val);
}

sub new_var {
  my ($base, $name) = @_;
  $base->new('VAR', $name);
}

sub is_constant { $_[0][0] eq "CON" }
sub value { $_[0][1] }

sub emap {
  my ($name, $d) = @_;
  my $f;
  $f = sub {
    my ($expr, $u) = @_;
    my ($op, @s) = @$expr;
    my $action = (exists $eval_op{$op} ? $d->{$op} : $d->{UNKNOWN})
              || $d->{DEFAULT};
    unless (defined $action) {
      die "emap '$name' found unrecognized operator '$op'";
    }
    my @v = map UNIVERSAL::isa($_, 'Expression') ? $f->($_, $u) : $_, @s;
    return $action->($u, $expr, $op, @v);
  };
  return $f;
}

sub to_str {
  my $expr = shift;
  my $make = emap('to_str',
                  { CON => sub { $_[1][1] },
                    VAR => sub { $_[1][1] },
                    DEFAULT => sub { "($_[3] $_[1][0] $_[4])" },
                  });
  $make->($expr);
}

sub substitute {
  my ($expr, @envs) = @_;
  my ($op, @args) = @$expr;
  if ($op eq 'VAR') {
    my ($name) = @args;
    my $is_param;
    my $value;

    for my $env (@envs) {
      if ($env->has_var($name)) {
        $is_param = 1;
        $value = $env->lookup($name);
        last if defined $value;
      }
    }

    return $expr unless $is_param;
    return $value if defined $value;
    die "Unspecified parameter '$name'";

  } else {
    return $expr->new($op, 
                      map UNIVERSAL::isa($_, 'Expression') ? $_->substitute(@envs) : $_, 
                      @args);
  }
}

sub qualify {
  my ($expr, $prefix) = @_;
  my $q = emap "qualify($prefix)", 
    { DEFAULT => sub { shift; my $x = shift;
                       $x->new(@_)
                     },
      CON => sub { return $_[1] },
      VAR => sub { $_[1]->new('VAR', "$prefix.$_[3]") },
      FUN => sub { return $_[1] },
    };
  $q->($expr);
}

# Take an AST for an expression.  Assuming it
# implies "expression = 0", turn it into a Value::? object
sub to_value {
  my ($expr, $builtins, $context) = @_;
  unless (defined $expr) {
    Carp::croak("Missing expression in 'expression_to_constraints'");
  }
  my ($op, @s) = @$expr;

  if ($op eq 'VAR') {
    my $name = $s[0];
    if ($context->is_param($name)) {
      die "Uneliminated parameter '$name' in '$context->{N}'";
    }
    return Value::Chunk->new_from_var($name, $context->subchunk($name));
  } elsif ($op eq 'CON') {
    return Value::Constant->new($s[0]);
  } elsif ($op eq 'FUN') {
    my ($name, $arg_exp) = @s;
    my $arg = $arg_exp->to_value($builtins, $context);
    unless ($arg->kindof eq "CONSTANT") {
      lino_error("Argument to function '$name' is not a constant");
    }
    return Value::Constant->new($builtins->{$name}->($arg->value));
  } elsif ($op eq 'TUPLE') {
    my %elements;
    for my $k (keys %{$s[0]}) {
      # Add check to make sure that $s[0]{$k} is actually a scalar type XXX
      $elements{$k} = $s[0]{$k}->to_value($builtins, $context);
    }
    return Value::Tuple->new(%elements);
  } elsif ($op eq 'STR') {
    return Value::String->new($s[0]);
  }

  my $e1 = $s[0]->to_value($builtins, $context);
  my $e2 = $s[1]->to_value($builtins, $context);

  my %opmeth = ('+' => 'add',
		'-' => 'sub',
		'*' => 'mul',
		'/' => 'div',
	       );
  
  my $meth = $opmeth{$op};
  if (defined $meth) {
    return $e1->$meth($e2);
  } else {
    lino_error("Unknown operator '$op' in AST");
  }
}

sub to_equations {
  my ($self, $builtins, $context) = @_;
  my $value = $self->to_value($builtins, $context);
  return $value->equations;
}

sub to_constant {
  my ($expr, $env) = @_;
  my ($op, @s) = @$expr;
  if ($op eq 'VAR') {
    if ($env->has_var($s[0])) {
#      return $env->lookup($s[0])->to_constant($env);  # Possible infinite loop
      return $env->lookup($s[0]);
    } else {
      die "Undefined variable '$s[0]'";
    }
  } elsif ($op eq 'CON') {
    return $s[0];
  } elsif ($op eq 'STR') {
    return $s[0];
  } elsif (exists $eval_op{$op}) {
    my @v = map { $_->to_constant($env) } @s;
    return $eval_op{$op}->(@v);
  } else {
    die "Unknown operator '$op' in expression\n";
  }
}

sub eval_in_place {
  my ($self, $env) = @_;
  my $result = $self->eval($env);
  @$self = @$result;
}

################################################################
package Value::Chunk;
@Value::Chunk::ISA = 'Value';

sub kindof { "CHUNK" }

sub new {
    my ($base, $synthetic) = @_;
    my $class = ref $base || $base;
    my $self = {WHAT => $base->kindof,
		SYNTHETIC => $synthetic,
	       };
    bless $self => $class;
}

sub new_from_var {
  my ($base, $name, $type) = @_;
  my $class = ref $base || $base;
  $base->new($type->qualified_synthetic_constraints($name));
}

sub param {
  my ($self, $pname, $pval) = @_;
  if (@_ == 3) {
    $self->{PARAM}{$pname} = $pval;
  } else {
    return $self->{PARAM}{$pname};
  }
}

sub synthetic { $_[0]->{SYNTHETIC} }

sub equations { values %{$_[0]->synthetic} }

sub scale {
  my ($self, $coeff) = @_;
  return 
    $self->new($self->synthetic->scale($coeff));
}

sub add_chunks {
  my ($o1, $o2) = @_;
  my $synthetic = $o1->synthetic->apply2($o2->synthetic,
					 sub { $_[0]->add_equations($_[1]) },
					);
  $o1->new($synthetic);
}

sub add_chunk_con {
  my ($o, $c) = @_;
  my $v = $c->value;
  my $synthetic = $o->synthetic->apply(sub { $_[0]->add_constant($v) });
  $o->new($synthetic);
}

sub add_chunk_tuple {
  my ($o, $t) = @_;
  my $synthetic = 
    $o->synthetic->apply_hash($t->to_hash, 
			      sub { 
				my ($constr, $comp) = @_;
				my $kind = $comp->kindof;
				if ($kind eq "CONSTANT") {
				  $constr->add_constant($comp->value);
				} elsif ($kind eq "CHUNK") {
				  $constr->add_equations($comp->synthetic->constraint(""));
				} elsif ($kind eq "TUPLE") {
				  die "Tuple with subtuple component";
				} else {
				  die "Unknown tuple component type '$kind'";
				}
			      },
			     );
  $o->new($synthetic);
}

sub mul_chunk_con {
  my ($o, $c) = @_;
  $o->scale($c->value);
}


################################################################
package Value::String;
@Value::String::ISA = 'Value';

sub new {
  my ($base, $con) = @_;
  my $class = ref $base || $base;
  bless { WHAT => $base->kindof,
          STRING => $con,
        } => $class;
}

sub str { $_[0]{STRING} }
sub kindof { "STRING" }
sub scale { 
  my ($self, $coeff) = @_;
  die qq{Can't scale string "$self->{STRING}" by $coeff\n};
}
sub reciprocal {
  my ($self) = @_;
  die qq{Can't take reciprocal of string "$self->{STRING}"\n};
}
sub concat_strings {
  my ($self, $str) = @_;
  $self->new($self->str . $str->str);
}

################################################################
package Value::Constant;
@Value::Constant::ISA = 'Value';

sub new {
  my ($base, $con) = @_;
  my $class = ref $base || $base;
  bless { WHAT => $base->kindof,
          VALUE => $con,
        } => $class;
}

sub kindof { "CONSTANT" }

sub value { $_[0]{VALUE} }

sub scale {
  my ($self, $coeff) = @_;
  $self->new($coeff * $self->value);
}

sub reciprocal {
  my ($self) = @_;
  my $v = $self->value;
  if ($v == 0) {
    die "Division by zero";
  }
  $self->new(1/$v);
}

sub add_constants {
  my ($c1, $c2) = @_;
  $c1->new($c1->value + $c2->value);
}

sub mul_constants {
  my ($c1, $c2) = @_;
  $c1->new($c1->value * $c2->value);
}

sub equations {
  return [];
}

################################################################
package Value::Tuple;
@Value::Tuple::ISA = 'Value';

sub kindof { "TUPLE" }

sub components { keys %{$_[0]{TUPLE}} }
sub component_values { values %{$_[0]{TUPLE}} }
sub has_component { exists $_[0]{TUPLE}{$_[1]} }
sub component { $_[0]{TUPLE}{$_[1]} }
sub to_hash { $_[0]{TUPLE} }

sub new {
  my ($base, %tuple) = @_;
  my $class = ref $base || $base;
  bless { WHAT => $base->kindof,
          TUPLE => \%tuple,
        } => $class;
}

sub scale {
    my ($self, $coeff) = @_;
    my %new_tuple;
    for my $k ($self->components) {
      $new_tuple{$k} = $self->component($k)->scale($coeff);
    }
    $self->new(%new_tuple);
}

sub has_same_components_as {
  my ($t1, $t2) = @_;
  my %t1c;
  for my $c ($t1->components) {
    return unless $t2->has_component($c);
    $t1c{$c} = 1;
  }
  for my $c ($t2->components) {
    return unless $t1c{$c};
  }
  return 1;
}

sub equations {
  my $self = shift;
  map $_->equations, $self->component_values;
}

sub add_tuples {
  my ($t1, $t2) = @_;
  croak("Nonconformable tuples") unless $t1->has_same_components_as($t2);

  my %result ;
  for my $c ($t1->components) {
    $result{$c} = $t1->component($c)->add($t2->component($c));
  }
  $t1->new(%result);
}

sub mul_tuple_con {
  my ($t, $c) = @_;

  $t->scale($c->value);
}

1;
