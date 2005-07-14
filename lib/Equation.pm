
package Equation;
my $Zero;

#use overload ;
#  '+'  => \&add_equations,
#  '-'  => \&subtract_equations,
#  '.'  => \&scale_equation,
#  '""' => \&eqn_to_string,
#  ;

sub new {
  my ($class, %self) = @_;
  $class = ref($class) || $class;
  $self{""} = 0 unless exists $self{""};
  for my $k (keys %self) {
    if ($self{$k} == 0 && $k ne "") { delete $self{$k} }
  }
  bless \%self => $class;
}
BEGIN { $Zero = Equation->new() }

sub qualify {
  my ($self, $prefix) = @_;
  my %q = ("" => $self->constant);
  for my $var ($self->varlist) {
    $q{"$prefix.$var"} = $self->coefficient($var);
  }
  $self->new(%q);
}

sub specify {
  my ($self, $suffix) = @_;
  my %q = ("" => $self->constant);
  for my $var ($self->varlist) {
    $q{"$var.$suffix"} = $self->coefficient($var);
  }
  $self->new(%q);
}

sub duplicate {
  my $self = shift;
  $self->new(%$self);
}

sub a_var {
  my $self = shift;
  my ($var) = $self->varlist;
  $var;
}

sub add_equations {
  my ($a, $b) = @_;

  arithmetic($a, 1, $b, 1);
}

sub subtract_equations {
  my ($a, $b) = @_;

  arithmetic($a, 1, $b, -1);
}

sub scale_equation {
  my ($a, $c) = @_;
  arithmetic($a, $c, $Zero, 0);
}

# First eliminate sufficiently small coefficients
# Make the leading coefficient of the equation into 1
  sub normalize {
    my $self = shift;
    my $var = $self->a_var;
    return unless defined $var;
    %$self = %{$self->scale_equation(1/$self->{$var})};
  }


{ my $EPSILON = 1e-12;
  sub arithmetic {
    my ($a, $ac, $b, $bc) = @_;
    my %new;
    for my $k (keys(%$a), keys %$b) {
      my ($av) = $a->coefficient($k);
      my ($bv) = $b->coefficient($k);
      my $new = $ac * $av + $bc * $bv;
      $new{$k} = abs($new) < $EPSILON ? 0 : $new;
    }
    $a->new(%new);
  }
}

sub to_string {
  my ($e, $v) = @_;
  my @left;
  while (my ($v, $c) = each %$e) {
    next if $v eq "";
    if ($c == 1) { push @left, "+ $v" }
    elsif ($c == -1) { push @left, "- $v" }
    elsif ($c > 0) { push @left, "+ $c$v" }
    else { $c *= -1; push @left, "- $c$v" }
  }
  $left[0] =~ s/^\+ // if @left;
  @left = "0" unless @left;
  my $right = -$e->{''};
  join(" ", @left) . " = $right";
}

# Does the equation have the form "x = 13"?
# If so, return the name of x; if not, return undef
sub defines_var {
  my $self = shift;
  my @keys = keys %$self;
  return unless @keys == 2;
  my $var = $keys[0] || $keys[1];
  return $self->{$var} == 1 ? $var : () ;
}

sub coefficient {
  my ($self, $name) = @_;
  $self->{$name} || 0;
}


# Constant part of an equation
sub constant {
  $_[0]->coefficient("");
}

# List of names of all variables used in an equation
sub varlist {
  my $self = shift;
  grep $_ ne "", keys %$self;
}

# We have S:  s + s1 v1 + s2 v2 + ...
#    and  T:  t + t1 v1 + t2 v2 + ...
# Eliminate $var from S, modifying it in place,
# by substituting in some other expression that involves $var
# Do this by setting S -= s1/t1 T
sub substitute_for {
  my ($self, $var, $value) = @_;
  my $left = $self->coefficient($var);
  return if $left == 0;
  my $right = $value->coefficient($var);
  die "Oh NO" if $right == 0;  # Should never happen

  my $result = arithmetic($self, 1, $value, -$left/$right);
  %$self = %$result;
}

# Probably you should only invoke this if
# $self->will_be_reduced_by($param)
sub reduce_by {
  my ($self, $param) = @_;
  my $v = $param->a_var;
  $self->substitute_for($v, $param);
}

sub will_be_reduced_by {
  my ($self, $param) = @_;
  my $pv = $param->a_var;
  $self->coefficient($pv) != 0;
}

# No variables and a nonzero constant part means it's inconsistent
sub is_inconsistent {
  my $self = shift;
  return $self->constant != 0 && $self->varlist == 0;
}

# No variables and a zero constant part means it's tautological
sub is_tautology {
  my $self = shift;
  return $self->constant == 0 && $self->varlist == 0;
}

################################################################
################################################################

package Equation::System;

sub new {
  my ($base, @eqns) = @_;
  my $class = ref $base || $base;
  bless \@eqns => $class;
}

sub adjoin {
  my ($self, $eqns) = @_;
  push @$self, @$eqns;
}

sub equations {
  my $self = shift;
  grep defined, @$self;
}

