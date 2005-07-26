#!/usr/bin/perl

use Data::Dumper;
$Data::Dumper::Freezer = 'FREEZER';
sub UNIVERSAL::FREEZER { $_[0] }

my @search_path = split /:/, $ENV{LINOGRAM_LIB_DIRS} || ".:./linolib";

#$SIG{__DIE__} = sub {
#  die @_ if $^S && ref $_[0];
#  my $N = 1;
#  warn ">>> $@\n";
#  while (my ($pkg, $file, $line, $sub) = caller($N)) {
#    print "Die trace: $sub in $file at line $line\n"
#      unless $sub eq '(eval)' || $sub =~ /::__ANON__$/;
#    $N++;
#  }
#  die @_;
#};
$|=1;

use lib 'lib';
use strict;

my $verbose;

while (@ARGV && $ARGV[0] =~ /^-(\w)/) {
  my $opt = $1;
  shift;
  if ($opt eq "P") {
    my $file = shift;
    require $file;
  } elsif ($opt eq "v") {
    $verbose++;
  } else {
    usage();
  }
}

use Lexer;
use Parser qw(_ parser star option commalist labeledblock operator %N 
              lookfor $End_of_Input error);

use Equation;
use Chunk;
use Expression;
use Stream 'drop';

my $FILE = shift || die "Usage: $0 [-Pperllib] filename";

my $ROOT_TYPE = Type->new('ROOT');

my $PI = atan2(0, -1);

my %builtins = (sin => sub { sin($_[0] * $PI / 180) },
                cos => sub { cos($_[0] * $PI / 180) },
                sqrt => sub { sqrt($_[0]) },
               );

my %TYPES = ('number' => Type::Scalar->new('number'),
             'string' => Type::Scalar->new('string'),
             'ROOT'   => $ROOT_TYPE,
            );

my @keywords = map [uc($_), qr/\b$_\b/],
  qw(constraints define extends draw param require);

sub lino_lexer {
  my $input = shift;
  i2s(make_lexer($input,
                 ['ENDMARKER',  qr/__END__.*/s,
                  sub {
                    my $s = shift;
                    $s =~ s/^__END__\s*//;
                    ['ENDMARKER', $s]
                  } ],
                 ['STRING', qr/" [^"\n]* "/x,
                   sub {
                     my $s = shift;
                     $s =~ s/^"//;
                     $s =~ s/"$//;
                     ['STRING', $s];
                   }
                 ],
                 @keywords,
                 ['IDENTIFIER', qr/[a-zA-Z_]\w*/],
                 ['NUMBER', qr/(?: \d+ (?: \.\d*)?
                               | \.\d+)
                               (?: [eE]  \d+)? /x ],
                 ['FUNCTION',   qr/&/],
                 ['DOT',        qr/\./],
                 ['COMMA',      qr/,/],
                 ['OP',         qr|[-+*/]|],
                 ['EQUALS',     qr/=/],
                 ['LPAREN',     qr/[(]/],
                 ['RPAREN',     qr/[)]/],
                 ['LBRACE',     qr/[{]/],
                 ['RBRACE',     qr/[}]\n*/],
                 ['TERMINATOR', qr/;\n*/],
                 ['WHITESPACE', qr/\s+/, sub { "" }],
                 ));
}


################################################################

my ($atom, $base_name, $constraint, $constraint_section, $declaration,
    $declarator, $defheader, $definition, $drawable, $draw_section, 
    $expression, $extends, $funapp, $name, $param_spec,
    $perl_code, $program, $require_decl, $term, $tuple, $type, );

