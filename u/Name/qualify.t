
use lib "../lib";
use Name;
use Expression;
use Test::More tests => 2;

my $c12 = Expression->new("CON", 12);
my $i = Expression->new("VAR", Name->new("i"));

{ my $name = Name->new("a", ["b", $c12]);
  my $qname = $name->qualify("foo");
  is($qname->to_str, "foo.a.b[12]");
}

{ my $name = Name->new("a", ["b", $i]);
  my $qname = $name->qualify("foo");
  is($qname->to_str, "foo.a.b[foo.i]");
}
