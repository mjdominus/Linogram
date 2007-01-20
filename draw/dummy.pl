

sub draw_line { 
  my $env = shift;
  print "LINE from ($env->{'start.x'}, $env->{'start.y'}) to ($env->{'end.x'}, $env->{'end.y'})\n";
}

sub put_string {
  my $env = shift;
  print "TEXT '$env->{text}' at ($env->{'x'}, $env->{'y'})\n";
}

sub draw_curve {
  my $env = shift;
  my $N = $env->{N};
  if ($N < 2) { print "CURVE: N=$N\n"; return }

  my @x = map $env->{"control[$_].x"}, 0 .. $N-1;
  my @y = map $env->{"control[$_].y"}, 0 .. $N-1;
  my $s = "CURVE from ($x[0], $y[0])";
  for (1 .. $N-1) {
    $s .= " to ($x[$_], $y[$_])";
  }
  print "$s\n";
}

sub draw_circle {
  my $env = shift;
  print "CIRCLE at ($env->{'c.x'},  $env->{'c.y'}) with radius $env->{'r'}";
  if ($env->{'fill'}) { print $env->{fill} == 1 ? " filled" : " filled ($env->{fill})" }
  print "\n";
}

1;