my $Atom               = parser { $atom->(@_) };
my $Base_name          = parser { $base_name->(@_) };
my $Constraint         = parser { $constraint->(@_) };
my $Constraint_section = parser { $constraint_section->(@_) };
my $Declaration        = parser { $declaration->(@_) };
my $Declarator         = parser { $declarator->(@_) };
my $Defheader          = parser { $defheader->(@_) };
my $Definition         = parser { $definition->(@_) };
my $Draw_section       = parser { $draw_section->(@_) };
my $Drawable           = parser { $drawable->(@_) };
my $Expression         = parser { $expression->(@_) };
my $Extends            = parser { $extends->(@_) };
my $Funapp             = parser { $funapp->(@_) };
my $Name               = parser { $name->(@_) };
my $Param_Spec         = parser { $param_spec->(@_) };
my $Perl_code          = parser { $perl_code->(@_) };
my $Program            = parser { $program->(@_) };
my $Require_decl       = parser { $require_decl->(@_) };
my $Term               = parser { $term->(@_) };
my $Tuple              = parser { $tuple->(@_) };
my $Type               = parser { $type->(@_) };

@N{$Atom, $Base_name, $Constraint, $Constraint_section, $Declaration,
    $Declarator, $Defheader, $Definition, $Extends, $Draw_section,
    $Drawable, $Expression, $Funapp, $Name, $Param_Spec,
    $Perl_code, $Program, $Require_decl, $Term, $Tuple, $Type} =
qw(atom base_name constraint constraint_section declaration 
   declarator defheader definition extends draw_section 
   drawable expression funapp name param_spec 
   perl_code program require_decl term tuple type);

################################################################

$program = star($Definition 
              | ($Declaration
                 > sub { add_declarations($ROOT_TYPE, $_[0]) })
              )
         - option($Perl_code) - $End_of_Input;

$defheader = _("DEFINE") - _("IDENTIFIER") - $Extends
  >> sub { ["DEFINITION", @_[1,2] ]};

$definition = labeledblock($Defheader, $Declaration)
  >> sub {
     my ($defheader, @declarations) = @_;
     my ($name, $extends) = @$defheader[1,2];
     my $extended_type = (defined $extends) ? $TYPES{$extends} : undef;
     my $new_type;

     if (exists $TYPES{$name}) {
       lino_error("Type '$name' redefined");
     }
     if (defined $extends && ! defined $extended_type) {
       lino_error("Type '$name' extended from unknown type '$extends'");
     }
     $new_type = Type->new($name, $extended_type);

     add_declarations($new_type, @declarations);

     warn "** defined '$name'\n" if $verbose;
     $TYPES{$name} = $new_type;
  };

$extends = option(_("EXTENDS") - _("IDENTIFIER") >> sub { $_[1] }) ;

$declaration = option(_("PARAM")) - $Type
             - commalist($Declarator) - _("TERMINATOR")
                 >> sub { my ($is_param, $type, $decl_list) = @_;
			  unless (exists $TYPES{$type}) {
			    lino_error("Unknown type name '$type' in declaration '@_'\n");
			  }
                          for (@$decl_list) {
                            $_->{TYPE} = $type;
                            $_->{PARAM} = $is_param;
                            check_declarator($TYPES{$type}, $_);
                          }
                          {WHAT => 'DECLARATION',
                           IS_PARAM => $is_param ? 1 : 0,
                           DECLARATORS => $decl_list };
                        }
             | $Constraint_section 
             | $Draw_section
             | $Require_decl
#  | error(_("RBRACE"), $Declaration)
             ;

$declarator = _("IDENTIFIER") 
            - option(_("LPAREN")  - commalist($Param_Spec) - _("RPAREN")
                     >> sub { $_[1] }
                    )
            - option(_("EQUALS") - $Expression >> sub { $_[1] })
  >> sub {
    { WHAT => 'DECLARATOR',
      NAME => $_[0],
      PARAM_SPECS => $_[1],
      EXPR => $_[2],
    };
  };

$param_spec = _("IDENTIFIER") - _("EQUALS") - $Expression
  >> sub {
    { WHAT => "PARAM_SPEC",
      NAME => $_[0],
      EXPR => $_[2],
    }
  }
  ;

#$pdeclarator = _("IDENTIFIER") 
#             - option(_("EQUAL") - $Expression >> sub { $_[1] })
#  >> sub {
#    { WHAT => 'PDECLARATOR',
#      NAME => $_[0],
#      DEFAULT => $_[1],
#    };
#  };

