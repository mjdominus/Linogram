
package Name;
#
# Names:
#  a         ==> ["a"]
#  a.b       ==> ["a", "b"]
#  a[3]      ==> [["a", 3]]
#  a[3].b    ==> [["a", 3], "b"]
#  a.b[3]    ==> ["a", ["b", 3]]
#  a[3].b[3] ==> [["a", 3], ["b", 3]]
#
# Except that instead of 3's, we really have Expression objects

use Expression;

sub new {
  my ($base, @components) = @_;
  my $class = ref($base) || $base;
  for (@components) {		# convert ["a"] to "a"
    $_ = $_->[0] if @$_ == 1;
  }
  bless \@components, $class;
}

sub copy {
  my $self = shift;
  $self->new(map ref($_) ? [@$_] : $_, $self->components);
}

sub is_compound {
  my $self = shift;
  $self->components > 1 || $self->is_array;
}

sub is_simple {
  not $_[0]->is_compound;
}

sub component { $_[0][$_[1]] }

sub first_component { $_[0]->component(0) }
sub last_component { $_[0]->component(-1) }

sub split {
  my $self = shift;
  my ($first, @rest) = $self->components;
  return ($first, @rest ? $self->new(@rest) : undef);
}

sub subscript_expression {
  $_[0]->last_component->[1];
}

sub without_subscript {
  my $self = shift;
  return $self unless $self->is_array;
  my $rv = $self->copy;
  $rv->[-1] = $rv->[-1][0];
  return $rv;
}

sub qualify {
  my ($self, $prefix) = @_;
  $self->new($prefix, map {ref() ? [$_->[0], $_->[1]->qualify($prefix)] : $_} $self->components);
}

sub is_array {
  my $last = $_[0]->last_component;
  ref($last) && @$last == 2;
}

sub components {
  my $self = shift;
  @$self;
}

sub prefixes {
  my $self = shift;
  my @prefixes;
  my @cur_prefix;
  my $n = $self->components;
  for my $i (0 .. $n-1) {
    push @cur_prefix, $self->component($i);
    push @prefixes, $self->new(@cur_prefix);
  }
  return @prefixes;
}

# Given foo.bar.baz, returns foo.bar
# Given foo, returns undef
sub enclosing_prefix {
  my $self = shift;
  my @p = $self->prefixes;
  $p[-2];
}

sub to_str {
  my $self = shift;
  my $name = "";
  my @c = map _component_to_str($_), $self->components;
  join ".", @c;
}

sub _component_to_str {
  my $c = shift;
  return $c unless ref $c;
  my ($name, $subscript) = @$c;
  return $name unless defined $subscript;
  "$name\[" . $subscript->to_str . "]";
}

# List of variables found in subscript expressions in a name
sub subvars {
  my $self = shift;
  my %subvars;
  _uniq([map $_->[1] ? $_->[1]->list_vars : (), $self->components]);
}

sub _uniq {
  my ($items) = @_;
  my %h;
  $h{$_->to_str} = $_ for @$items;
  return values %h;
}

sub all_subscript_associations {
  my $self = shift;
  map $_->subscript_associations, $self->prefixes;
}

sub subscript_associations {
  my $self = shift;
  return unless $self->is_array;
  my $v = $self->without_subscript;
  map [$v, $_], $self->subscript_expression->list_vars;
}

sub substitute_subscripts {
  my ($self, $env) = @_;
  my @new;
  for my $c ($self->components) {
    if (ref $c) {
      push @new, [$c->[0], 
                  $c->[1]->substitute_variables($env)];
    } else {
      push @new, $c;
    }
  }
  return $self->new(@new);
}

# TODO: structure here is very similar to substitute_subscripts
# and perhaps to other methods that apply a per-component 
# transformation.  Abstract this out.
sub reduce_subscripts {
  my ($self, $type, $defs) = @_;
  my @new;
  for my $c ($self->components) {
    if (ref $c) {
      my ($name, $subscript) = @$c;

      my $bounds = $type->bounds_of(Name->new($name), $defs);

      $subscript = $subscript->fold_constants;
      if (! $subscript->is_number || $bounds->in_bounds($subscript->value)) {
	  push @new, [$name, $subscript];
      } else {
        if ($bounds->closed) { 
          my $reduced_subscript = $bounds->modulus($subscript->value);
          push @new, [$name,
                      $subscript->new_constant($reduced_subscript)];
        } else {
          return;
        }
      }

      $type = $type->subchunk($name)->base_type;
      $defs = $defs->subset($name);
    } else {
      push @new, $c;
      $type = $type->subchunk($c);
      $defs = $defs->subset($c);
    }
  }

  return $self->new(@new);
}

1;
