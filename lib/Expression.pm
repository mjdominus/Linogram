
package Expression; 
use Value;

my %eval_op = ( '+' => sub { $_[0] + $_[1] },
		'-' => sub { $_[0] - $_[1] },
		'*' => sub { $_[0] * $_[1] },
		'/' => sub { $_[0] / $_[1] },
		'CON' => "special case",  # TODO: Change this to NUM
		'VAR' => "special case",
		'FUN' => "special case",
		'STR' => "special case",
		'TUPLE' => "special case",
	      );
sub _is_special_case {
  $eval_op{$_[0]} eq "special case";
}

sub new {
  my ($base, $op, @args) = @_;
  my $class = ref $base || $base;
  unless (exists $eval_op{$op}) {
    die "Unknown operator '$op' in expression '$op @args'\n";
  }

  if ($op eq "VAR" && ! UNIVERSAL::isa($args[0], 'Name')) {
    $args[0] = Name->new($args[0]);
  }

#  if (ref $eval_op{$op}
#      && $args[0][0] eq "CON" && $args[1][0] eq "CON") {
#    # Fold constants
#    # XXX assumes all foldable operators are binary
#    return bless ["CON", $eval_op{$op}->($args[0][1], $args[1][1])] => $class;
#  }

  bless [ $op, @args ] => $class;
}

sub op { $_[0][0] }
sub args { @{$_[0]}[1..$#{$_[0]}] }

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

sub copy {
  my $self = shift;
  my @args = $self->args;
  my $op = $self->op;
  if (_is_special_case($op)) {
    $self->new($op, @args);
  } else {
    $self->new($op, map {$_->copy} @args);
  }
}

sub is_constant { $_[0][0] eq "CON" || $_[0][0] eq "STR" }
sub is_number { $_[0][0] eq "CON" }
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
    my @v;
    if ($op eq "TUPLE") {
      my $vexpr = $expr->tuplemap(sub { $f->($_[0], $u) });
      @v = $vexpr->[1];
    } elsif ($op eq "FUN") {
      my ($fun_name, @fun_args) = @s;
      @v = ($fun_name, map $f->($_, $u), @fun_args); 
    } elsif (_is_special_case($op)) {
      @v = @s;
    } else {
      @v = map $f->($_, $u), @s;
    }
    return $action->($u, $expr, $op, @v);
  };
  return $f;
}

*to_str = emap('to_str',
               { CON => sub { $_[1][1] },
		 STR => sub { qq{ "$_[1][1]" } },
                 FUN => sub { $_[1][1] . $_[1][2]->to_str },
                 VAR => sub { $_[1][1]->to_str },
		 TUPLE => sub { 
		   my ($u, $expr, $op, @v) = @_;
		   _tuple_to_str(@v);
		 },
                 DEFAULT => sub { "($_[3] $_[1][0] $_[4])" },
               });

sub _tuple_to_str {
  my $t = shift;
  my $weird;
  for my $k (keys %$t) {
    $weird = 1 if $k !~ /^[xyz]$/;
  }
  if ($weird) {
    "{ " . join(", ", map "$_ => $t->{$_}", sort keys %$t) . " }";
  } elsif (exists $t->{z}) {
    "{ $t->{x}, $t->{y}, $t->{z} }";
  } else {
    "{ $t->{x}, $t->{y} }";
  }
}

