package Bounds;

sub new {
  my $class = shift;
  my ($lo, $hi, $closure) = @_;
  defined $hi or Carp::croak("Bounds->new");

  bless [$lo, $hi, $closure] => $class;
}

sub low { $_[0][0] }
sub high { $_[0][1] }
sub closure { $_[0][2] }
sub closed { $_[0]->closure eq "CLOSED" }
sub in_bounds {
  my ($self, $n) = @_;
  $self->low <= $n && $n <= $self->high;
}
# If number is in range, return it.
# else return equivalent number (mod n) that *is* in range
# for example, if bounds are [1..3], then:
# ... -1 0 1 2 3 4 5 6 ...
# ...  2 3 1 2 3 1 2 3 ...
sub modulus {
  my ($self, $n) = @_;
  die "unimplemented" unless $self->low == 0;
  return $n % ($self->high + 1);
}

sub range {
  my $self = shift;
  $self->low .. $self->high;
}

sub to_str {
  "($_[0][0] .. $_[0][1])";
}

1;
