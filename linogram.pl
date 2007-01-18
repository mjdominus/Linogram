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

my ($verbose, $outputdir) = @_;

while (@ARGV && $ARGV[0] =~ /^-(\w)/) {
  my $opt = $1;
  shift;
  if ($opt eq "P") {
    my $file = shift;
    require $file;
  } elsif ($opt eq "v") {
    $verbose++;
  } elsif ($opt eq "o") {
    $outputdir = shift;
    require Data::Dumper;
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
use Name;
use Stream 'drop';

my $FILE = shift || die "Usage: $0 [-Pperllib] filename";

my $ROOT_TYPE = Type->new('ROOT');

my $PI = atan2(0, -1);

my %builtins = (sin => sub { sin($_[0] * $PI / 180) },
                cos => sub { cos($_[0] * $PI / 180) },
                sqrt => sub { sqrt($_[0]) },
                cis => sub { my $a = shift() * $PI / 180;
                             Value::Tuple->new_const_vals(x => cos($a),
                                                          y => sin($a),
                                                         )
                             },
               );

our %TYPES = ('number' => Type::Scalar->new('number'),
              'index' => Type::Scalar->new('index'),
              'string' => Type::Scalar->new('string'),
              'ROOT'   => $ROOT_TYPE,
             );

my @keywords = map [uc($_), qr/\b$_\b/],
  qw(closed constraints define draw extends open param require);

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
                 ['FLOAT', qr/(?: \d+\.\d*
                                   | \.\d+)
                              (?: [eE]  \d+)? /x ],
                 ['INTEGER', qr/\d+ (?: [eE]  \d+)? /x ],
                 ['FUNCTION',   qr/&/],
                 ['DOT',        qr/\./],
                 ['COMMA',      qr/,/],
                 ['OP',         qr|[-+*/]|],
                 ['EQUALS',     qr/=/],
                 ['LPAREN',     qr/[(]/],
                 ['RPAREN',     qr/[)]/],
                 ['LBRACK',     qr/\[/],
                 ['RBRACK',     qr/\]/],
                 ['LBRACE',     qr/[{]/],
                 ['RBRACE',     qr/[}]\n*/],
                 ['TERMINATOR', qr/;\n*/],
                 ['WHITESPACE', qr/\s+/, sub { "" }],
                 ));
}


################################################################

my ($atom, $closure, $constraint, $constraint_section, $declaration,
    $declarator, $declarator_single, $declarator_array, 
    $defheader, $definition, $drawable, $draw_section, 
    $expression, $extends, $funapp, $name, $name_component, $number, 
    $param_spec, $perl_code, $program, $require_decl, $subscript, 
    $term, $tuple, $type, );

my $Atom               = parser { $atom->(@_) };
my $Closure            = parser { $closure->(@_) };
my $Constraint         = parser { $constraint->(@_) };
my $Constraint_section = parser { $constraint_section->(@_) };
my $Declaration        = parser { $declaration->(@_) };
my $Declarator         = parser { $declarator->(@_) };
my $Declarator_array   = parser { $declarator_array->(@_) };
my $Declarator_single  = parser { $declarator_single->(@_) };
my $Defheader          = parser { $defheader->(@_) };
my $Definition         = parser { $definition->(@_) };
my $Draw_section       = parser { $draw_section->(@_) };
my $Drawable           = parser { $drawable->(@_) };
my $Expression         = parser { $expression->(@_) };
my $Extends            = parser { $extends->(@_) };
my $Funapp             = parser { $funapp->(@_) };
my $Name               = parser { $name->(@_) };
my $Name_component     = parser { $name_component->(@_) };
my $Number             = parser { $number->(@_) };
my $Param_Spec         = parser { $param_spec->(@_) };
my $Perl_code          = parser { $perl_code->(@_) };
my $Program            = parser { $program->(@_) };
my $Require_decl       = parser { $require_decl->(@_) };
my $Subscript          = parser { $subscript->(@_) };
my $Term               = parser { $term->(@_) };
my $Tuple              = parser { $tuple->(@_) };
my $Type               = parser { $type->(@_) };


@N{$Atom,$Constraint, $Constraint_section, $Declaration, $Declarator,
     $Declarator_array, $Declarator_single, $Defheader, $Definition,
     $Extends, $Draw_section, $Drawable, $Expression, $Funapp, $Name,
     $Name_component, $Number, $Param_Spec, $Perl_code, $Program,
     $Require_decl, $Subscript, $Term, $Tuple, $Type} =
qw(atom constraint constraint_section declaration declarator
   declarator_array declarator_single defheader definition extends
   draw_section drawable expression funapp name name_component number
   param_spec perl_code program require_decl subscript term tuple
   type);

################################################################

$program = star($Definition 
              | ($Declaration
                 > sub { add_declarations($ROOT_TYPE, $_[0]) })
              )
         - option($Perl_code) - $End_of_Input;

