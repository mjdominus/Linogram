
package Type::Scalar;
@Type::Scalar::ISA = 'Type';

sub is_scalar { 1 }

sub add_constraint {
  die "Added constraint to scalar type";
}

sub add_subchunk {
  die "Added subchunk to scalar type";
}

sub drawables { () }   # Numbers don't have drawables

sub all_leaf_subchunks { "" } # They are themselves leaves

# Qualification is a little different, owing only to the
# fact that the empty string has a special meaning in a constraint
sub qualified_synthetic_constraints {
  my ($self, $name) = @_;
  Synthetic_Constraint_Set->new
      ("" =>
       Constraint->new($name => 1)
      );
}

1;
