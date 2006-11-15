


my $INF = 10000000;

my ($xmin, $xmax, $ymin, $ymax) = ($INF, -$INF, $INF, -$INF);
my $X = 8 * 72;
my $Y = 10 * 72;

sub loc {
  my ($x, $y) = @_;
  $xmin = $x if $x < $xmin;
  $xmax = $x if $x > $xmax;
  $ymin = $y if $y < $ymin;
  $ymax = $y if $y > $ymax;
}

sub draw_line { 
  my $env = shift;
  my ($a, $b, $c, $d) = @{$env}{qw(start.x start.y end.x end.y)};
  $_ *= -1 for $b, $d;
  loc($a, $b);
  loc($c, $d);
  push @LINES, [$a, $b, $c, $d];
}

sub draw_circle { 
  my $env = shift;
  my ($x, $y, $r, $fill) = @{$env}{qw(c.x c.y r fill)};
  $y *= -1;
  loc($x-$r, $y-$r);
  loc($x+$r, $y+$r);
  push @CIRCLES, [$x, $y, $r, 1-$fill];
}

sub put_string {
  my $env = shift;
  my ($x, $y, $text) = @{$env}{qw(x y text)};
  return if $text eq "";
  $y *= -1;
  loc($x, $y);
  push @TEXTS, [$x, $y, $text];
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
    $scale = 72 if $scale > 72;
    $xoff = ($X - $wd * $scale) / 2 + 24;
    $yoff = ($Y - $ht * $scale) / 2 + 24;
  }

#  warn "bb=($xmin, $ymin)-($xmax, $ymax)\n";
#  warn "wd=$wd ht=$ht\nscale=$scale\noffset=($xoff,$yoff)\n";

  header(bb => [24, 24, $wd * $scale + 24, $ht * $scale + 24],
         mode => $mode);
  for my $l (@LINES) {
    my ($a, $b, $c, $d) = @$l;
    $_ = ($_ - $xmin) * $scale + $xoff for $a, $c;
    $_ = ($_ - $ymin) * $scale + $yoff for $b, $d;
    print "$a $b moveto $c $d lineto stroke\n";
  }

  for my $o (@CIRCLES) {
    my ($x, $y, $r, $fill) = @$o;
    $x = ($x - $xmin) * $scale + $xoff;
    $y = ($y - $ymin) * $scale + $yoff;
    $r *= $scale;
    print "$x $y $r 0 360 arc\n";
    if ($fill != 1) { print "  gsave $fill setgray fill grestore\n"; }
    print "  stroke\n";
  }

  for my $l (@TEXTS) {
    my ($x, $y, $text) = @$l;
    $text =~ s/([\\()])/\\$1/g; # escape

    $x = ($x - $xmin) * $scale + $xoff;
    $y = ($y - $ymin) * $scale + $yoff;
    print "/msg ($text) def\n\t$x msg stringwidth pop 2 div sub\n\t$y moveto msg show \n";
  }

  trailer(mode => $mode);
}

sub header {
  my %arg = @_;
  print "%!PS
%%Title: linogram output
%%BoundingBox: @{$arg{bb}}
%%Creator: linogram
/Times findfont 10 scalefont setfont\n";
}

sub trailer {
  my %arg = @_;
  print "showpage\n%%EOF\n";
}

1;