# $expr->substitute_variables($environment)
# replace variables with values in expression
# subexpressions of the form [VAR "foo"] are replaced with [CON 37]
# variables not present in the environment are left alone
# returns new, modified expression, which may share structure with the original
*substitute_variables = 
  emap('substitute_variables',
       {
	DEFAULT => sub { $_[1]->new(@_[2..$#_]) },
	VAR => sub { my $name = $_[3];
		     my $env  = $_[0];
		     my $croak;
		     ($env, $croak) = @$env if ref $env eq 'ARRAY';


		     $name = $name->substitute_subscripts($env);

	             my $namestr = $name->to_str;
		     if ($env->has_var($namestr)) {
			 my $r = $env->lookup($namestr);
			 return UNIVERSAL::isa($r, 'Expression') ? $r : 
			     Expression->new('CON', $r);
		     } elsif ($croak) {
		       die "Name '$namestr' absent";
		     } else {
		       $_[1]->new($_[2], $name);
		     }},
       });

*fold_constants = 
  emap('fold_constants',
       {
	CON => sub { $_[1] },
	VAR => sub { $_[1] },
	TUPLE => sub { $_[1]->new('TUPLE', $_[3]) },
	DEFAULT => sub {
	  my ($u, $expr, $op, @args) = @_;
	  for my $a (@args) {
	    return $expr->new($op, @args) if $a->[0] ne 'CON';
	  }
	  my @v = map $_->[1], @args;
          my $res = $eval_op{$op}->(@v);
	  return $expr = $expr->new_constant($res);
	},
       });

sub qualify {
  my ($expr, $prefix) = @_;
  my $q = emap "qualify($prefix)", 
    { DEFAULT => sub { shift; my $x = shift;
                       $x->new(@_)
                     },
      CON => sub { return $_[1] },
      VAR => sub { $expr->new_var($_[3]->qualify($prefix))  },
      FUN => sub { shift;  my $expr = shift; return $expr->new(@_); },
      TUPLE => sub { 
        return $_[1]->tuplemap(sub{ $_[0]->qualify($prefix) })
      },
    };
  $q->($expr);
}

# $self is a tuple expression
# map $f over its component values and return a new tuple
sub tuplemap {
  my ($self, $f) = @_;
  my ($op, $comp) = @$self;
  die "expression <@$self> is not a tuple in tuplemap()"
    unless $op eq "TUPLE";
  my %new;
  for my $k (keys %$comp) {
    $new{$k} = $f->($comp->{$k}, $k);
  }
  $self->new('TUPLE', \%new);
}

# Take an AST for an expression.  Assuming it
# implies "expression = 0", turn it into a Value::? object
sub to_value {
  my ($expr, $builtins, $context) = @_;
  unless (defined $expr) {
    Carp::croak("Missing expression in 'to_value'");
  }
  my ($op, @s) = @$expr;

  if ($op eq 'VAR') {
    my $name = $s[0];
    # XXX TODO add a check here to make sure that the name is monomorphic
    # (a[3] allowed; a[x] not allowed.)
    return Value::Chunk->new_from_var($name->to_str, 
				      $context->subchunk($name));
  } elsif ($op eq 'CON') {
    return Value::Constant->new($s[0]);
  } elsif ($op eq 'FUN') {
    # TODO functions here can have only one argument
    my ($name, $arg_exp) = @s;
    my $arg = $arg_exp->to_value($builtins, $context);
    unless ($arg->kindof eq "CONSTANT") {
      lino_error("Argument to function '$name' is not a constant");
    }
    my $val = $builtins->{$name}->($arg->value);
    return UNIVERSAL::isa($val, 'Value') ? $val : Value::Constant->new($val);
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
  my $result = $expr->substitute_variables([$env, "croak"])->fold_constants();
  if ($result->is_constant) {
    return $result->value;
  } else {
    die "Expression " . $expr->to_str . " did not reduce to a constant";
  }
}

sub _uniq {
  my ($items, $uniq) = @_;
  $uniq ||= sub { "$_[0]" };
  my %h;
  $h{$uniq->($_)} = $_ for @$items;
  return values %h;
}

# XXX Does this properly handle tuples?
# XXX This does not properly handle a[i] and the like
# BEGIN { die "Work here" }
*_list_vars = emap 'list_vars',
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
  my $vars = _list_vars(@_);
  _uniq($vars, sub { $_[0]->to_str });
}

use Name;
*_list_subscript_vars = emap 'list_subscript_vars',
  {
   DEFAULT => sub {
     my ($u, $expr, $op, @v) = @_;
     return [map @$_, @v];
   },
   TUPLE => sub {
     return [map @$_, values %{$_[3]}];
   },
   CON => sub { [] },
   VAR => sub {
     my ($name) = $_[3];
     [$name->subvars];
   },
  };

sub list_subscript_vars {
  my $vars = _list_subscript_vars(@_);
  _uniq($vars, sub { $_[0]->to_str });
}

# Given expression, return pairs (a => b) for each a[b]
*subscript_associations = emap 'subscript_associations',
  {
   CON => sub { [] },
   FUN => sub { $_[4] },
   VAR => sub {
     my ($name) = $_[3];
     [$name->all_subscript_associations];
   },
   DEFAULT => sub {
       my ($u, $expr, $op, @v) = @_;
       [map @$_, @v];
   },
   TUPLE => sub {
       my ($u, $expr, $op, @v) = @_;
       [map @$_, values %{$v[0]}];
   },
   CON => sub { [] },
   STR => sub { [] },
};

# Given expression and bounds, return expression with subscripts of
# names reduced modulo whatever.
*reduce_subscripts = emap 'reduce_subscripts',
    { DEFAULT => sub { shift; my $x = shift;
		       return unless defined($_[1]) && defined($_[2]);
                       $x->new(@_)
                     },
      CON => sub { return $_[1] },
      STR => sub { return $_[1] },
      VAR => sub {
        my ($env, $expr, $VAR, $name) = @_;
	my ($type, $defs) = @$env;
        return $expr unless $name->is_array;
        $name = $name->reduce_subscripts($type, $defs);
        return $name ? $expr->new_var($name) : undef;
      },
      FUN => sub { return $_[1] },
      TUPLE => sub {
        $_[1]->new("TUPLE", $_[3]);
      },
    };



