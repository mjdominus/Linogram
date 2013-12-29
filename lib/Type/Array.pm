package Type::Array;
use strict;

sub new {
  my ($class, $base_type, $bounds) = @_;
  unless ($base_type->isa("Type")) {
    Carp::croak("Trying to make an array of type '$base_type', whatever that is");
  }
  unless ($bounds =~ /\d+/) {
    Carp::croak("Trying to make an array of type '" . $base_type->name . "' with bad bounds '$bounds'");
  }

  bless [ $base_type, $bounds ] => $class;
}

sub base_type { $_[0][0] }
sub bounds_expr { $_[0][1] }
sub bounds {
  my ($self, $params) = @_;
  my $bounds_expr = $self->bounds_expr->substitute_variables($params)
                                      ->fold_constants;
  if ($bounds_expr->is_constant) {
    return Bounds->new(0, $bounds_expr->value - 1);
  } else {
    my $name = $self->name;
    Carp::croak("Unspecificied variable(s) in $name\'s bounds");
  }
}

sub my_subchunks {
  my ($self, $params) = @_;
  $params //= {};
  my %subchunks;
  for my $i ($self->bounds($params)->range) {
    $subchunks{"[$i]"} = $self->base_type;
  }
  return %subchunks;
}

sub is_array_type { 1 }
sub is_scalar { 0 }
sub param_values { Environment->new() }

sub name {
  my $self = shift;
  my $base_name = $self->base_type->name;
  my $bounds = $self->bounds_expr->to_str;
  "$base_name\[$bounds]";
}

sub subchunk {
  my ($self, $name, $nocroak) = @_;
  defined($name) ? $self->base_type->subchunk($name, $nocroak) : $self;
}

1;
