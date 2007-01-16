

sub draw_line { 
  my $env = shift;
  print "LINE from ($env->{'start.x'}, $env->{'start.y'}) to ($env->{'end.x'}, $env->{'end.y'})\n";
}

sub put_string {
  my $env = shift;
  print "TEXT '$env->{text}' at ($env->{'x'}, $env->{'y'})\n";
}

1;
