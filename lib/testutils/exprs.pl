## my $c = Expression->new_constant(3);
## my @v;
## $v[1] = [map(Expression->new_var($_), qw(a b c d e f g)),
##          map(Expression->new_constant($_), 0..7),
##         ];
##
## sub rselect {
##   my $items = shift;
##   $items->[rand @$items];
## }
##
## sub rop { rselect([qw(+ - * /)]) }
##
## # Build a bunch of random expressions
## for my $n (2 .. 10) {
##   for (1..15) {
##     my $a = 1+int(rand($n-2)); my $b = $n - $a;
##     my $op = rop();
##     push @{$v[$n]}, Expression->new($op, rselect($v[$a]), rselect($v[$b]));
##   }
## }
##
## use Data::Dumper;
## $Data::Dumper::Purity = 1;
##
## print Dumper \@v;
##

# $expr[$n] is a list of 15 different expressions of $n nodes each
@expr = (
          undef,
          [
            bless( [
                     'VAR',
                     'a'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'b'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'c'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'd'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'e'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'f'
                   ], 'Expression' ),
            bless( [
                     'VAR',
                     'g'
                   ], 'Expression' ),
            bless( [
                     'CON',
                     0
                   ], 'Expression' ),
            bless( [
                     'CON',
                     1
                   ], 'Expression' ),
            bless( [
                     'CON',
                     2
                   ], 'Expression' ),
            bless( [
                     'CON',
                     3
                   ], 'Expression' ),
            bless( [
                     'CON',
                     4
                   ], 'Expression' ),
            bless( [
                     'CON',
                     5
                   ], 'Expression' ),
            bless( [
                     'CON',
                     6
                   ], 'Expression' ),
            bless( [
                     'CON',
                     7
                   ], 'Expression' )
          ],
          [
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' )
          ],
          [
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '+',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '-',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '*',
                     [],
                     []
                   ], 'Expression' ),
            bless( [
                     '/',
                     [],
                     []
                   ], 'Expression' )
          ]
        );