$constraint_section = labeledblock(_("CONSTRAINTS"), $Constraint)
  >> sub { shift;
           { WHAT => 'CONSTRAINTS', CONSTRAINTS => [map @$_, @_] }
         };

$constraint = commalist($Expression, _("EQUALS"), " = ") - _("TERMINATOR")
  >> sub { my ($expr1, @exprs) = @{$_[0]};
           [map Expression->new('-', $expr1, $_), @exprs]
          } ;

$draw_section = labeledblock(_("DRAW"), $Drawable)
  >> sub { shift; { WHAT => 'DRAWABLES', DRAWABLES => [@_] } };

$drawable =
            $Name - _("TERMINATOR")
                >> sub { return { WHAT => 'NAMED_DRAWABLE',
				  NAME => $_[0],
				}
                         }
          | _("FUNCTION") - _("IDENTIFIER") - _("TERMINATOR")
  >> sub { my $ref = \&{$_[1]};
           return { WHAT => 'FUNCTIONAL_DRAWABLE',
                    REF => $ref,
                    NAME => $_[1],
                  };
         };

{
  my %already_loaded;

$require_decl = _("REQUIRE") - _("STRING") - _("TERMINATOR")
  >> sub { my $req_file = $_[1];
           return undef if $already_loaded{$req_file}++;
           warn "Requiring '$req_file'\n" if $verbose;
           my $file = lib_resolve($req_file);
           unless ($file) {
             lino_error("Couldn't find library file '$req_file'");
           }
           unless (do_file($file)) {
             lino_error("Failed while loading '$file'");
           }
           return undef;
         };
}

$expression = operator($Term,
                       [_('OP', '+'), sub { Expression->new('+', @_) } ],
                       [_('OP', '-'), sub { Expression->new('-', @_) } ],
                      );

$term = operator($Atom, 
                       [_('OP', '*'), sub { Expression->new('*', @_) } ],
                       [_('OP', '/'), sub { Expression->new('/', @_) } ],
                );

$atom = $Funapp
      | $Name > sub { Expression->new_var($_[0]) }
      | $Tuple
      | lookfor("NUMBER", sub { Expression->new('CON', $_[0][1]) })
      | lookfor("STRING", sub { Expression->new('STR', $_[0][1]) })
      | _('OP', '-') - $Expression
            >> sub { Expression->new('-', Expression->new('CON', 0), $_[1]) }
      | _("LPAREN") - $Expression - _("RPAREN") >> sub {$_[1]};

$funapp = $Name - _("LPAREN") - $Expression - _("RPAREN")
            >> sub { 
              my $name = $_[0];
              unless (exists $builtins{$name}) {
                lino_error("Unknown function '$name'");
              }
              Expression->new('FUN', $name, $_[2]) 
            }
        ;

$name = $Base_name - star(_("DOT") - _("IDENTIFIER") >> sub { $_[1] })
            >> sub { join(".", $_[0], @{$_[1]}) }
        ;

$base_name = _"IDENTIFIER";

$tuple = _("LPAREN")
       - commalist($Expression) / sub { @{$_[0]} > 1 }
       - _("RPAREN")
  >> sub {
    my ($explist) = $_[1];
    my $N = @$explist;
    my @axis = qw(x y z);
    if ($N == 2 || $N == 3) {
      return Expression->new('TUPLE',
               { map { $axis[$_] => $explist->[$_] } (0 .. $N-1) }
             );
    } else {
      lino_error("$N-tuples are not supported\n");
    }
  } ;


$type = lookfor("IDENTIFIER",
                sub {
#                  print "In lookfor (@{$_[0]})\n";
                  exists($TYPES{$_[0][1]}) || lino_error("Unrecognized type '$_[0][1]'");
                  $_[0][1];
                }
               );

$perl_code = _("ENDMARKER") > sub { warn "Evaling perl code $_[0]\n" if $verbose;
                                    eval $_[0];
                                    die if $@; 
                                  };


################################################################


sub check_types {
  my ($a, $b) = @_;
  $a->meet($b) or
    lino_error("Can't equate type ", $a->name, " with type ", $b->name, "; aborting");
}

