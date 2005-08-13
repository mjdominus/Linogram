
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

#
# There's a big problem with this function:
# it work great, but you can never rememeber how to use it.
# You have to look at the source code every time.
# Is this a problem?  Can (and should) it be redesigned?
#
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
    my @v = map UNIVERSAL::isa($_, 'Expression') ? $f->($_, $u) : (), @s;
    return $action->($u, $expr, $op, @v);
  };
  return $f;
}

*to_str = emap('to_str',
               { CON => sub { $_[1][1] },
                 VAR => sub { $_[1][1] },
                 DEFAULT => sub { "($_[3] $_[1][0] $_[4])" },
               });

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

sub _uniq {
  my %h;
  $h{$_}++ for @_;
  keys %h;
}

*uses = emap 'uses',
  { 
      DEFAULT => sub {
          my ($u, $expr, $op, @v) = @_;
          return [map @$_, @v];
      },
      VAR => sub {
          my ($u, $expr, $op, @v) = @_;
          [$expr->[1]];
      },
  };

sub list_vars {
  my $vars = uses(@_);
  _uniq(@$vars);
}

