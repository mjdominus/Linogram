
package Environment;

sub new {
  my ($self, %vars) = @_;
  my $class = ref($self) || $self;
  bless \%vars => $class;
}

sub empty {
  my $class = shift;
  $class->new();
}

sub clone { 
  my $self = shift;
  $self->new($self->var_hash);
}

sub qualify {
  my $self = shift;
  my $prefix = shift;
  my %n = map {+"$prefix.$_" => $self->{$_}} keys(%$self);
  $self->new(%n);
}

# Destructive
sub merge {
  my ($self, %new) = @_;
  %$self = (%$self, %new);
  return $self;
}

# Destructive
sub append {
  my ($self, %new) = @_;
  %$self = (%new, %$self);
  return $self;
}

# Destructive
sub merge_env {
  my ($self, $env) = @_;
  $self->merge($env->var_hash);
  return $self;
}

# Destructive
sub append_env {
  my ($self, $env) = @_;
  $self->append($env->var_hash);
  return $self;
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
# XXX BUG HERE: $name might be a single name component like 
# ["x", EXPR(...)], in which case this code doesn't really work
  my $name_str = ref($name) && UNIVERSAL::isa($name, "Name") ? $name->to_str : $name;
  my %result;
  for my $k (keys %$self) {
    my $kk = $k;
    if ($kk =~ s/^\Q$name_str.//) {
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

sub tsort {
  my $self = shift;

  my %h;
  my @vars = $self->vars;
  for (@vars) {
    my $expr = $self->lookup($_);
    my @vars = $expr && UNIVERSAL::isa($expr, 'Expression') ? 
      $expr->list_vars : ();
    # TODO Is ->to_str correct here in this next line? 
    $h{$_} = [grep $self->has_var($_), map $_->to_str, @vars];
  }
  _tsort(\%h);
}

# Like tsort, but for hashes of arrays
# instead of environments of expressions
sub _tsort {
  my $h = shift;
  my %count;
  for my $var (keys %$h) {
    $count{$var} += 0;
    $count{$_}++ for @{$h->{$var}};
  }

  my @order;
  while (%count) {
    my @next = grep $count{$_} == 0, keys %count;
    if (@next == 0) {
#      warn "tsort cycle involves [", join(" ", sort keys %count), "]\n";
      return ();
    }
    push @order, @next;
    for (@next) { 
      delete $count{$_};
      --$count{$_}  for @{$h->{$_}};
    }
  }
  return reverse @order;
}

# Take an environment that maps names to expressions
# and a topological ordering of the names
# and replace each name with its value in each expression in which it appears
# DESTRUCTIVE
sub self_substitute {
  my ($self, $order) = @_;
  $order ||= [$self->tsort];
  for my $var (@$order) {
    for my $k (grep defined($self->{$_}), $self->vars) {
      $self->{$k} = $self->{$k}->substitute_variables($self, $order);
    }
  }
  return $order;
}

sub to_str {
  my $self = shift;
  my @pairs;
  for my $var ($self->vars) {
    my $val = $self->lookup($var);
    $val = $val->to_str if UNIVERSAL::can($val, 'to_str');
    push @pairs, "$var => $val";
  }
  "ENV { " . join(", ", @pairs) . " }";
}

1;
