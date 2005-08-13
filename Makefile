
LIBS= \
	lib/Equation.pm \
	lib/Lexer.pm    \
	lib/Stream.pm   \
	lib/Chunk.pm    \
	lib/Expression.pm \
	lib/Environment.pm \
	lib/Value.pm \
	lib/Parser.pm 

LINOLIB= \
	linolib/point.lino \
	linolib/line.lino \
	linolib/hline.lino \
	linolib/vline.lino \
	linolib/box.lino

SOURCE= linogram.pl $(LIBS) $(LINOLIB)

TESTS= do_tests lib/testutils/dump_hash.pl Makefile \
	t/__empty000-i t/__empty000-o t/box001-i t/box001-o		\
	t/builtin000-i t/builtin000-o t/builtin001-i t/builtin001-o	\
	t/builtin002-i t/builtin002-o t/constraint001-i			\
	t/constraint001-o t/constraint002-i t/constraint002-o		\
	t/constraint003-i t/constraint003-o t/constraint004-i		\
	t/constraint004-o t/constraint005-i t/constraint005-o		\
	t/constraint006-i t/constraint006-o t/define001-i		\
	t/define001-o t/define002-i t/define002-o t/extends001-i	\
	t/extends001-o t/extends002-i t/extends002-o t/extends003-i	\
	t/extends003-o t/extends004-i t/extends004-o t/extends005-i	\
	t/extends005-o t/extends006-i t/extends006-o			\
	t/inconsistent001-i t/inconsistent001-o t/line001-i		\
	t/line001-o t/line002-i t/line002-o t/param000-i t/param000-o	\
	t/param001-i t/param001-o t/param002-i t/param002-o		\
	t/param003-i t/param003-o t/param004-i t/param004-o		\
	t/param005-i t/param005-o t/pspec001-i t/pspec001-o		\
	t/pspec002-i t/pspec002-o t/subfile001-i t/subfile001-o		\
	t/tripeq-i t/tripeq-o t/tripeq2-i t/tripeq2-o t/tuple001-i	\
	t/tuple001-o


DOC=doc/linogram.txt doc/syntax.txt

default: system-tests


# do_tests linogram.pl $(LIBS) testutils.pl Makefile
test: unit-tests system-tests

system-tests:
	perl do_tests t
	@touch .tested

unit-tests:
	perl -Ilib -Ilib/testutils -MTest::Harness -e 'runtests(@ARGV)' u/*.t

alltests: nostamps test

nostamps:
	@rm -f t/.*-o

diff:  DIFFS

DIFFS: $(LIBS) linogram.pl
	cvs diff -u > DIFFS

dist: nostamps linogram.tgz linogram.zip

linogram.tgz: $(SOURCE) $(DOC) $(TESTS)
	tar czf linogram.tgz $(SOURCE) $(DOC) $(TESTS)

linogram.zip: $(SOURCE) $(DOC) $(TESTS)
	zip -q -r linogram.zip $(SOURCE) $(DOC) $(TESTS)

wc: .wc
	@cat .wc

.wc: $(SOURCE)	
	@wc $(SOURCE) > .wc
