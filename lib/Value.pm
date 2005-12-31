
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

sub new_const_vals {
  my ($base, %tuple) = @_;
  for my $k (keys %tuple) {
    $tuple{$k} = Value::Constant->new($tuple{$k});
  }
  $base->new(%tuple);
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
