## use strict;

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
use Environment;

#sub FREEZER {
#  my $s = "TYPE <$_[0]{N}>";
#  \$s;
#}

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

# Utility backend for constraint_expressions
sub _constraint_expressions {
  my $self = shift;
  my %h = map {$_ => $_} @{$self->{C}};
  Environment->new(%h);
}

sub my_constraint_expressions {
  my $self = shift;
  @{$self->{C}};
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

  my %subchunk = $self->up_subchunks;
  my @drawables = grep ! $subchunk{$_}->is_scalar, keys %subchunk;

  if (my $p = $self->parent) {
    push @drawables, $p->drawables;
  }

  @drawables;
}

sub add_subchunk {
  my ($self, $name, $type) = @_;
  $self->{O}{$name} = $type;
}

sub my_subchunks {
  my $self = shift;
  %{$self->{O}};
}


sub all_leaf_subchunks {
  my $self = shift;
  my @all;
  my $sc = sub { my $self = shift;
                 Environment->new($self->my_subchunks)
               };
  my %base = $self->up($sc)->var_hash;
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
#    $env ||= Environment->new();
    my $param_defs = $self->param_defs;
    my @p_order = $param_defs->tsort;
    my $equations = $self->all_constraint_equations($builtins,
                                                    $param_defs,
                                                    \@p_order);
    my $solutions = Environment->new($equations->values);
    $env = $self->param_values($solutions, \@p_order);
    $env->merge_env($solutions);
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

# given a type object and the name of a method that returns an environment,
# accumulate the return value of the environments returned by the method
# called on this object and all its subobjects.
sub over {
  my ($self, $meth, %opts) = @_;

  my $env = $opts{NO_UP} ? $self->$meth : $self->up($meth, %opts);

  my %subchunks = $self->my_subchunks;
  for my $name (keys %subchunks) {
    my $subenv = $subchunks{$name}->over($meth, %opts)->qualify($name);
    $env->append_env($subenv);
  }

  $env;
}

# given a type object and the name of a method that returns an
# environment, accumulate the environments from the method called on
# this object and all its parent objects
sub up {
  my $self = shift;
  my ($meth) = @_;

  my $env = $self->$meth;
  my $parent = $self->parent;
  if ($parent) { $env->merge_env($env, $parent->up(@_)) }

  $env;
}

sub up_list {
  my ($self, $meth) = @_;
  my @results;

  for ( ; $self; $self = $self->parent) {
    push @results, $self->$meth;
  }
  @results;
}

sub over_list {
  my ($self, $meth, %opts) = @_;
  my @results;

  @results = $opts{NO_UP} ? $self->$meth : $self->up_list($meth, %opts);

  my %subchunks = $self->my_subchunks;
  for my $name (keys %subchunks) {
    my @sub = $subchunks{$name}->over_list($meth, %opts);
    push @results, map $_->qualify($name), @sub;

  }

  @results;
}


# The ->{V} hash should probably be an enironment to begin with
# So should the ->{O} hash for that matter
sub param_defs {
  my $self = shift;
  $self->over('my_param_defs');
}

sub my_param_defs {
  my $self = shift;
  Environment->new(%{$self->{V}});
}


# Given a type, which contains parameter definitions, an environment
# of solved variable values, and a dependency ordering of parameter
# names, evaluate the definitions and return an  environment mapping parameter
# names to their values
sub param_values {
  my ($self, $_env, $p_order) = @_;
  my $DEBUG = $ENV{DEBUG_PARAM};
  my $env = $_env->clone();
  my $pvals = Environment->new();

  my $params = $self->up('param_defs');

  for my $name (@$p_order) {
    my $param_exp = $params->lookup($name);
    if (not defined $param_exp) {
      die "Undefined parameter $self->{N}.$name\n";
    }
    my $val = eval { $param_exp->to_constant($env) };
    if ($@) {
      die "Ill-defined parameter $self->{N}.$name\n\t$@\n";
    } else {
      warn "$self->{N}.$name => $val\n" if $DEBUG;
      $pvals->merge($name => $val);
      $env->merge($name => $val);
    }
  }

  while (my ($name, $type) = each %{$self->{O}}) {
    next if $type->is_scalar;
    warn "Checking subobject $name of type $type->{N}...\n" if $DEBUG;
    my $Vo = $type->param_values($env->subset($name));
    warn "...Done\n" if $DEBUG;
    my $Vq = $Vo->qualify($name);
    $pvals->merge_env($Vq);
    $env->merge_env($Vq);
  }

  $pvals;
}

# Given a type object, en environment defining builtin functions,
# an environment with parameter definitions, and a topological 
# ordering of the parameter names, 
# return a constraint set of the type's constraints, 
# including those from subtypes, with all parameters replaced by
# their definitions and all builtin functions evaluated
sub constraint_equations {
  my ($self, $builtins, $param_def, $p_order) = @_;

  my @exprs = $self->constraint_expressions;

  for my $expr (@exprs) {
    $expr = $expr->substitute($param_def, $p_order);
  }
  
  my @eqns = map $_->to_equations($builtins, $self), @exprs;
  Constraint_Set->new(@eqns);
}

sub all_constraint_equations {
  my ($self, $builtins, $param_defs, $p_order) = @_;

  my @constraint_expressions = $self->over_list('my_constraint_expressions');

  for my $expr (@constraint_expressions) {
    $expr = $expr->substitute($param_defs, $p_order);
  }

  my @eqns = map $_->to_equations($builtins, $self), @constraint_expressions;

  Constraint_Set->new(@eqns);
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

1;
