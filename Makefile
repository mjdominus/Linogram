
LIBS= \
	lib/Equation.pm \
	lib/Lexer.pm    \
	lib/Stream.pm   \
	lib/Chunk.pm    \
	lib/Expression.pm \
	lib/Parser.pm


# do_tests linogram.pl $(LIBS) testutils.pl Makefile
test: 
	perl do_tests t
	@touch .tested

alltests: nostamps test

nostamps:
	@rm -f t/.*-o

diff:  DIFFS

DIFFS: $(LIBS) linogram.pl
	cvs diff -u > DIFFS

