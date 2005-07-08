
LIBS= \
	lib/Equation.pm \
	lib/Lexer.pm    \
	lib/Stream.pm   \
	lib/Chunk.pm    \
	lib/Expression.pm \
	lib/Parser.pm

test: .tested

.tested: do_tests linogram.pl $(LIBS) testutils.pl Makefile
	perl do_tests t
	@touch .tested