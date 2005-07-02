# Suitable for chaining a la chained-lexers.pl
#
# Also supports 'peek';
# Also supports i2s, to turn iterators into streams

package Lexer;
use Exporter;
@ISA = 'Exporter';
@EXPORT = qw(make_lexer i2s);
@EXPORT_OK = qw(tokens);

sub tokens {
  my ($input, $typeid, $terminator) = @_;
  my $maketoken = $_[3] || sub { [$_[1], $_[0] ]};
  my @tokens;
  my $buf = "";   # set to undef to when input is exhausted
  my $split = sub { split /($terminator)/, $_[0] };
  sub {
    while (@tokens == 0 && defined $buf) {
      my $i = $input->();
      if (ref $i) {
        my ($sep, $tok) = $split->($buf);
        $tok = $maketoken->($tok, $typeid) if defined $tok;
        push @tokens, grep $_ ne "", $sep, $tok, $i;
        $buf = "";
        last;
      }

      $buf .= $i if defined $i;
      my @newtoks = $split->($buf);
      while (@newtoks > 2 
             || @newtoks && ! defined $i) {
        push @tokens, shift(@newtoks);
        push @tokens, $maketoken->(shift(@newtoks), $typeid) if @newtoks;
      }
      $buf = join "", @newtoks;
      undef $buf if ! defined $i;
      @tokens = grep $_ ne "", @tokens;
    }
    return $_[0] eq "peek" ? $tokens[0] : shift(@tokens);
  }
}

# Syntactic sugar
sub make_lexer {
  my $lexer = shift;
  while (@_) {
    my $args = shift;
    $lexer = tokens($lexer, @$args);
  }
  $lexer;
}

use Stream 'node', 'promise';
BEGIN { die unless prototype('promise')  eq '&'}

sub i2s {
  my $i = shift;
  my $v = $i->();
  if (defined $v) {
    node($v, promise { i2s($i) });
  } else {
    return;
  }
}


1;
