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
                    Name->new('a')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('b')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('c')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('d')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('e')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('f')
                   ], 'Expression' ),
            bless( [
                     'VAR',
                    Name->new('g')
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

__DATA__

Here's what is in those variables

$expr[1][0] = a
$expr[1][1] = b
$expr[1][2] = c
$expr[1][3] = d
$expr[1][4] = e
$expr[1][5] = f
$expr[1][6] = g
$expr[1][7] = 0
$expr[1][8] = 1
$expr[1][9] = 2
$expr[1][10] = 3
$expr[1][11] = 4
$expr[1][12] = 5
$expr[1][13] = 6
$expr[1][14] = 7
$expr[2][0] = (0 * 3)
$expr[2][1] = (6 + 4)
$expr[2][2] = (e * d)
$expr[2][3] = (5 / g)
$expr[2][4] = (c + a)
$expr[2][5] = (6 / 7)
$expr[2][6] = (4 / e)
$expr[2][7] = (2 - 2)
$expr[2][8] = (f - 2)
$expr[2][9] = (3 + 4)
$expr[2][10] = (b + 2)
$expr[2][11] = (1 - a)
$expr[2][12] = (4 - 1)
$expr[2][13] = (d / 7)
$expr[2][14] = (6 - g)
$expr[3][0] = (4 * (0 * 3))
$expr[3][1] = (b + (c + a))
$expr[3][2] = (f / (b + 2))
$expr[3][3] = (d / (2 - 2))
$expr[3][4] = (f - (4 - 1))
$expr[3][5] = (4 + (d / 7))
$expr[3][6] = (4 + (4 - 1))
$expr[3][7] = (a - (f - 2))
$expr[3][8] = (a + (b + 2))
$expr[3][9] = (f - (5 / g))
$expr[3][10] = (1 / (b + 2))
$expr[3][11] = (7 - (4 / e))
$expr[3][12] = (g / (2 - 2))
$expr[3][13] = (b - (f - 2))
$expr[3][14] = (7 / (6 + 4))
$expr[4][0] = ((4 / e) - (4 - 1))
$expr[4][1] = (4 + (a + (b + 2)))
$expr[4][2] = ((e * d) / (d / 7))
$expr[4][3] = (0 * (4 + (d / 7)))
$expr[4][4] = (d - (d / (2 - 2)))
$expr[4][5] = ((5 / g) - (c + a))
$expr[4][6] = ((e * d) * (0 * 3))
$expr[4][7] = ((0 * 3) / (4 - 1))
$expr[4][8] = (2 * (f / (b + 2)))
$expr[4][9] = ((1 - a) * (b + 2))
$expr[4][10] = ((5 / g) + (6 / 7))
$expr[4][11] = ((3 + 4) / (0 * 3))
$expr[4][12] = ((6 + 4) - (1 - a))
$expr[4][13] = ((f - 2) * (6 - g))
$expr[4][14] = (7 * (a + (b + 2)))
$expr[5][0] = (6 / ((1 - a) * (b + 2)))
$expr[5][1] = ((4 + (4 - 1)) - (1 - a))
$expr[5][2] = (0 - (4 + (a + (b + 2))))
$expr[5][3] = (2 - (4 + (a + (b + 2))))
$expr[5][4] = ((g / (2 - 2)) * (2 - 2))
$expr[5][5] = (e / (2 * (f / (b + 2))))
$expr[5][6] = (1 * (d - (d / (2 - 2))))
$expr[5][7] = ((6 - g) + (f - (4 - 1)))
$expr[5][8] = (e - ((6 + 4) - (1 - a)))
$expr[5][9] = ((b - (f - 2)) * (b + 2))
$expr[5][10] = ((f - (5 / g)) + (0 * 3))
$expr[5][11] = ((d / (2 - 2)) / (c + a))
$expr[5][12] = ((a - (f - 2)) * (5 / g))
$expr[5][13] = (b * (7 * (a + (b + 2))))
$expr[5][14] = ((e * d) / (d / (2 - 2)))
$expr[6][0] = ((2 - 2) - ((0 * 3) / (4 - 1)))
$expr[6][1] = (4 / ((b - (f - 2)) * (b + 2)))
$expr[6][2] = ((e * d) + (4 + (a + (b + 2))))
$expr[6][3] = ((7 * (a + (b + 2))) - (4 / e))
$expr[6][4] = ((c + a) - (0 * (4 + (d / 7))))
$expr[6][5] = ((2 * (f / (b + 2))) / (6 - g))
$expr[6][6] = (c * (0 - (4 + (a + (b + 2)))))
$expr[6][7] = ((2 - 2) / ((5 / g) - (c + a)))
$expr[6][8] = ((g / (2 - 2)) * (4 * (0 * 3)))
$expr[6][9] = ((4 * (0 * 3)) / (a - (f - 2)))
$expr[6][10] = (2 + ((f - (5 / g)) + (0 * 3)))
$expr[6][11] = (4 + (2 - (4 + (a + (b + 2)))))
$expr[6][12] = ((4 + (4 - 1)) + (d / (2 - 2)))
$expr[6][13] = (f - ((a - (f - 2)) * (5 / g)))
$expr[6][14] = (2 + ((6 - g) + (f - (4 - 1))))
$expr[7][0] = ((e - ((6 + 4) - (1 - a))) * (3 + 4))
$expr[7][1] = (e + ((c + a) - (0 * (4 + (d / 7)))))
$expr[7][2] = ((6 / 7) - ((g / (2 - 2)) * (2 - 2)))
$expr[7][3] = ((0 - (4 + (a + (b + 2)))) * (4 - 1))
$expr[7][4] = (((0 * 3) / (4 - 1)) + (4 * (0 * 3)))
$expr[7][5] = (3 / ((2 * (f / (b + 2))) / (6 - g)))
$expr[7][6] = ((f - 2) - ((6 - g) + (f - (4 - 1))))
$expr[7][7] = (3 / ((2 - 2) - ((0 * 3) / (4 - 1))))
$expr[7][8] = (((f - (5 / g)) + (0 * 3)) - (c + a))
$expr[7][9] = (((e * d) / (d / 7)) + (4 + (4 - 1)))
$expr[7][10] = ((b * (7 * (a + (b + 2)))) / (2 - 2))
$expr[7][11] = ((4 + (4 - 1)) / (2 * (f / (b + 2))))
$expr[7][12] = (d / (4 / ((b - (f - 2)) * (b + 2))))
$expr[7][13] = (b + (2 + ((f - (5 / g)) + (0 * 3))))
$expr[7][14] = (((5 / g) - (c + a)) - (a - (f - 2)))
$expr[8][0] = (1 + ((0 - (4 + (a + (b + 2)))) * (4 - 1)))
$expr[8][1] = ((f / (b + 2)) / ((e * d) / (d / (2 - 2))))
$expr[8][2] = (((f - 2) * (6 - g)) + ((1 - a) * (b + 2)))
$expr[8][3] = ((a + (b + 2)) - (1 * (d - (d / (2 - 2)))))
$expr[8][4] = ((6 / ((1 - a) * (b + 2))) / (7 - (4 / e)))
$expr[8][5] = ((b + 2) * (2 + ((6 - g) + (f - (4 - 1)))))
$expr[8][6] = (3 / (3 / ((2 * (f / (b + 2))) / (6 - g))))
$expr[8][7] = (((5 / g) - (c + a)) * (2 * (f / (b + 2))))
$expr[8][8] = (3 * ((f - 2) - ((6 - g) + (f - (4 - 1)))))
$expr[8][9] = ((f - 2) - ((e * d) + (4 + (a + (b + 2)))))
$expr[8][10] = ((b - (f - 2)) - (6 / ((1 - a) * (b + 2))))
$expr[8][11] = ((e * d) + ((4 + (4 - 1)) + (d / (2 - 2))))
$expr[8][12] = ((4 + (4 - 1)) / (0 - (4 + (a + (b + 2)))))
$expr[8][13] = (a * (((f - (5 / g)) + (0 * 3)) - (c + a)))
$expr[8][14] = (7 + ((f - 2) - ((6 - g) + (f - (4 - 1)))))
$expr[9][0] = ((a + (b + 2)) * (4 + (2 - (4 + (a + (b + 2))))))
$expr[9][1] = ((4 / ((b - (f - 2)) * (b + 2))) / (f / (b + 2)))
$expr[9][2] = ((4 + (d / 7)) * (4 + (2 - (4 + (a + (b + 2))))))
$expr[9][3] = ((a - (f - 2)) + ((g / (2 - 2)) * (4 * (0 * 3))))
$expr[9][4] = ((4 + (a + (b + 2))) / ((6 - g) + (f - (4 - 1))))
$expr[9][5] = ((b + (2 + ((f - (5 / g)) + (0 * 3)))) + (1 - a))
$expr[9][6] = (((e * d) * (0 * 3)) - (e - ((6 + 4) - (1 - a))))
$expr[9][7] = ((3 / ((2 - 2) - ((0 * 3) / (4 - 1)))) + (5 / g))
$expr[9][8] = (((f - 2) * (6 - g)) / ((6 - g) + (f - (4 - 1))))
$expr[9][9] = (((a - (f - 2)) * (5 / g)) - (7 * (a + (b + 2))))
$expr[9][10] = (g - (a * (((f - (5 / g)) + (0 * 3)) - (c + a))))
$expr[9][11] = ((e + ((c + a) - (0 * (4 + (d / 7))))) / (5 / g))
$expr[9][12] = ((f - (4 - 1)) - ((4 * (0 * 3)) / (a - (f - 2))))
$expr[9][13] = (2 / ((a + (b + 2)) - (1 * (d - (d / (2 - 2))))))
$expr[9][14] = ((d / (2 - 2)) + ((g / (2 - 2)) * (4 * (0 * 3))))
$expr[10][0] = ((4 * (0 * 3)) - (3 / ((2 - 2) - ((0 * 3) / (4 - 1)))))
$expr[10][1] = ((4 - 1) / ((b - (f - 2)) - (6 / ((1 - a) * (b + 2)))))
$expr[10][2] = ((2 + ((f - (5 / g)) + (0 * 3))) / ((f - 2) * (6 - g)))
$expr[10][3] = (g / ((f - (4 - 1)) - ((4 * (0 * 3)) / (a - (f - 2)))))
$expr[10][4] = (4 - ((e + ((c + a) - (0 * (4 + (d / 7))))) / (5 / g)))
$expr[10][5] = ((d / (2 - 2)) / ((e - ((6 + 4) - (1 - a))) * (3 + 4)))
$expr[10][6] = (((e * d) * (0 * 3)) - (f - ((a - (f - 2)) * (5 / g))))
$expr[10][7] = (b - (((e * d) * (0 * 3)) - (e - ((6 + 4) - (1 - a)))))
$expr[10][8] = (((a + (b + 2)) - (1 * (d - (d / (2 - 2))))) + (2 - 2))
$expr[10][9] = (((d / (2 - 2)) / (c + a)) / ((d / (2 - 2)) / (c + a)))
$expr[10][10] = ((7 / (6 + 4)) - ((4 + (4 - 1)) / (2 * (f / (b + 2)))))
$expr[10][11] = (((a + (b + 2)) - (1 * (d - (d / (2 - 2))))) / (3 + 4))
$expr[10][12] = (b * (((f - 2) * (6 - g)) / ((6 - g) + (f - (4 - 1)))))
$expr[10][13] = (((f / (b + 2)) / ((e * d) / (d / (2 - 2)))) * (6 + 4))
$expr[10][14] = (((b + 2) * (2 + ((6 - g) + (f - (4 - 1))))) / (d / 7))
