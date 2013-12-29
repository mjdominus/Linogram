package Type::Array;
use Carp qw(confess croak);
use strict;
use base 'Type';

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

sub is_in_bounds {
  my ($self, $index, $params) = @_;
  $self->bounds($params)->in_bounds($index);
}

sub parent { $_[0]->base_type->parent }

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
sub my_param_defs { $_[0]->base_type->my_param_defs }
sub my_constraint_expressions { $_[0]->base_type->my_constraint_expressions }

sub name {
  my $self = shift;
  my $base_name = $self->base_type->name;
  my $bounds = $self->bounds_expr->to_str;
  "$base_name\[$bounds]";
}

sub subchunk {
  my ($self, $name, $nocroak, $param) = @_;
  return $self unless defined $name;
  $name = Name->new($name) unless ref $name; # convert "a" to N("a")
  my ($first, $rest) = $name->split;

  if (my($n) = $first =~ /\A \[ (\d+) \] \z/x) {
    croak "subscript '$n' out of bounds for array"
      unless $self->is_in_bounds($n, $param);
    return $self->base_type->subchunk($rest, $nocroak, $param);
  } else {
    die("unparseable array subchunk name '$name'; should be [123]");
  }
}

1;
