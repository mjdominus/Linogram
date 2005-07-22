use strict;


package Type::Scalar;
@Type::Scalar::ISA = 'Type';

sub is_scalar { 1 }

sub add_constraint { 
  die "Added constraint to scalar type";
}

sub add_subchunk { 
  die "Added subchunk to scalar type";
}

sub drawables { () }   # Numbers don't have drawables

sub all_leaf_subchunks { "" } # They are themselves leaves

# Qualification is a little different, owing only to the
# fact that the empty string has a special meaning in a constraint
sub qualified_synthetic_constraints {
  my ($self, $name) = @_;
  Synthetic_Constraint_Set->new
      ("" => 
       Constraint->new($name => 1)
      );
}


################################################################
package Type;

sub FREEZER {
  my $s = "TYPE <$_[0]{N}>";
  \$s;
}

# What does a type contain?
# * N: Type name
# * P: Parent type
# * C: Constraints
# * D: Drawable list
# * O: Subchunk hash (names => types)
# * V: Parameter definitions

sub new {
  my ($old, $name, $parent) = @_;
  my $class = ref $old || $old;
  my $self = {N => $name, P => $parent, C => [], 
              O => {}, D => [], V => {},
             };
  bless $self => $class;
}

sub is_scalar { 0 }

sub parent { $_[0]{P} }

sub add_param_default {
  my ($self, $name, $expr) = @_;
  if (defined $self->{V}{$name}) {
    warn "$self->{N} parameter '$name' redefined";
  }
  $self->{V}{$name} = $expr;
}

sub add_constraints {
  my ($self, @exprs) = @_;
  push @{$self->{C}}, @exprs;
}

sub constraint_expressions {
  my $self = shift;

  my @constraint_exprs = @{$self->{C}};
  my $p = $self->parent;
  if (defined $p) { push @constraint_exprs, $p->constraint_expressions }

  @constraint_exprs;
}

sub synthetic_constraints {
  my @subchunks = $_[0]->all_leaf_subchunks;
  Synthetic_Constraint_Set->new(map {$_ => Constraint->new($_ => 1)}
					  @subchunks
					 );
}

sub qualified_synthetic_constraints {
  $_[0]->synthetic_constraints->qualify($_[1]);
}

sub constraint_set {
  my $self = shift;
  Constraint_Set->new(@{$self->constraints});
}

sub add_drawable {
  my ($self, $drawable) = @_;
  push @{$self->{D}}, $drawable;
}

sub add_pspec {
  my ($self, $name, $expr) = @_;
  if ($self->is_param($name)) {
    $self->add_param_default($name, $expr);
  } else {
    $self->add_constraints(Expression->new('-',
                                           Expression->new('VAR', $name),
                                           $expr));
  }
}

sub is_param {
  my ($self, $name) = @_;
  my ($base, $rest) = split /\./, $name, 2;
  if (defined $rest) {
    return $self->subchunk($base)->is_param($rest);
  } else {
    return exists $self->{V}{$base};
  }
}

sub has_subchunk
 {
  my ($self, $name) = @_;
  defined($self->subchunk($name, "don't croak"));
}

# Should this be recursive?
# No, the recursion in the ->draw method itself will take care of that.
# If no drawables are explicitly mentioned, then draw all the subchunks
# except those with scalar type.
# However, it *should* recurse up the inheritance tree.
sub drawables {
  my ($self) = @_;
  return @{$self->{D}} if $self->{D} && @{$self->{D}};

  my %subchunk = $self->subchunks;
  my @drawables = grep ! $subchunk{$_}->is_scalar, keys %subchunk;

  if (my $p = $self->parent) {
    push @drawables, $p->drawables if $p;
  }

  @drawables;
}

sub add_subchunk {
  my ($self, $name, $type) = @_;
  $self->{O}{$name} = $type;
}

sub subchunks {
  my $self = shift;
  my %all;
  while ($self) {
    %all = (%{$self->{O}}, %all);
    $self = $self->parent;
  }
  %all;
}

