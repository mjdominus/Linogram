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

1;