my %add_decl = ('DECLARATION' => \&add_subobj_declaration,
                'CONSTRAINTS' => \&add_constraint_declaration,
                'DRAWABLES' => \&add_draw_declaration,
                'DEFAULT' =>  sub {
                  lino_error("Unknown declaration kind '$[1]{WHAT}'");
                },
               );

sub add_declarations {
  my ($type, @declarations) = @_;

  for my $declaration (@declarations) {
    next unless defined $declaration;
    my $decl_kind = $declaration->{WHAT};
    my $func = $add_decl{$decl_kind} || $add_decl{DEFAULT};
    $func->($type, $declaration);
  }
}

sub add_subobj_declaration {
  my ($type, $declaration) = @_;
  my $declarators = $declaration->{DECLARATORS};
  for my $decl (@$declarators) {
    my $name = $decl->{NAME};
    my $decl_type = $decl->{TYPE};
    my $decl_type_obj = $TYPES{$decl_type};
    $type->add_subchunk($name, $decl_type_obj);
    if ($declaration->{IS_PARAM}) {
      $type->add_param_default($name, $decl->{EXPR});
    } elsif (defined $decl->{EXPR}) {
      $type->add_constraints(Expression->new('-', 
                                             Expression->new_var($name),
                                             $decl->{EXPR}));
    }
    for my $pspec (@{$decl->{PARAM_SPECS}}) {
      $type->add_pspec("$name.$pspec->{NAME}", $pspec->{EXPR});
    }
  }
}

sub add_constraint_declaration {
  my ($type, $declaration) = @_;
  $type->add_constraints(@{$declaration->{CONSTRAINTS}});
}

sub add_draw_declaration {
  my ($type, $declaration) = @_;
  my $drawables = $declaration->{DRAWABLES};

  for my $d (@$drawables) {
    my $drawable_type = $d->{WHAT};
    if ($drawable_type eq "NAMED_DRAWABLE") {
      unless ($type->has_subchunk($d->{NAME})) {
        lino_error("Unknown drawable chunk '$d->{NAME}'");
      }
      $type->add_drawable($d->{NAME});
    } elsif ($drawable_type eq "FUNCTIONAL_DRAWABLE") {
      $type->add_drawable($d->{REF});
    } else {
      lino_error("Unknown drawable type '$type'");
    }
  }
} 



################################################################

1;

#while ($tokens) {
#  my $token = drop($tokens);
#  for my $x (@$token) {
#    $x =~ s/\n/\\n/g;
#  }
#  print ">> @$token\n";
#}

do_file($FILE);
$ROOT_TYPE->draw(\%builtins);

sub do_file {
  my $file = shift;
  warn "Using $file\n" if $verbose;
  open my($INPUT), "<", $file or die "$file: $!";
  my $input = sub { read $INPUT, my($buf), 8192 or return; $buf };
  my $tokens = lino_lexer($input);
  my ($result, $leftover) = eval { $program->($tokens) };
  warn "Done with '$file'\n" if $verbose;
  return 1 unless $@;
  print "$file failed: \n";
  Parser::display_failures($@);
  return;
}

sub lib_resolve {
  my $f = shift;
  for my $d (@search_path) {
    return "$d/$f" if -r "$d/$f";
    return "$d/$f.lino" if -r "$d/$f.lino";
  }
  return;
}

sub lino_error {
  die @_;
}

sub check_declarator {
  my ($type, $declarator) = @_;
  for my $pspec (@{$declarator->{PARAM_SPECS}}) {
    my $name = $pspec->{NAME};
    unless ($type->has_subchunk($name)) {
      lino_error("Declaration of '$declarator->{NAME}' specifies unknown parameter '$name' for type '$type->{N}'\n");
    }
  }
}

sub hash2str {
    my %h;
    if (@_ == 1) { %h = %{$_[0]} }
    elsif (@_ % 2 == 0) { %h = @_ }
    else { die "Bad hash passed to hash2str (@_)\n" }
    my @kvp;
    for my $k (sort keys %h) {
	push @kvp, "$k => $h{$k}";
    }
    join ", ", @kvp;
}
