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
