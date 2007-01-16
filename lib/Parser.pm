use strict 'refs';

# Library based on chap09/arith25.pl

package Parser;
our ($nothing, $End_of_Input);

use Exporter;
@EXPORT_OK = qw(lookfor _ $End_of_Input $nothing T error handle_error
                operator star option concatenate alternate
                display_failures labeledblock commalist termilist %N
                parser checkval);
@ISA = 'Exporter';


use Stream 'node', 'head', 'tail', 'promise';
sub debug($);
use overload
                '-' => \&concatenate2,
                '|' => \&alternate2,
                '>>' => \&T,
                '>' => \&V,
                '/' => \&checkval,
                '""' => \&overload::StrVal,
  ;

sub parser (&) { bless $_[0] => __PACKAGE__ }

sub Parser::_ { @_ = [@_]; goto &lookfor }

sub lookfor {
  my $wanted = shift;
  my $value = shift || sub { $_[0][1] };
  my $u = shift;

  $wanted = [$wanted] unless ref $wanted;
  my $parser = parser {
    my $input = shift;
    debug "Looking for token [@$wanted]\n";
    unless (defined $input) {
      debug "Premature end of input\n";
      die ['TOKEN', $input, $wanted];
    }
    my $next = head($input);
    debug "Next token is [@$next]\n";
    for my $i (0 .. $#$wanted) {
      next unless defined $wanted->[$i];
      unless ($wanted->[$i] eq $next->[$i]) {
        debug "Token mismatch\n";
        die ['TOKEN', $input, $wanted];
      }
    }
    my $wanted_value = $value->($next, $u);
    debug "Token matched\n";
    return ($wanted_value, tail($input));
  };

  $N{$parser} = "[@$wanted]";
  return $parser;
}

sub End_of_Input {
  my $input = shift;
  debug "Looking for End of Input\n";
  return (undef, undef) unless defined($input);
  die ["End of input", $input];
}
$End_of_Input = \&End_of_Input;
bless $End_of_Input => __PACKAGE__;
$N{$End_of_Input} = "EOI";

sub nothing {
  my $input = shift;
  debug "Looking for nothing\n";
  if (defined $input) {
    debug "(Next token is @{$input->[0]})\n";
  } else {
    debug "(At end of input)\n";
  }
  return (undef, $input);
}

$nothing = \&nothing;
bless $nothing => __PACKAGE__;
$N{$nothing} = "(nothing)";

sub alternate2 {
  my ($A, $B) = @_;
  alternate($A, $B);
}

my $ALT = 'A';
sub alternate {
  my @p = @_;
  return parser { return () } if @p == 0;
  return $p[0]             if @p == 1;

  my $p;
  $p = parser {
    my $input = shift;
    debug "Looking for $N{$p}\n";
    if (defined $input) {
      debug "(Next token is @{$input->[0]})\n";
    } else {
      debug "(At end of input)\n";
    }
    my ($q, $np) = (0, scalar @p);
    my ($v, $newinput);
    my @failures;
    for (@p) {
      $q++;
      debug "Trying alternative $q/$np\n";
      eval { ($v, $newinput) = $_->($input) };
      if ($@) {
        die unless ref $@;
        debug "Failed alternative $q/$np\n";
        push @failures, $@;
      } else {
        debug "Matched alternative $q/$np\n";
        return ($v, $newinput);
      }
    }
    debug "No alternatives matched in $N{$p}; failing\n";
    die ['ALT', $input, \@failures];
  };
  $N{$p} = "(" . join(" | ", map $N{$_}, @p) . ")";
  return $p;
}

sub concatenate2 {
  my ($A, $B) = @_;
  concatenate($A, $B);
}