sub all_leaf_subchunks {
  my $self = shift;
  my @all;
  my %base = $self->subchunks;
  while (my ($name, $type) = each %base) {
    push @all, map {$_ eq "" ? $name : "$name.$_"} 
      $type->all_leaf_subchunks;
  }
  @all;
}


sub subchunk { 
  my ($self, $name, $nocroak) = @_;
  return $self unless defined $name;
  my ($basename, $suffix) = split /\./, $name, 2;
  if (exists $_[0]{O}{$basename}) {
    return $_[0]{O}{$basename}->subchunk($suffix); 
  } elsif (my $parent = $self->parent) {
    $parent->subchunk($name);
  } elsif ($nocroak) {
    return;
  } else {
    Carp::croak("Asked for nonexistent subchunk '$name' of type '$self->{N}'");
  }
}

sub draw {
  my ($self, $builtins, $env) = @_;

  unless ($env) {
    $env ||= Environment->new();
    my $equations = $self->constraint_equations($builtins);
    my %solutions = $equations->values;
    my %params = $self->param_values;
    $env = Environment->new(%params, %solutions);
    # XXX TODO maybe incorporate V's here?
  }

  for my $name ($self->drawables) {
    if (ref $name) { 		# actually a coderef, not a name
      $name->($env);
    } else {
      my $type = $self->subchunk($name);
      warn "Drawing subchunk '$name' ($type->{N})\n" if $ENV{DEBUG_DRAW};
      my $subenv = $env->subset($name);
      $type->draw($builtins, $subenv, "already solved");
    }
  }
}

sub param_values {
  my $self = shift;
  my %V;

  for (my $ancestor = $self; $ancestor; $ancestor=$ancestor->parent) {
    %V = (%V, %{$ancestor->{V}});
  }

  for my $name (keys %V) {
    if ($V{$name}[0] eq "CON") { # wrong test here XXX TODO
      $V{$name} = $V{$name}[1];
    } else {
      delete $V{$name};
    }
  }

  while (my ($name, $type) = each %{$self->{O}}) {
    next if $type->is_scalar;
    my %Vo = $type->param_values;
    for my $pname (keys %Vo) {
      my $qname = "$name.$pname";
      next if exists $V{$qname};
      $V{$qname} = $Vo{$pname};
    }
  }

  %V;
}

sub constraint_equations {
  my ($self, $builtins, @envs) = @_;
  my $new_env = Environment->new(%{$self->{V}});
  my @exprs = map $_->substitute(@envs, $new_env), $self->constraint_expressions;
  my @eqns = map $_->to_equations($builtins, $self), @exprs;

  while (my ($name, $type) = each %{$self->{O}}) {
    next if $type->is_scalar;
    my @new_eqns = $type->constraint_equations($builtins,
                                               map $_->subset($name),
                                               @envs, $new_env);
    push @eqns, map $_->qualify($name)->equations, @new_eqns;
  }
  return Constraint_Set->new(@eqns);
}

################################################################
package Constraint_Set;
@Constraint_Set::ISA = 'Equation::System';

sub constraints {
  my $self = shift;
  $self->equations;
}

sub qualify {
  my ($self, $name) = @_;
  $self->new(map $_->qualify($name), $self->constraints);
}

################################################################
package Constraint;
use Equation;
@Constraint::ISA = qw(Equation);

sub qualify {
  my ($self, $prefix) = @_;
  my %q = ("" => $self->constant);
  for my $var ($self->varlist) {
    $q{"$prefix.$var"} = $self->coefficient($var);
  }
  $self->new(%q);
}

sub new_constant {
  my ($base, $val) = @_;
  my $class = ref $base || $base;
  $class->new("" => $val);
}

sub add_constant {
  my ($self, $v) = @_;
  $self->add_equations($self->new_constant($v));
}

sub mul_constant {
  my ($self, $v) = @_;
  $self->scale_equation($v);
}


