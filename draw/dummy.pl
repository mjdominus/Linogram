

sub draw_line { 
  my $env = shift;
  print "LINE from ($env->{'start.x'}, $env->{'start.y'}) to ($env->{'end.x'}, $env->{'end.y'})\n";
}

1;