my $CON = 'A';
sub concatenate {

  my @p = @_;
  return $nothing if @p == 0;
  return $p[0]  if @p == 1;

  my $p;
  $p = parser {
    my $input = shift;
    debug "Looking for $N{$p}\n";
    if (defined $input) {
      debug "(Next token is @{$input->[0]})\n";
    } else {
      debug "(At end of input)\n";
    }
    my $v;
    my @values;
    my ($q, $np) = (0, scalar @p);
    my @succeeded;
    for (@p) {
      $q++;
      eval { ($v, $input) = $_->($input) };
      if ($@) {
        die unless ref $@;
        die ['CONC', $input, [\@succeeded, $@]];
      } else {
        debug "Matched concatenated component $q/$np\n";
        push @succeeded, $N{$_};
        push @values, $v;
      }
    }
    debug "Finished matching $N{$p}\n";
    while (ref $values[0] eq 'Tuple') {
      splice @values, 0, 1, @{$values[0]};
    }
    return (bless(\@values => Tuple), $input);
  };
  $N{$p} = join " ", map $N{$_}, @p;
  return $p;
}

my $null_tuple = [];
bless $null_tuple => 'Tuple';
sub star {
  my $p = shift;
  my ($p_star, $conc);
  $p_star = alternate(T($conc = concatenate($p, sub { $p_star->($_[0]) }),
                        sub { 
#                          print "STAR($_[0], $_[1])\n";
                          [$_[0], @{$_[1]}] 
                        }),
                      T($nothing,
                        sub { $null_tuple }),
                     );
  $N{$p_star} = "star($N{$p})";
  $N{$conc} = "$N{$p} $N{$p_star}";
  $p_star;
}

sub option {
  my $p = shift;
  $p_opt = alternate($p, $nothing);
  $N{$p_opt} = "option($N{$p})";
  $p_opt;
}

# commalist(p, sep) = p star(sep p) option(sep)
sub commalist {
  my ($p, $separator, $sepstr) = @_;

  if (defined $separator) {
    $sepstr ||= $N{$separator};
  } else {
    $separator ||= lookfor('COMMA');
    $sepstr ||= ", ";
  }

  my $parser = T(concatenate($p,
                             star(T(concatenate($separator, $p),
                                    sub { $_[1] }
                                   )),
                             option($separator)),
                 sub { [$_[0], @{$_[1]}] }
                );


  $N{$parser} = "$N{$p}$sepstr $N{$p}$sepstr ...";
  return $parser;
}

sub termilist {
  my ($p) = shift;
  commalist($p, lookfor('TERMINATOR'), "; ");
}

sub labeledblock {
  my ($label, $contents) = @_;
  my $t;
  my $p = concatenate(concatenate(concatenate($label, 
                                              lookfor('LBRACE'),
                                             ),
                                  $t = star($contents),
                                 ),
                      lookfor('RBRACE'),
                     );
  $N{$p} = "$N{$label} { $N{$t} }";
  T($p, sub { [$_[0], @{$_[2]}] });
}

use Data::Dumper;
# Only suitable for applying to concatenations
sub T {
  my ($parser, $transform) = @_;
#  return $parser;
  my $p = parser {
    my $input = shift;
    my ($value, $newinput) = $parser->($input);
    debug "Transforming value produced by $N{$parser}\n";
    debug "Input to $N{$parser}:  ". Dumper($value);
#    my @values;
#    while (ref($value) eq 'Pair') {
#      unshift @values, $value->[1];
#      $value = $value->[0];
#    }
#    unshift @values, $value;
#    { local $" = ')(';
#      print "Flattened:  (@values)";
#      if (ref $values[0] eq 'ARRAY') { print " [\$v[0] = (@{$values[0]})]" };
#      print "\n";
#    }
#    if (@values == 1 && UNIVERSAL::isa($values[0], 'ARRAY')) { 
#      @values = @{$values[0]};
#    }
    $value = $transform->(@$value);
    debug "Output from $N{$parser}: ". Dumper($value);
    return ($value, $newinput);
  };
  $N{$p} = $N{$parser};
  return $p;
}

sub V {
  my ($parser, $transform) = @_;
#  return $parser;
  my $p = parser {
    my $input = shift;
    my ($value, $newinput) = $parser->($input);
    debug "Vransforming value produced by $N{$parser}\n";
    debug "Input to $N{$parser}:  ". Dumper($value);
    $value = $transform->($value); 
    debug "Output from $N{$parser}: ". Dumper($value);
    return ($value, $newinput);
  };
  $N{$p} = $N{$parser};
  return $p;
}