$expr[2][0][1] = $expr[1][7];
$expr[2][0][2] = $expr[1][10];
$expr[2][1][1] = $expr[1][13];
$expr[2][1][2] = $expr[1][11];
$expr[2][2][1] = $expr[1][4];
$expr[2][2][2] = $expr[1][3];
$expr[2][3][1] = $expr[1][12];
$expr[2][3][2] = $expr[1][6];
$expr[2][4][1] = $expr[1][2];
$expr[2][4][2] = $expr[1][0];
$expr[2][5][1] = $expr[1][13];
$expr[2][5][2] = $expr[1][14];
$expr[2][6][1] = $expr[1][11];
$expr[2][6][2] = $expr[1][4];
$expr[2][7][1] = $expr[1][9];
$expr[2][7][2] = $expr[1][9];
$expr[2][8][1] = $expr[1][5];
$expr[2][8][2] = $expr[1][9];
$expr[2][9][1] = $expr[1][10];
$expr[2][9][2] = $expr[1][11];
$expr[2][10][1] = $expr[1][1];
$expr[2][10][2] = $expr[1][9];
$expr[2][11][1] = $expr[1][8];
$expr[2][11][2] = $expr[1][0];
$expr[2][12][1] = $expr[1][11];
$expr[2][12][2] = $expr[1][8];
$expr[2][13][1] = $expr[1][3];
$expr[2][13][2] = $expr[1][14];
$expr[2][14][1] = $expr[1][13];
$expr[2][14][2] = $expr[1][6];
$expr[3][0][1] = $expr[1][11];
$expr[3][0][2] = $expr[2][0];
$expr[3][1][1] = $expr[1][1];
$expr[3][1][2] = $expr[2][4];
$expr[3][2][1] = $expr[1][5];
$expr[3][2][2] = $expr[2][10];
$expr[3][3][1] = $expr[1][3];
$expr[3][3][2] = $expr[2][7];
$expr[3][4][1] = $expr[1][5];
$expr[3][4][2] = $expr[2][12];
$expr[3][5][1] = $expr[1][11];
$expr[3][5][2] = $expr[2][13];
$expr[3][6][1] = $expr[1][11];
$expr[3][6][2] = $expr[2][12];
$expr[3][7][1] = $expr[1][0];
$expr[3][7][2] = $expr[2][8];
$expr[3][8][1] = $expr[1][0];
$expr[3][8][2] = $expr[2][10];
$expr[3][9][1] = $expr[1][5];
$expr[3][9][2] = $expr[2][3];
$expr[3][10][1] = $expr[1][8];
$expr[3][10][2] = $expr[2][10];
$expr[3][11][1] = $expr[1][14];
$expr[3][11][2] = $expr[2][6];
$expr[3][12][1] = $expr[1][6];
$expr[3][12][2] = $expr[2][7];
$expr[3][13][1] = $expr[1][1];
$expr[3][13][2] = $expr[2][8];
$expr[3][14][1] = $expr[1][14];
$expr[3][14][2] = $expr[2][1];
$expr[4][0][1] = $expr[2][6];
$expr[4][0][2] = $expr[2][12];
$expr[4][1][1] = $expr[1][11];
$expr[4][1][2] = $expr[3][8];
$expr[4][2][1] = $expr[2][2];
$expr[4][2][2] = $expr[2][13];
$expr[4][3][1] = $expr[1][7];
$expr[4][3][2] = $expr[3][5];
$expr[4][4][1] = $expr[1][3];
$expr[4][4][2] = $expr[3][3];
$expr[4][5][1] = $expr[2][3];
$expr[4][5][2] = $expr[2][4];
$expr[4][6][1] = $expr[2][2];
$expr[4][6][2] = $expr[2][0];
$expr[4][7][1] = $expr[2][0];
$expr[4][7][2] = $expr[2][12];
$expr[4][8][1] = $expr[1][9];
$expr[4][8][2] = $expr[3][2];
$expr[4][9][1] = $expr[2][11];
$expr[4][9][2] = $expr[2][10];
$expr[4][10][1] = $expr[2][3];
$expr[4][10][2] = $expr[2][5];
$expr[4][11][1] = $expr[2][9];
$expr[4][11][2] = $expr[2][0];
$expr[4][12][1] = $expr[2][1];
$expr[4][12][2] = $expr[2][11];
$expr[4][13][1] = $expr[2][8];
$expr[4][13][2] = $expr[2][14];
$expr[4][14][1] = $expr[1][14];
$expr[4][14][2] = $expr[3][8];
$expr[5][0][1] = $expr[1][13];
$expr[5][0][2] = $expr[4][9];
$expr[5][1][1] = $expr[3][6];
$expr[5][1][2] = $expr[2][11];
$expr[5][2][1] = $expr[1][7];
$expr[5][2][2] = $expr[4][1];
$expr[5][3][1] = $expr[1][9];
$expr[5][3][2] = $expr[4][1];
$expr[5][4][1] = $expr[3][12];
$expr[5][4][2] = $expr[2][7];
$expr[5][5][1] = $expr[1][4];
$expr[5][5][2] = $expr[4][8];
$expr[5][6][1] = $expr[1][8];
$expr[5][6][2] = $expr[4][4];
$expr[5][7][1] = $expr[2][14];
$expr[5][7][2] = $expr[3][4];
$expr[5][8][1] = $expr[1][4];
$expr[5][8][2] = $expr[4][12];
$expr[5][9][1] = $expr[3][13];
$expr[5][9][2] = $expr[2][10];
$expr[5][10][1] = $expr[3][9];
$expr[5][10][2] = $expr[2][0];
$expr[5][11][1] = $expr[3][3];
$expr[5][11][2] = $expr[2][4];
$expr[5][12][1] = $expr[3][7];
$expr[5][12][2] = $expr[2][3];
$expr[5][13][1] = $expr[1][1];
$expr[5][13][2] = $expr[4][14];
$expr[5][14][1] = $expr[2][2];
$expr[5][14][2] = $expr[3][3];
$expr[6][0][1] = $expr[2][7];
$expr[6][0][2] = $expr[4][7];
$expr[6][1][1] = $expr[1][11];
$expr[6][1][2] = $expr[5][9];
$expr[6][2][1] = $expr[2][2];
$expr[6][2][2] = $expr[4][1];
$expr[6][3][1] = $expr[4][14];
$expr[6][3][2] = $expr[2][6];
$expr[6][4][1] = $expr[2][4];
$expr[6][4][2] = $expr[4][3];
$expr[6][5][1] = $expr[4][8];
$expr[6][5][2] = $expr[2][14];
$expr[6][6][1] = $expr[1][2];
$expr[6][6][2] = $expr[5][2];
$expr[6][7][1] = $expr[2][7];
$expr[6][7][2] = $expr[4][5];
$expr[6][8][1] = $expr[3][12];
$expr[6][8][2] = $expr[3][0];
$expr[6][9][1] = $expr[3][0];
$expr[6][9][2] = $expr[3][7];
$expr[6][10][1] = $expr[1][9];
$expr[6][10][2] = $expr[5][10];
$expr[6][11][1] = $expr[1][11];
$expr[6][11][2] = $expr[5][3];
$expr[6][12][1] = $expr[3][6];
$expr[6][12][2] = $expr[3][3];
$expr[6][13][1] = $expr[1][5];
$expr[6][13][2] = $expr[5][12];
$expr[6][14][1] = $expr[1][9];
$expr[6][14][2] = $expr[5][7];
$expr[7][0][1] = $expr[5][8];
$expr[7][0][2] = $expr[2][9];
$expr[7][1][1] = $expr[1][4];
$expr[7][1][2] = $expr[6][4];
$expr[7][2][1] = $expr[2][5];
$expr[7][2][2] = $expr[5][4];
$expr[7][3][1] = $expr[5][2];
$expr[7][3][2] = $expr[2][12];
$expr[7][4][1] = $expr[4][7];
$expr[7][4][2] = $expr[3][0];
$expr[7][5][1] = $expr[1][10];
$expr[7][5][2] = $expr[6][5];
$expr[7][6][1] = $expr[2][8];
$expr[7][6][2] = $expr[5][7];
$expr[7][7][1] = $expr[1][10];
$expr[7][7][2] = $expr[6][0];
$expr[7][8][1] = $expr[5][10];
$expr[7][8][2] = $expr[2][4];
$expr[7][9][1] = $expr[4][2];
$expr[7][9][2] = $expr[3][6];
$expr[7][10][1] = $expr[5][13];
$expr[7][10][2] = $expr[2][7];
$expr[7][11][1] = $expr[3][6];
$expr[7][11][2] = $expr[4][8];
$expr[7][12][1] = $expr[1][3];
$expr[7][12][2] = $expr[6][1];
$expr[7][13][1] = $expr[1][1];
$expr[7][13][2] = $expr[6][10];
$expr[7][14][1] = $expr[4][5];
$expr[7][14][2] = $expr[3][7];
$expr[8][0][1] = $expr[1][8];
$expr[8][0][2] = $expr[7][3];
$expr[8][1][1] = $expr[3][2];
$expr[8][1][2] = $expr[5][14];
$expr[8][2][1] = $expr[4][13];
$expr[8][2][2] = $expr[4][9];
$expr[8][3][1] = $expr[3][8];
$expr[8][3][2] = $expr[5][6];
$expr[8][4][1] = $expr[5][0];
$expr[8][4][2] = $expr[3][11];
$expr[8][5][1] = $expr[2][10];
$expr[8][5][2] = $expr[6][14];
$expr[8][6][1] = $expr[1][10];
$expr[8][6][2] = $expr[7][5];
$expr[8][7][1] = $expr[4][5];
$expr[8][7][2] = $expr[4][8];
$expr[8][8][1] = $expr[1][10];
$expr[8][8][2] = $expr[7][6];
$expr[8][9][1] = $expr[2][8];
$expr[8][9][2] = $expr[6][2];
$expr[8][10][1] = $expr[3][13];
$expr[8][10][2] = $expr[5][0];
$expr[8][11][1] = $expr[2][2];
$expr[8][11][2] = $expr[6][12];
$expr[8][12][1] = $expr[3][6];
$expr[8][12][2] = $expr[5][2];
$expr[8][13][1] = $expr[1][0];
$expr[8][13][2] = $expr[7][8];
$expr[8][14][1] = $expr[1][14];
$expr[8][14][2] = $expr[7][6];
$expr[9][0][1] = $expr[3][8];
$expr[9][0][2] = $expr[6][11];
$expr[9][1][1] = $expr[6][1];
$expr[9][1][2] = $expr[3][2];
$expr[9][2][1] = $expr[3][5];
$expr[9][2][2] = $expr[6][11];
$expr[9][3][1] = $expr[3][7];
$expr[9][3][2] = $expr[6][8];
$expr[9][4][1] = $expr[4][1];
$expr[9][4][2] = $expr[5][7];
$expr[9][5][1] = $expr[7][13];
$expr[9][5][2] = $expr[2][11];
$expr[9][6][1] = $expr[4][6];
$expr[9][6][2] = $expr[5][8];
$expr[9][7][1] = $expr[7][7];
$expr[9][7][2] = $expr[2][3];
$expr[9][8][1] = $expr[4][13];
$expr[9][8][2] = $expr[5][7];
$expr[9][9][1] = $expr[5][12];
$expr[9][9][2] = $expr[4][14];
$expr[9][10][1] = $expr[1][6];
$expr[9][10][2] = $expr[8][13];
$expr[9][11][1] = $expr[7][1];
$expr[9][11][2] = $expr[2][3];
$expr[9][12][1] = $expr[3][4];
$expr[9][12][2] = $expr[6][9];
$expr[9][13][1] = $expr[1][9];
$expr[9][13][2] = $expr[8][3];
$expr[9][14][1] = $expr[3][3];
$expr[9][14][2] = $expr[6][8];
$expr[10][0][1] = $expr[3][0];
$expr[10][0][2] = $expr[7][7];
$expr[10][1][1] = $expr[2][12];
$expr[10][1][2] = $expr[8][10];
$expr[10][2][1] = $expr[6][10];
$expr[10][2][2] = $expr[4][13];
$expr[10][3][1] = $expr[1][6];
$expr[10][3][2] = $expr[9][12];
$expr[10][4][1] = $expr[1][11];
$expr[10][4][2] = $expr[9][11];
$expr[10][5][1] = $expr[3][3];
$expr[10][5][2] = $expr[7][0];
$expr[10][6][1] = $expr[4][6];
$expr[10][6][2] = $expr[6][13];
$expr[10][7][1] = $expr[1][1];
$expr[10][7][2] = $expr[9][6];
$expr[10][8][1] = $expr[8][3];
$expr[10][8][2] = $expr[2][7];
$expr[10][9][1] = $expr[5][11];
$expr[10][9][2] = $expr[5][11];
$expr[10][10][1] = $expr[3][14];
$expr[10][10][2] = $expr[7][11];
$expr[10][11][1] = $expr[8][3];
$expr[10][11][2] = $expr[2][9];
$expr[10][12][1] = $expr[1][1];
$expr[10][12][2] = $expr[9][8];
$expr[10][13][1] = $expr[8][1];
$expr[10][13][2] = $expr[2][1];
$expr[10][14][1] = $expr[8][5];
$expr[10][14][2] = $expr[2][13];


1;
