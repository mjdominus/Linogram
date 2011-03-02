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

1;