sub checkval {
  my ($parser, $condition) = @_;
  $label = "$N{$parser} condition";
  return parser {
    my $input = shift;
    my ($val, $newinput) = $parser->($input);
    return ($val, $newinput) if ($condition->($val));
    die ['CONDITION', $label, $val];
  }
}

sub test {
  my $action = shift;
  return parser {
    my $input = shift;
    my $result = $action->($input);
    return $result ? (undef, $input) : ();
  };
}

sub error {
  my ($checker, $continuation) = @_;
  my $p;
  $p = parser {
    my $input = shift;
    debug "Error in $N{$continuation}\n";
    debug "Discarding up to $N{$checker}\n";
    my @discarded;

    while (defined($input)) {
      my $h = head($input);
      if (my (undef, $result) = $checker->($input)) {
        debug "Discarding $N{$checker}\n";
        push @discarded, $N{$checker};
        $input = $result;
        last;
      } else {
        debug "Discarding token [@$h]\n";
        push @discarded, $h->[1];
        drop($input);
      }
    }

    warn "Erroneous input: ignoring '@discarded'\n" if @discarded;
    return unless defined $input;

    debug "Continuing with $N{$continuation} after error recovery\n";
    return $continuation->($input);
  };
  $N{$p} = "errhandler($N{$continuation} -> $N{$checker})";
  return $p;
}


sub handle_error {
  my ($try) = @_;
  my $p;
  $p = parser {
    my $input = shift;
    my @result = eval { $try->($input) };
    if ($@) {
      display_failures($@) if ref $@;
      die;
    }
    return @result;
  };
}

sub debug ($) {
  return unless $ENV{DEBUG};
  my $msg = shift;
  my $i = 0;
  $i++ while caller($i);
  $I = " " x ($i-2);
  $I =~ s/../ |/g;
  print $I, $msg;
}

sub display_failures {
  my ($fail, $depth) = @_;
  $depth ||= 0;
  my $I = "  " x $depth;
  unless (ref $fail) { die $fail }
  my ($type, $position, $data) = @$fail;
  my $pos_desc = "";
  while (length($pos_desc) < 40) {
    if ($position) {
      my $h = head($position);
      $pos_desc .= "[@$h] ";
    } else {
      $pos_desc .= "End of input ";
      last;
    }
    $position = tail($position);
  }
  chop $pos_desc;
  $pos_desc .= "..." if defined $position;

  if ($type eq 'TOKEN') {
    print $I, "Wanted [@$data] instead of '$pos_desc'\n";
  } elsif ($type eq 'End of input') {
    print $I, "Wanted EOI instead of '$pos_desc'\n";
  } elsif ($type eq 'ALT') {
    print $I, ($depth ? "Or any" : "Any"), " of the following:\n";
    for (@$data) {
      display_failures($_, $depth+1);
    }
  } elsif ($type eq 'CONC') {
    my ($succeeded, $subfailure) = @$data;
    print $I, "Following (@$succeeded), got '$pos_desc' instead of:\n";
    display_failures($subfailure, $depth+1);
  } else {
    die "Unknown failure type '$type'\n";
  }
}

sub operator {
  my ($subpart_parser, @ops) = @_;
  my (@alternatives);
  my $opdesc;
  
  for my $op (@ops) {
    my ($operator, $op_func) = @$op;
    my $rest_op;
    push @alternatives,
      $t_rest_op = T($rest_op = concatenate($operator,
                                            $subpart_parser),
                     sub {
                       my $rest = $_[1];
                       sub { $op_func->($_[0], $rest) }
                     });
    $N{$rest_op} = $N{$t_rest_op} = "($N{$operator} $N{$subpart_parser})";
    $opdesc .= "$N{$operator} ";
  }
  chop $opdesc;

  my $alts = alternate(@alternatives);
  $N{$alts} = "some operation {$opdesc} $N{$subpart_parser}";
  
  my $result = 
    T(concatenate($subpart_parser,
                  star($alts)),
      sub { my ($total, $funcs) = @_;
            for my $f (@$funcs) {
              $total = $f->($total);
            }
            $total;
          });
  $N{$result} = "(operations {$opdesc} on $N{$subpart_parser}s)";
  $result;
}


1;
