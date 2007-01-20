


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
  loc($a, $b);
  loc($c, $d);
  push @LINES, [$a, $b, $c, $d];
}

sub draw_circle { 
  my $env = shift;
  my ($x, $y, $r, $fill) = @{$env}{qw(c.x c.y r fill)};
  loc($x-$r, $y-$r);
  loc($x+$r, $y+$r);
  push @CIRCLES, [$x, $y, $r, 1-$fill];
}

sub put_string {
  my $env = shift;
  my ($x, $y, $text) = @{$env}{qw(x y text)};
  return if $text eq "";
  loc($x, $y);  # Doesn't correctly allow for text size
  push @TEXTS, [$x, $y, $text];
}

sub draw_curve {
  my $env = shift;
  defined(my $N = $env->{N}) or return;
  if ($N < 2) { return }

  my @p = map [$env->{"control[$_].x"},
               $env->{"control[$_].y"},
              ], 0 .. $N-1;
  loc($_->[0], $_->[1]) for @p;

  if ($N == 2) {
    push @LINES, [$p[0][0], $p[0][1],
                  $p[1][0], $p[1][1],
                 ];
    return;
  }

  # At least three control points
  my @spline = ($p[0]);
  for my $i (1 .. $#p-2) {
    my ($pix, $piy) = @{$p[$i]};
    my ($pjx, $pjy) = @{$p[$i+1]};
    push @spline, [$pix, $piy, $pix, $piy, ($pix+$pjx)/2, ($piy+$pjy)/2];
  }
  push @spline, [$p[-2][0], $p[-2][1], $p[-2][0], $p[-2][1], $p[-1][0], $p[-1][1]];
  push @SPLINES, \@spline;
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
    print "newpath $x $y $r 0 360 arc\n";
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

  for my $spline (@SPLINES) {
    my $init = shift @$spline;
    $_ = ($_ - $xmin) * $scale + $xoff for $init->[0];
    $_ = ($_ - $ymin) * $scale + $yoff for $init->[1];
    print "newpath @$init moveto\n";
    for my $next_point (@$spline) {
      for my $i (0 .. $#$next_point) {
        for ($next_point->[$i]) {
          if ($i % 2 == 0) {
            $_ = ($_ - $xmin) * $scale + $xoff;
          } else {
            $_ = ($_ - $ymin) * $scale + $yoff;
          }
        }
      }
      print "  @$next_point curveto\n";
    }
    print "  stroke\n";
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

