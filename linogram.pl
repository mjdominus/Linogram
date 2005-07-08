#!/usr/bin/perl

use Data::Dumper;
$Data::Dumper::Freezer = 'FREEZER';
sub UNIVERSAL::FREEZER { $_[0] }

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

while (@ARGV && $ARGV[0] =~ /-(\w)/) {
  my $opt = $1;
  shift;
  if ($opt eq "P") {
    my $file = shift;
    require $file;
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
warn "Using $FILE\n";
open INPUT, "<", $FILE or die $!;

my $ROOT_TYPE = Type->new('ROOT');
my %TYPES = ('number' => Type::Scalar->new('number'),
             'ROOT'   => $ROOT_TYPE,
            );
my $input = sub { read INPUT, my($buf), 8192 or return; $buf };

my @keywords = map [uc($_), qr/\b$_\b/],
  qw(constraints define extends draw param);

my $tokens = 
  i2s(make_lexer($input,
                 @keywords,
                 ['ENDMARKER',  qr/__END__.*/s,
                  sub {
                    my $s = shift;
                    $s =~ s/^__END__\s*//;
                    ['ENDMARKER', $s]
                  } ],
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


################################################################

my ($atom, $base_name, $constraint, $constraint_section, $declaration,
    $declarator, $defheader, $definition, $extends, $draw_section,
    $drawable, $expression, $name, $param_spec,
    $perl_code, $program, $term, $tuple, $type, );

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
my $Name               = parser { $name->(@_) };
my $Param_Spec         = parser { $param_spec->(@_) };
my $Perl_code          = parser { $perl_code->(@_) };
my $Program            = parser { $program->(@_) };
my $Term               = parser { $term->(@_) };
my $Tuple              = parser { $tuple->(@_) };
my $Type               = parser { $type->(@_) };

@N{$Atom, $Base_name, $Constraint, $Constraint_section, $Declaration,
    $Declarator, $Defheader, $Definition, $Extends, $Draw_section,
    $Drawable, $Expression, $Name, $Param_Spec,
    $Perl_code, $Program, $Term, $Tuple, $Type} =
qw(atom base_name constraint constraint_section declaration 
   declarator defheader definition extends draw_section 
   drawable expression name param_spec 
   perl_code program term tuple type);

################################################################

$program = star($Definition 
              | $Declaration
                > sub { add_declarations($ROOT_TYPE, $_[0]) }
              )
         - option($Perl_code) - $End_of_Input
  >> sub {
#    print "FINISHED READING THE PROGRAM\n";
    $ROOT_TYPE->draw();
  };

$defheader = _("DEFINE") - _("IDENTIFIER") - $Extends
  >> sub { ["DEFINITION", @_[1,2] ]};

$definition = labeledblock($Defheader, $Declaration)
  >> sub {
     my ($defheader, @declarations) = @_;
     my ($name, $extends) = @$defheader[1,2];
     my $extended_type = (defined $extends) ? $TYPES{$extends} : undef;
     my $new_type;

     if (exists $TYPES{$name}) {
       pic_error("Type '$name' redefined");
     }
     if (defined $extends && ! defined $extended_type) {
       pic_error("Type '$name' extended from unknown type '$extends'");
     }
     $new_type = Type->new($name, $extended_type);

     add_declarations($new_type, @declarations);

     warn "** defined '$name'\n";
     $TYPES{$name} = $new_type;
  };

$extends = option(_("EXTENDS") - _("IDENTIFIER") >> sub { $_[1] }) ;

$declaration = option(_("PARAM")) - $Type
             - commalist($Declarator) - _("TERMINATOR")
                 >> sub { my ($is_param, $type, $decl_list) = @_;
			  unless (exists $TYPES{$type}) {
			    pic_error("Unknown type name '$type' in declaration '@_'\n");
			  }
                          for (@$decl_list) {
                            $_->{TYPE} = $type;
                            check_declarator($TYPES{$type}, $_);
                          }
                          {WHAT => 'DECLARATION',
                           IS_PARAM => $is_param ? 1 : 0,
                           DECLARATORS => $decl_list };
                        }
             | $Constraint_section 
             | $Draw_section
#  | error(_("RBRACE"), $Declaration)
             ;

$declarator = _("IDENTIFIER") 
            - option(_("LPAREN")  - commalist($Param_Spec) - _("RPAREN")
                     >> sub { $_[1] }
                    )
  >> sub {
    { WHAT => 'DECLARATOR',
      NAME => $_[0],
      PARAM_SPECS => $_[1],
    };
  };

$param_spec = _("IDENTIFIER") - _("EQUALS") - $Expression
  >> sub {
    { WHAT => "PARAM_SPEC",
      NAME => $_[0],
      VALUE => $_[2],
    }
  }
  ;

$constraint_section = labeledblock(_("CONSTRAINTS"), $Constraint)
  >> sub { shift;
           { WHAT => 'CONSTRAINTS', CONSTRAINTS => [@_] }
         };

$constraint = $Expression - _("EQUALS") - $Expression - _("TERMINATOR")
  >> sub { Expression->new('-', $_[0], $_[2]) } ;

$draw_section = labeledblock(_("DRAW"), $Drawable)
  >> sub { shift; { WHAT => 'DRAWABLES', DRAWABLES => [@_] } };

$drawable =
            $Name - _("TERMINATOR")
                >> sub { return { WHAT => 'NAMED_DRAWABLE',
				  NAME => $_[1],
				}
                         }
          | _("FUNCTION") - _("IDENTIFIER") - _("TERMINATOR")
  >> sub { my $ref = \&{$_[1]};
           return { WHAT => 'FUNCTIONAL_DRAWABLE',
                    REF => $ref,
                    NAME => $_[1],
                  };
         };

$expression = operator($Term,
                       [_('OP', '+'), sub { Expression->new('+', @_) } ],
                       [_('OP', '-'), sub { Expression->new('-', @_) } ],
                      );

$term = operator($Atom, 
                       [_('OP', '*'), sub { Expression->new('*', @_) } ],
                       [_('OP', '/'), sub { Expression->new('/', @_) } ],
                );

$atom = $Name
      | $Tuple
      | lookfor("NUMBER", sub { Expression->new('CON', $_[0][1]) })
      | _('OP', '-') - $Expression
            >> sub { Expression->new('-', Expression->new('CON', 0), $_[1]) }
      | _("LPAREN") - $Expression - _("RPAREN") >> sub {$_[1]};

$name = $Base_name - star(_("DOT") - _("IDENTIFIER") >> sub { $_[1] })
            >> sub { Expression->new('VAR', join(".", $_[0], @{$_[1]})) }
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
      return [ 'TUPLE',
               { map { $axis[$_] => $explist->[$_] } (0 .. $N-1) }
             ];
    } else {
      pic_error("$N-tuples are not supported\n");
    }
  } ;


$type = lookfor("IDENTIFIER",
                sub {
#                  print "In lookfor (@{$_[0]})\n";
                  exists($TYPES{$_[0][1]}) || pic_error("Unrecognized type '$_[0][1]'");
                  $_[0][1];
                }
               );

$perl_code = _("ENDMARKER") > sub { warn "Evaling perl code $_[0]\n"; 
                                    eval $_[0];
                                    die if $@; 
                                  };


################################################################


sub check_types {
  my ($a, $b) = @_;
  $a->meet($b) or
    pic_error("Can't equate type ", $a->name, " with type ", $b->name, "; aborting");
}

my %add_decl = ('DECLARATION' => \&add_subobj_declaration,
                'CONSTRAINTS' => \&add_constraint_declaration,
                'DRAWABLES' => \&add_draw_declaration,
                'DEFAULT' =>  sub {
                  pic_error("Unknown declaration kind '$[1]{WHAT}'");
                },
               );

sub add_declarations {
  my ($type, @declarations) = @_;

  for my $declaration (@declarations) {
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
    for my $pspec (@{$decl->{PARAM_SPECS}}) {
      my $pspec_name = $pspec->{NAME};
      my $constraints = convert_param_specs($type, $name, $pspec);
      $type->add_constraints($constraints);
    }
  }
}

sub add_constraint_declaration {
  my ($type, $declaration) = @_;
  my $constraint_expressions = $declaration->{CONSTRAINTS};
  my @constraints 
    = map expression_to_constraints($type, $_), @$constraint_expressions;
  $type->add_constraints(@constraints);
}

sub add_draw_declaration {
  my ($type, $declaration) = @_;
  my $drawables = $declaration->{DRAWABLES};

  for my $d (@$drawables) {
    my $drawable_type = $d->{WHAT};
    if ($drawable_type eq "NAMED_DRAWABLE") {
      unless ($type->has_subchunk($d->{NAME})) {
        pic_error("Unknown drawable chunk '$d->{NAME}'");
      }
      $type->add_drawable($d->{NAME});
    } elsif ($drawable_type eq "FUNCTIONAL_DRAWABLE") {
      $type->add_drawable($d->{REF});
    } else {
      pic_error("Unknown drawable type '$type'");
    }
  }
} 


# Take an AST for an expression.  Assuming it
# implies "expression = 0", turn it into a list of constraint
# (Equation) objects
sub expression_to_constraints {
  my ($context, $expr) = @_;
  unless (defined $expr) {
    Carp::croak("Missing expression in 'expression_to_constraints'");
  }
  my ($op, @s) = @$expr;

  if ($op eq 'VAR') {
    my $name = $s[0];
    return Value::Chunk->new_from_var($name, $context->subchunk($name));
  } elsif ($op eq 'CON') {
    return Value::Constant->new($s[0]);
  } elsif ($op eq 'TUPLE') {
    my %elements;
    for my $k (keys %{$s[0]}) {
      # Add check to make sure that $s[0]{$k} is actually a scalar type XXX
      $elements{$k} = expression_to_constraints($context, $s[0]{$k});
    }
    return Value::Tuple->new(%elements);
  }

  my $e1 = expression_to_constraints($context, $s[0]);
  my $e2 = expression_to_constraints($context, $s[1]);

  my %opmeth = ('+' => 'add',
		'-' => 'sub',
		'*' => 'mul',
		'/' => 'div',
	       );
  
  my $meth = $opmeth{$op};
  if (defined $meth) {
    return $e1->$meth($e2);
  } else {
    pic_error("Unknown operator '$op' in AST");
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

my ($result, $leftover) = eval { $program->($tokens) };
if ($@) {
  print "Failed: \n";
  Parser::display_failures($@);
}

sub pic_error {
  die @_;
}

sub check_declarator {
  my ($type, $declarator) = @_;
  for my $pspec (@{$declarator->{PARAM_SPECS}}) {
    my $name = $pspec->{NAME};
    unless ($type->has_subchunk($name)) {
      pic_error("Declaration of '$declarator->{NAME}' specifies unknown parameter '$name' for type '$type->{N}'\n");
    }
  }
}

sub convert_param_specs {
  my ($context, $subobj, $pspec) = @_;
  my @constraints;
  my $left = Value::Chunk->new_from_var("$subobj." . $pspec->{NAME}, 
					 $context->subchunk($subobj)
					 ->subchunk($pspec->{NAME})
					);
  my $right = expression_to_constraints($context, $pspec->{VALUE});
  return $left->sub($right);
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
