package Type;
use Bounds;
use Environment;
use Type::Array;
use strict 'vars';

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
# * K: "CLOSED" or "OPEN"

sub new {
  my ($old, $name, $parent, $closure) = @_;

  $closure ||= "CLOSED";
  Carp::croak("bad closure '$closure'")
      unless $closure eq "OPEN" || $closure eq "CLOSED";

  my $class = ref $old || $old;
  my $self = {N => $name, P => $parent, C => [],
              O => {}, D => [], V => {}, K => $closure,
             };
  bless $self => $class;
}

sub is_scalar { 0 }
sub is_array_type { 0 }

sub parent { $_[0]{P} }
sub name { $_[0]{N} }

sub set_closure {
  my ($self, $closure) = @_;
  $self->{K} = $closure || "CLOSED";
}

sub is_closed { $_[0]{K} eq "CLOSED" }
sub is_open   { $_[0]{K} eq "OPEN" }
sub closure   { $_[0]{K} }

sub add_param_default {
  my ($self, $name, $expr) = @_;
  if (defined $self->{V}{$name}) {
    warn "$self->{N} parameter '$name' redefined";
  }
  $self->{V}{$name->to_str} = $expr;
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
  my ($base, $rest) = $name->split;
  if (defined $rest) {
    my $sc = $self->subchunk($base);
    return $sc && $sc->is_param($rest);
  } else {
    return 1 if exists $self->{V}{$base};
    my $p = $self->parent;
    return $p && $p->is_param(Name->new($base));
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
  my ($self, $env) = @_;
  return @{$self->{D}} if $self->{D} && @{$self->{D}};

  my %subchunk = $self->my_subchunks;
  my @drawables = grep ! $subchunk{$_}->is_scalar, keys %subchunk;
  @drawables = map {
    # XXX $self->subchunk($_) should just be $subchunk{$_}, but
    # ->my_subchunks for some reason returns array types as if they were
    # scalars.  This should be fixed.
    if ($self->subchunk($_)->is_array_type) {
      my $subchunk = $_;
      my $bounds = $self->bounds_of(Name->new($subchunk), $env);
      map Name->new([$subchunk, Expression->new_constant($_)]), $bounds->range;
    } else {
      Name->new($_);
    }
  } @drawables;

  my $parent = $self->parent;
  push @drawables, $parent->drawables if $parent;

  @drawables;
}

sub add_subchunk {
  my ($self, $name, $type, $count) = @_;
  if (defined $count) {
    $self->{O}{$name} = Type::Array->new($type, $count);
  } else {
    $self->{O}{$name} = $type;
  }
}

sub my_subchunks {
  my $self = shift;
  my %basic_subchunks = %{$self->{O}};
  my %subchunks;
  while (my ($n, $t) = each %basic_subchunks) {
#    if ($t->is_array_type) {
#      my $bounds = $t->bounds;
#      for my $i ($bounds->range) {
#        $subchunks{"$n\[$i]"} = $t->base_type;
#      }
#    } else {
      $subchunks{$n} = $t;
#    }
  }
  %subchunks;
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

  $name = Name->new($name) unless ref $name; # convert "a" to N("a")

  my ($first, $rest) = $name->split;

  # XXX encapsulation violation
  my ($basename, $subscript_expr) = ref $first ? @$first : ($first, undef);

  if (exists $_[0]{O}{$basename}) {
    my $obj_type = $_[0]{O}{$basename};
    if ($obj_type->is_array_type) {
      if (defined($subscript_expr)) {
	# TODO array bounds check here, if possible
	return $obj_type->base_type->subchunk($rest);
      } else {
	return $obj_type->subchunk($rest);
      }
    } else {
      if (defined($subscript_expr) && not $nocroak) {
	Carp::croak("Subscripted non-array object '$basename' in '$name'");
      } else {
	return $obj_type->subchunk($rest);
      }
    }
  } elsif (my $parent = $self->parent) {
    $parent->subchunk($name);
  } elsif ($nocroak) {
    return;
  } else {
    my $ns = $name->to_str;
    Carp::croak("Asked for nonexistent subchunk '$ns' of type '$self->{N}'");
  }
}

sub enclosing_type {
  my ($self, $name) = @_;
  $self->subchunk($name->enclosing_prefix);
}


sub subchunk_type {
  my ($self, $name, $nocroak) = @_;
  $self->subchunk($name, $nocroak)->base_type($nocroak);
}

sub subchunk_bounds {
  my ($self, $name, $nocroak) = @_;
  $self->subchunk($name, $nocroak)->bounds($nocroak);
}

sub base_type {
  my ($self, $nocroak) = @_;
  return $self;
}

sub bounds {
  my ($self, $nocroak) = @_;
  Carp::croak("Can't get bounds for non-array type '" . $self->name . "'")
      unless $nocroak;
  return;
}

sub bounds_of {
  my ($self, $name, $defs) = @_;
  $defs ||= Environment->empty;

  { my $n = $name;
    until ($n->is_simple) {
      my ($first, $rest) = $n->split;
      $first = $first->[0] if ref $first;
      $defs = $defs->subset($first);
      $n = $rest;
    }
  }

  my $enclosing_type = $self->enclosing_type($name);
  my $array = $self->subchunk($name);
  if ($array->is_array_type) {
    my $bounds_expr = $array->bounds_expr
                            ->substitute_variables($defs)
                            ->fold_constants;
    if ($bounds_expr->is_constant) {
      return Bounds->new(0,
			 $bounds_expr->value - 1,
			 $enclosing_type->closure);
    } else {
      return;
    }
  } else {
    Carp::croak($name->to_str . " in " . $self->name .
		" is not an array type");
  }
}

sub draw {
  my ($self, $builtins, $env) = @_;

  unless ($env) {
#    $env ||= Environment->new();
    my $param_defs = $self->param_defs;
    my $p_order = $param_defs->self_substitute();
    my $equations = $self->all_constraint_equations($builtins,
                                                    $param_defs,
                                                    $p_order);
    my $solutions = Environment->new($equations->values);
    $env = $self->param_values($solutions, $p_order);
    $env->merge_env($solutions);
  }

  for my $name ($self->drawables($self->param_defs)) {
#    if (ref $name) { 		# actually a coderef, not a name
    if (ref $name eq "CODE") { 		# actually a coderef, not a name
        warn "Calling drawutil(" . $self->name . ")\n"
	  if $ENV{DEBUG_DRAW};
	$name->($env);
    } else {
      my $type = $self->subchunk($name);
      warn "Drawing subchunk '" . $name->to_str . "' (" . $type->name . ")\n"
	  if $ENV{DEBUG_DRAW};
      my $subenv = $env->subset(Name->new($name));
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
    my $subenv = $opts{ENV} ? $opts{ENV}->subset($name) : undef;
    my $qenv = $subchunks{$name}->over($meth, %opts, ENV => $subenv)
                                ->qualify($name);
    if ($opts{QUALIFY_VALS}) {
      for my $vname ($qenv->vars) {
        my $expr = $qenv->lookup($vname);
        next unless defined $expr;
        $qenv->merge($vname => $expr->qualify($name));
      }
    }
    $env->append_env($qenv);
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
  if ($parent) { $env->append_env($parent->over(@_)) }

  $env;
}

sub up_list {
  my ($self, $meth, %opts) = @_;
  my @results = $self->$meth;
  my $parent = $self->parent;
  push @results, $parent->over_list($meth, %opts) if $parent;

  @results;
}

sub over_list {
  my ($self, $meth, %opts) = @_;
  my @results;

  @results = $opts{NO_UP} ? $self->$meth : $self->up_list($meth, %opts);

  my %subchunks = $self->my_subchunks;
  for my $name (keys %subchunks) {
    my $subenv = $opts{ENV} ? $opts{ENV}->subset($name) : undef;
    my @sub = $subchunks{$name}->over_list($meth, %opts, ENV => $subenv);
    if ($self->subchunk($name)->is_array_type) {
      for my $i ($self->subchunk($name)->bounds($opts{ENV})->range) {
	my @r = map $_->qualify(Name->new([$name,
					   Expression->new_constant($i)])),
		     @sub;
	push @results, @r;
      }
    } else {
      push @results, map $_->qualify($name), @sub;
    }
  }

  @results;
}


# The ->{V} hash should probably be an enironment to begin with
# So should the ->{O} hash for that matter
sub param_defs {
  my $self = shift;
  my $pd = $self->over('my_param_defs', QUALIFY_VALS => 1);
  return $pd;
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
    my $Vo = $type->param_values($env->subset(Name->new($name)));
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
    $expr = $expr->substitute_variables($param_def, $p_order);
  }

  my @eqns = map $_->to_equations($builtins, $self), @exprs;
  Constraint_Set->new(@eqns);
}

sub all_constraint_equations {
  my ($self, $builtins, $param_defs, $p_order) = @_;

  my @constraint_expressions = $self->over_list('my_constraint_expressions',
						ENV => $param_defs);

  for my $expr (@constraint_expressions) {
    $expr = $expr->substitute_variables($param_defs, $p_order);
  }

  @constraint_expressions =
    map $self->expand_subscripted_expression($_, $param_defs),
      @constraint_expressions;

#  @constraint_expressions =
#    map $self->reduce_subscripts($_, $param_defs),
#      @constraint_expressions;

  my @eqns = map $_->to_equations($builtins, $self), @constraint_expressions;

  Constraint_Set->new(@eqns);
}

# Given an expression, return a hash
# keys in the hash are the (simple) subscript variables
# values are [low, high, OPEN|CLOSED] range triples
# die if a variable is ambiguous---if it appears in
# types with two incompatible ranges
sub subvar_mappings {
  my ($self, $expr, $param_defs) = @_;
  my %range;
  my @assocs = @{$expr->subscript_associations};
  for my $assoc (@assocs) {
    my ($target_chunk_name, $var) = @$assoc;
    $var = $var->to_str;

    my $bounds = $self->bounds_of($target_chunk_name, $param_defs);
    unless ($bounds) {
      my $c = $self->name;
      my $tc = $target_chunk_name->to_str;
      Carp::croak("Bounds of '$tc' in $c are not constant \n\t" . $param_defs->to_str);
    }

    my @range = @$bounds;  # XXX Encapsulation violation
    if (exists $range{$var}) {
      unless ($range{$var}[0] == $range[0] && $range{$var}[1] == $range[1]
	      && $range{$var}[2] eq $range[2]) {
        my $estr = $expr->to_str;
        # TODO error message should mention both subexpressions
        die "Variable '$var' appears in incompatible subscripts in expression '$estr'\n";
      }
    } else {
      $range{$var} = \@range;
    }
  }
  return %range;
}

sub expand_subscripted_expression {
  my ($self, $expr, $param_defs) = @_;
  my @exprs;
  my %subvar_mappings = $self->subvar_mappings($expr, $param_defs);

  # Set up iterator tracker for ranges
  my @it;
  while (my ($v, $range) = each %subvar_mappings) {
    my ($lo, $hi) = @$range;
    push @it, {VAR => $v, LO => $lo, HI => $hi, CUR => $lo};
  }

  my $DONE;
 EXPRESSION:
  until ($DONE) {
    my $env = Environment->new(map {$_->{VAR} => $_->{CUR}} @it);
    my $a = $expr->substitute_variables($env);
    my $b = $a->reduce_subscripts([$self, $param_defs]);
    push @exprs, $b if defined $b;
    for my $i (@it) {
      if ($i->{CUR} < $i->{HI}) {
        $i->{CUR}++;
        next EXPRESSION;
      } else {
        $i->{CUR} = $i->{LO}
      }
    }
    $DONE = 1;
  }
  return @exprs;
}

# Given a type and an expression:
# examine subscripts in expresion
# if subscripts are out-of-bound, then (if type is closed)
# reduce the subscripts mod N, where N is the dimension of the
# array subobject of the type, or (if type is open) discard the
# expression.
#
# return ($expr) if no subscripts out of bounds, otherwise
# ($reduced_expression) if closed, () if open
sub reduce_subscripts {
  my ($self, $expr, $env) = @_;
  my $reduced = $expr->reduce_subscripts($env);
  return $reduced == $expr ? ($expr)
       : $self->is_closed ? ($reduced)
       :                    ();
}

1;
