sub dump_hash {
  my $h = shift;
#  my @a = %$h;
#  warn "dump_hash <@a>...\n";
  for my $k (sort keys %$h) {
    my $v = $h->{$k};
    if ($v != 0 && $v =~ /^-?\d*\.\d{7,}$/) {
      $v = sprintf("%.6f", $v);
    }
    print "$k: $v\n";
  }
}

1;
