
use Test::More tests => 46;
use lib '../lib';
use Expression;
use Name;

my $three = Expression->new('CON', 3);
my $i = Expression->new('VAR', "i");
my $j = Expression->new('VAR', "j");

my $a3 = Name->new(["a", $three]);
my $b3 = Name->new(["b", $three]);
my $ai = Name->new(["a", $i]);
my $bi = Name->new(["b", $j]);

my $n1 = Name->new("s", $a3);
my $n2 = Name->new("s", $b3);
my $n3 = Name->new("s", "t");
my $n4 = Name->new("s", "t", $a3);
my $s1 = Name->new("s", $ai);
my $s2 = Name->new("s", $bi);
my $s3 = Name->new("s", "t", $ai);
my $s4 = Name->new("s", $bi, "t");
my $t1 = Name->new("s", $bi, $ai);
my $t2 = Name->new($bi, $ai, "t");

sub checkname {
  my ($a, $x, $msg) = @_;
  checklist([map $_->to_str, @$a], $x, $msg);
}

checkname([$n1->subvars], []);
checkname([$n2->subvars], []);
checkname([$n3->subvars], []);
checkname([$n4->subvars], []);
checkname([$s1->subvars], ["i"]);
checkname([$s2->subvars], ["j"]);
checkname([$s3->subvars], ["i"]);
checkname([$s4->subvars], ["j"]);
checkname([$t1->subvars], ["i","j"]);
checkname([$t2->subvars], ["i","j"]);

sub checklist {
  my ($avars, $xvars, $msg) = @_;
  my %x;
  my $BAD;
  for (@$xvars) { $x{$_} = 1 }
  for (@$avars) { 
    unless (delete $x{$_}) {
      warn "# spurious item '$_'\n";
      $BAD++;
    }
  }
  for (keys %x) {
    warn "# missing item '$_'\n";
    $BAD++;
  }
  ok(! $BAD, $msg);
}

my $A1 = Expression->new('VAR', $a3);
my $A2 = Expression->new('VAR', $b3);
my $S1 = Expression->new('VAR', $ai);
my $S2 = Expression->new('VAR', $bi);

checklist([map $_->to_str, $A1->list_subscript_vars], []);
checklist([map $_->to_str, $A2->list_subscript_vars], []);
checklist([map $_->to_str, $S1->list_subscript_vars], ["i"]);
checklist([map $_->to_str, $S2->list_subscript_vars], ["j"]);

checkexpr(['*', $A1, $A2], );
checkexpr(['*', $A1, $A1], );
checkexpr(['*', $A2, $A1], );
checkexpr(['*', $A2, $A2], );

checkexpr(['*', $A1, $S2], "j");
checkexpr(['*', $A1, $S1], "i");
checkexpr(['*', $A2, $S1], "i");
checkexpr(['*', $A2, $S2], "j");

checkexpr(['*', $S1, $A2], "i");
checkexpr(['*', $S1, $A1], "i");
checkexpr(['*', $S2, $A1], "j");
checkexpr(['*', $S2, $A2], "j");

checkexpr(['*', $S1, $S2], "i","j");
checkexpr(['*', $S1, $S1], "i");
checkexpr(['*', $S2, $S1], "i","j");
checkexpr(['*', $S2, $S2], "j");

checkexpr(['TUPLE', { x => $A1, y => $A2 }], );
checkexpr(['TUPLE', { x => $A1, y => $A1 }], );
checkexpr(['TUPLE', { x => $A2, y => $A1 }], );
checkexpr(['TUPLE', { x => $A2, y => $A2 }], );

checkexpr(['TUPLE', { x => $A1, y => $S2 }], "j");
checkexpr(['TUPLE', { x => $A1, y => $S1 }], "i");
checkexpr(['TUPLE', { x => $A2, y => $S1 }], "i");
checkexpr(['TUPLE', { x => $A2, y => $S2 }], "j");

checkexpr(['TUPLE', { x => $S1, y => $A2 }], "i");
checkexpr(['TUPLE', { x => $S1, y => $A1 }], "i");
checkexpr(['TUPLE', { x => $S2, y => $A1 }], "j");
checkexpr(['TUPLE', { x => $S2, y => $A2 }], "j");

checkexpr(['TUPLE', { x => $S1, y => $S2 }], "i","j");
checkexpr(['TUPLE', { x => $S1, y => $S1 }], "i");
checkexpr(['TUPLE', { x => $S2, y => $S1 }], "i","j");
checkexpr(['TUPLE', { x => $S2, y => $S2 }], "j");

sub checkexpr {
  my ($expr_args, @xvars) = @_;
  my $expr = Expression->new(@$expr_args);
  my @avars = map $_->to_str, $expr->list_subscript_vars();
  checklist(\@xvars, \@avars, $expr->to_str);
}