$defheader = _("DEFINE") - _("IDENTIFIER") - $Closure - $Extends
  >> sub { ["DEFINITION", @_[1,2,3] ]};

$definition = labeledblock($Defheader, $Declaration)
  >> sub {
     my ($defheader, @declarations) = @_;
     my ($name, $closure, $extends) = @$defheader[1,2,3];
     my $extended_type = (defined $extends) ? $TYPES{$extends} : undef;
     my $new_type;

     if (exists $TYPES{$name}) {
       lino_error("Type '$name' redefined");
     }
     if (defined $extends && ! defined $extended_type) {
       lino_error("Type '$name' extended from unknown type '$extends'");
     }
     $new_type = Type->new($name, $extended_type, $closure);

     add_declarations($new_type, @declarations);

     warn "** defined '$name'\n" if $verbose;
     $TYPES{$name} = $new_type;

     if (defined $outputdir) {
       my $f = "$outputdir/$name.linoc";
       if (open my($O), ">", $f) {
         local $Data::Dumper::Purity = 1;
         print {$O} Data::Dumper->Dump([$TYPES{$name}], ["TYPE_$name"]);
       } else {
         warn "Couldn't open $f: $!; disabling compilation\n";
         undef $outputdir;
       }
     }

  };

$extends = option(_("EXTENDS") - _("IDENTIFIER") >> sub { $_[1] }) ;

$closure = option(_("CLOSED") | _("OPEN")) > sub { uc $_[0] };

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

$declarator = $Declarator_array | $Declarator_single;

$declarator_single = _("IDENTIFIER") 
            - option(_("LPAREN")  - commalist($Param_Spec) - _("RPAREN")
                     >> sub { $_[1] }
                    )
            - option(_("EQUALS") - $Expression >> sub { $_[1] })
  >> sub {
    { WHAT => 'DECLARATOR',
      NAME => $_[0],
      PARAM_SPECS => $_[1],
      EXPR => $_[2],
      COUNT => undef,
    };
  };

$param_spec = $Name - _("EQUALS") - $Expression
  >> sub {
    { WHAT => "PARAM_SPEC",
      NAME => $_[0],
      EXPR => $_[2],
    }
  }
  ;

$declarator_array = _("IDENTIFIER") - $Subscript
  >> sub { return { WHAT => 'DECLARATOR',
		    NAME => $_[0],
		    COUNT => $_[1]->fold_constants,
		  };
	 };

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
      | $Number > sub { Expression->new('CON', $_[0]) }
      | lookfor("STRING", sub { Expression->new('STR', $_[0][1]) })
      | _('OP', '-') - $Expression
            >> sub { Expression->new('-', Expression->new('CON', 0), $_[1]) }
      | _("LPAREN") - $Expression - _("RPAREN") >> sub {$_[1]};

$funapp = $Name - _("LPAREN") - $Expression - _("RPAREN")
            >> sub { 
              my $name = $_[0];
	      my $namestr = $name->to_str;
	      unless ($name->is_simple) {
		lino_error("Compound function name '$namestr' forbidden");
	      }
              unless (exists $builtins{$namestr}) {
                lino_error("Unknown function '$namestr'");
              }
              Expression->new('FUN', $namestr, $_[2]) 
            }
        ;

$name = $Name_component - star((_("DOT") - $Name_component) >> sub { $_[1] })
            >> sub { Name->new($_[0], @{$_[1]}) }
        ;

$name_component = _("IDENTIFIER") - option($Subscript)
  >> sub { defined($_[1]) ? [$_[0], $_[1]] : [$_[0]] };

$subscript = _("LBRACK") - $Expression - _("RBRACK") 
    >> sub { $_[1] };

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

$number = _("INTEGER") | _("FLOAT");

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
    my $count = $decl->{COUNT};
    my $decl_type = $decl->{TYPE};
    my $decl_type_obj = $TYPES{$decl_type};
    $type->add_subchunk($name, $decl_type_obj, $count);
    if ($declaration->{IS_PARAM}) {
      $type->add_param_default(Name->new($name), $decl->{EXPR});
    } elsif (defined $decl->{EXPR}) {
      $type->add_constraints(Expression->new('-', 
                                             Expression->new_var($name),
                                             $decl->{EXPR}));
    }
    for my $pspec (@{$decl->{PARAM_SPECS}}) {
      $type->add_pspec($pspec->{NAME}->qualify($name), $pspec->{EXPR});
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
  if ($file =~ /\.linoc$/) {
    do_compiled_file($file) && return;
  }
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

sub do_compiled_file {
  my $file = shift;
  my $type = $file;
  die "Malformed compiled filename '$file'"
    unless $type =~ s/\.linoc$//;
  $TYPES{$type} = do $file;
}

sub lib_resolve {
  my $f = shift;
  for my $d (@search_path) {
    my $F = "$d/$f";
    return "$F.linoc" if -r "$F.linoc" && -M "$F.linoc" <= -M $F;
    return $F if -r $F;
    return "$F.lino" if -r "$F.lino";
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

