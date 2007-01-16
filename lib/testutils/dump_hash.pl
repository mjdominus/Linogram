sub dump_hash {
  my $h = shift;
#  my @a = %$h;
#  warn "dump_hash <@a>...\n";
  for my $k (sort keys %$h) {
    print "$k: $h->{$k}\n";
  }
}

1;
