# Chapter 6 section 2
# Stream.pm


package Stream;
use Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(iterate_function head tail drop promise node
                show filter transform l2s);

sub head {
  my ($s) = @_;
  $s->[0];
}

sub tail {
  my ($s) = @_;
  if (is_promise($s->[1])) {
    $s->[1] = $s->[1]->();
  }
  $s->[1];
}

sub drop {
  my $h = head($_[0]);
  $_[0] = tail($_[0]);
  $h;
}

sub is_promise {
  UNIVERSAL::isa($_[0], 'CODE');
}
sub node {
  my ($h, $t) = @_;
  bless [$h, $t] => Stream;
}
sub promise (&) { $_[0] }
sub upto {
  my ($m, $n) = @_;
  return if $m > $n;
  node($m, promise { upto($m+1, $n) } );
}
sub upfrom {
  my ($m) = @_;
  node($m, promise { upfrom($m+1) } );
}
sub show {
  my ($s, $n) = @_;
  while ($s && (! defined $n || $n-- > 0)) {
    print head($s), $";
    $s = tail($s);
  }
  print $/;
}

1;
sub transform (&$) {
  my $f = shift;
  my $s = shift;
  return undef unless $s;
  node($f->(head($s)),
       promise { transform($f, tail($s)) });
}
sub filter {
  my $f = shift;
  my $s = shift;
  until (! $s || $f->(head($s))) {
    $s = tail($s);
  }
  return if ! $s;
  node(head($s),
       promise { filter($f, tail($s)) });
}
sub iterate_function {
  my ($f, $x) = @_;
  my $s;         
  $s = node($x, promise { &transform($f, $s) });
}

sub  l2s {
  return unless @_;
  my ($h, @t) = @_;
  node($h, promise { l2s(@t) });
}

1;