# Two equations are in the same group if they have a variable in common
# We can treat each group as a separate system to be solved
# This speeds up solving and improves handling of inconsistent equations
sub equation_groups {
  my $self = shift;
  my @groups;

  if ($ENV{DEBUG_EQNS}) {
    print "Complete system:\n";
    $self->print_system(">    ");
    print "----\n";
  }

  my %n; # Maps variable names to lists of equations that use them
  for my $eq ($self->equations) {
    for my $v ($eq->varlist) {
      push @{$n{$v}}, $eq;
    }
  }

  my %todo = map {$_ => $_} $self->equations;

  while (%todo) {
    my ($eq1) = values %todo; # select an equation arbitrarily
    my @queue = $eq1; # list of equations that might be in the current group
    my @group = ();  # Current group of equations
    while (@queue) {
      my $eq = pop @queue;
      next unless delete $todo{$eq}; # skip if already did this eqn
      push @group, $eq; # this equation is in the current group

      # For each var in the current equation, add all equations 
      # containing that var to the queue
      for my $v ($eq->varlist) {
        push @queue, @{delete $n{$v}};
      }
    }
    push @groups, $self->new(@group);
  }

  return @groups;
}

# The value given to a specific variable by a system of equations,
# or undef if it is indeterminate
sub value_of {
  my ($self, $var) = @_;
  $self->solve;
  for my $eqn ($self->equations) {
    if ($eqn->defines_var eq $var) {
      return -$eqn->constant;
    }
  }
  return;
}

sub discard {
  my ($self, $n) = @_;
  die "$n out of range in discard()\n" if $n < 0 || $n > $#$self;
  undef $self->[$n];
}

sub solve {
  my $self = shift;
  my $DEBUG = $ENV{DEBUG_EQNS};
  $self->print_system if $DEBUG;
  my $N = my @E = $self->equations;
  my $equations = $N == 1 ? "equation" : "equations";
  warn "Solving $N $equations\n" if $DEBUG;
  for my $i (0 .. $N-1) {
    next unless defined $E[$i];
    my $var = $E[$i]->a_var;
    for my $j (0 .. $N-1) {
      next if $i == $j;
      next unless defined $E[$j];
      next unless $E[$j]->coefficient($var);
      print "Reducing ", $E[$j]->to_string,
        " with ", $E[$i]->to_string, "\n"
          if $DEBUG;
      $E[$j]->substitute_for($var, $E[$i]);
      print "  Result: ", $E[$j]->to_string, "\n"
        if $DEBUG;
      if ($E[$j]->is_inconsistent) { # print "*** Inconsistent equations\n";
        warn "Equation " . $E[$i]->to_string . " failed.\n";
        return;
      }
      elsif ($E[$j]->is_tautology) { 
        print "Equation $j is now a tautology\n"
          if $DEBUG;
        $self->discard($j);
        undef $E[$j]; 
      }
      $self->print_system(),   print "----------\n" if $DEBUG;
    }
  }
  $self->normalize;
  return 1;
}

sub osolve {
  my $self = shift;
  my $N = my @E = $self->equations;
  warn "Solving $N equations\n";
  my $reducing = 1;
  while ($reducing) {
    $reducing = 0;
    for my $i (0 .. $N-1) {
      next unless defined $E[$i];
      for my $j (0 .. $N-1) {
        next if $i == $j;
        next unless defined $E[$j];
        if ($E[$i]->will_be_reduced_by($E[$j])) {
          $reducing = 1;
#          print "Reducing ", $E[$i]->to_string, 
#            " with ", $E[$j]->to_string, "\n";
          $E[$i]->reduce_by($E[$j]);
#          print "  Result: ", $E[$i]->to_string, "\n";
          if ($E[$i]->is_inconsistent) { # print "*** Inconsistent equations\n";
                                         return ;
                                       }
          elsif ($E[$i]->is_tautology) { 
#            print "Equation $i is now a tautology\n";
            undef $E[$i]; 
            $self->discard($i);
            last;
          }
#          $self->print_system();
#          print "----------\n";
        }
      }
    }
  }
  $self->normalize;
  return 1;
}

# Make the leading coefficient of each equation into 1
sub normalize {
  my $self = shift;
  $self->apply(sub { $_[0]->normalize});
}

sub apply {
  my ($self, $func) = @_;
  for my $e ($self->equations) {
    $func->($e);
  }
}

sub values {
  my $self = shift;
  my $DEBUG = $ENV{DEBUG_EQNS};
  my %values;
  my @DIAG;
  my @groups = $self->equation_groups;
  my $groups = @groups == 1 ? "group" : "groups";
  warn "Equations fall into " . @groups . " $groups.\n"
    if $DEBUG;
  for my $group (@groups) {
    unless ($group->solve) {
      warn "Inconsistent group\n" if $DEBUG;
      next;
    }
    for my $eqn ($group->equations) {
      if (my $name = $eqn->defines_var) {
        $values{$name} = -$eqn->constant;
        push @DIAG, "$name = $values{$name}";
      }
    }
  }
  warn "* Solutions: ", join("\n", sort @DIAG), "\n" if $DEBUG;
  %values;
}

sub print_system {
  my ($self, $prefix) = @_;
  $prefix = "* " unless defined $prefix;
  for ($_[0]->equations) {
    print STDERR $prefix, $_->to_string, "\n";
  }
}

1;
