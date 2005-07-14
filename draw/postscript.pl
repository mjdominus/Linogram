


my $INF = 10000000;

my ($xmin, $xmax, $ymin, $ymax) = ($INF, -$INF, $INF, -$INF);
my $X = 8 * 72;
my $Y = 10 * 72;

sub draw_line { 
  my $env = shift;
  my ($a, $b, $c, $d) = @{$env}{qw(start.x start.y end.x end.y)};
  for ($a, $c) {
    $xmin = $_ if $_ < $xmin;
    $xmax = $_ if $_ > $xmax;
  }
  for ($b, $d) {
    $ymin = $_ if $_ < $ymin;
    $ymax = $_ if $_ > $ymax;
  }
  push @LINES, [$a, $b, $c, $d];
}

END {
  my $wd = $xmax - $xmin;
  my $ht = $ymax - $ymin;
  my $mode = "P";

# Adjust to landscape mode
#  if ($wd > $ht) {
#    $mode = "L";
#    ($X, $Y) = ($Y, $X);
#  }

  my ($scale, $xoff, $yoff);
  { my $xscale = $X / $wd;
    my $yscale = $Y / $ht;
    $scale = $xscale < $yscale ? $xscale : $yscale;
    $xoff = ($X - $wd * $scale) / 2 + 24;
    $yoff = ($Y - $ht * $scale) / 2 + 24;
  }

  warn "wd=$wd ht=$ht\nscale=$scale\noffset=($xoff,$yoff)\n";

  header(bb => [24, 24, $wd * $scale + 24, $ht * $scale + 24],
         mode => $mode);
  for my $l (@LINES) {
    my ($a, $b, $c, $d) = map $_ * $scale, @$l;
    $a += $xoff; $c += $xoff;
    $b += $yoff; $d += $yoff;
    print "$a $b moveto $c $d lineto stroke\n";
  }
  trailer(mode => $mode);
}

sub header {
  my %arg = @_;
  print "%!PS
%%Title: linogram output
%%BoundingBox: @{$arg{bb}}
%%Creator: linogram\n";
}

sub trailer {
  my %arg = @_;
  print "showpage\n%%EOF\n";
}

1;

