
use Expression;
use Name;

my $c12 = Expression->new('CON', 12);
my $vi  = Expression->new('VAR', my $ni = Name->new("i"));
my $vj  = Expression->new('VAR', my $nj = Name->new("j"));
my $vbi  = Expression->new('VAR', my $ni = Name->new("b", "i"));
my $vbj  = Expression->new('VAR', my $ni = Name->new("b", "j"));

@names =
  (
   Name->new("fred"),                      # fred
   Name->new(["fred", $c12]),              # fred[12]
   Name->new(["fred", $vi]),               # fred[i]
   Name->new("fred", "x"),                 # fred.x
   Name->new("fred", ["x", $c12]),         # fred.x[12]
   Name->new("fred", ["x", $vi]),          # fred.x[i]
   Name->new(["fred", $c12], "x"),         # fred[12].x
   Name->new(["fred", $c12], ["x", $c12]), # fred[12].x[12]
   Name->new(["fred", $c12], ["x", $vi]),  # fred[12].x[i]
   Name->new(["fred", $vj], "x"),          # fred[j].x
   Name->new(["fred", $vj], ["x", $c12]),  # fred[j].x[12]
   Name->new(["fred", $vj], ["x", $vi]),   # fred[j].x[i]
   Name->new(["fred", $vbi]),               # fred[b.i]
   Name->new("fred", ["x", $vbi]),          # fred.x[b.i]
   Name->new(["fred", $c12], ["x", $vbi]),  # fred[12].x[b.i]
   Name->new(["fred", $vbj], "x"),          # fred[b.j].x
   Name->new(["fred", $vbj], ["x", $c12]),  # fred[b.j].x[12]
   Name->new(["fred", $vbj], ["x", $vbi]),   # fred[b.j].x[b.i]
  );

%parts = (c12 => $c12,
          vi => $vi, vj => $vj,
          ni => $ni, nj => $nj,
          vbi => $vbi, vbj => $vbj,
         );

sub V { Expression->new(N(@_)) }
sub N { Name->new(@_) }

1;