################################################################
package Synthetic_Constraint_Set;

sub new { 
  my $base = shift;
  my $class = ref $base || $base;

  my $constraints;
  if (@_ == 1) {
    $constraints = shift;
  } elsif (@_ % 2 == 0) {
    my %constraints = @_;
    $constraints = \%constraints;
  } else {
    my $n = @_;
    require Carp;
    Carp::croak("$n arguments to Synthetic_Constraint_Set::new");
  }

  bless $constraints => $class;
}

sub constraints { values %{$_[0]} }
sub constraint { $_[0]->{$_[1]} }
sub labels { keys %{$_[0]} }
sub has_label { exists $_[0]->{$_[1]} }

sub add_labeled_constraint {
  my ($self, $label, $constraint) = @_;
  $self->{$label} = $constraint;
}

# Curry?
sub apply {
  my ($self, $func) = @_;
  my %result;
  for my $k ($self->labels) {
    $result{$k} = $func->($self->constraint($k));
  }
  $self->new(\%result);
}

sub qualify {
  my ($self, $prefix) = @_;
  $self->apply(sub { $_[0]->qualify($prefix) });
}

sub scale {
  my ($self, $coeff) = @_;
  $self->apply(sub { $_[0]->scale_equation($coeff) });
}

sub apply_hash {
  my ($self, $hash, $func) = @_;
  my %result;
  for my $c (keys %$hash) {
    my $cc = ".$c";
    for my $k ($self->labels) {
      next unless $k eq $c || substr($k, -length($cc)) eq $cc;
      $result{$k} = $func->($self->constraint($k), $hash->{$c});
    }
  }
  $self->new(\%result);
}

sub apply2 {
  my ($self, $arg, $func) = @_;
  my %result;
  for my $k ($self->labels) {
    next unless $arg->has_label($k);
    $result{$k} = $func->($self->constraint($k), $arg->constraint($k));
  }
  $self->new(\%result);
}

################################################################
package Environment;

sub new {
  my ($self, %vars) = @_;
  my $class = ref($self) || $self;
  bless \%vars => $class;
}

sub clone { 
  my $self = shift;
  $self->new($self->var_hash);
}

sub merge {
  my ($self, %new) = @_;
  %$self = (%$self, %new);
}

sub lookup {
  my ($self, $name) = @_;
  $self->{$name};
}

sub has_var {
  my ($self, $name) = @_;
  exists $self->{$name};
}

sub vars { keys %{$_[0]} }
sub var_hash { %{$_[0]} }


sub subset {
  my ($self, $name) = @_;
  my %result;
  for my $k (keys %$self) {
    my $kk = $k;
    if ($kk =~ s/^\Q$name.//) {
      $result{$kk} = $self->{$k};
    }
  }
  $self->new(%result);
}

# Given two environments, substitute the definitions in the second one
# into the definitions in the first wherever a variable from the second
# environment appears in a definition of a variable in the first environment
#
# for example, if $self has {a: x+1,  b: x+y} and $val has
# {x: 3+d, y: x+3}, then return {a: 4+d, b:9+2d}
sub incorporate_values {
  my ($Self, $Val) = @_;
  my ($self, $val) = ($Self->clone, $Val->clone);
  my @rhvars = $val->vars;

  # First, flatten the RHS as much as possible.
  for my $v1 (@rhvars) {
    $val->lookup($v1)->eval_in_place($val);
  }

  # Now insert the results into the LHS
  for my $v1 ($self->vars) {
    $self->lookup($v1)->eval_in_place($val);
  }
  $self;
}

# Given an environment which might contain arbitrary unevaluated
# (or partially evaluated) expressions, return a hash mapping names
# to real numeric values, for only those elements that are actually constants
sub flatten {
  my $self = shift;
  my %result;
  for my $var ($self->vars) {
    my $val = $self->lookup($var);
    if ($val->is_constant) {
      $result{$var} = $val->value;
    }
  }
  \%result;
}
