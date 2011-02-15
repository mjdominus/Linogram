
LIBS= \
	lib/Equation.pm \
	lib/Lexer.pm    \
	lib/Stream.pm   \
	lib/Chunk.pm    \
	lib/Expression.pm \
	lib/Environment.pm \
	lib/Value.pm \
	lib/Parser.pm \
	lib/Name.pm 

LINOLIB= \
	linolib/point.lino \
	linolib/line.lino \
	linolib/hline.lino \
	linolib/vline.lino \
	linolib/box.lino \
	linolib/label.lino \
	linolib/labelbox.lino \
	linolib/polygon.lino \
	linolib/regpolygon.lino \
	linolib/curve.lino

DRAW= \
	draw/postscript.pl \
	draw/dummy.pl

SOURCE= linogram.pl $(LIBS) $(LINOLIB) $(DRAW)

TESTS= t/array000-i t/array000-o t/array001-i t/array001-o		\
	t/array002-i t/array002-o t/array003-i t/array003-o		\
	t/array004-i t/array004-o t/array005-i t/array005-o		\
	t/array006-i t/array006-o t/array007-i t/array007-o		\
	t/array008-i t/array008-o t/array009-i t/array009-o		\
	t/array010-i t/array010-o t/array011-i t/array011-o		\
	t/array012-i t/array012-o t/array013-i t/array013-o		\
	t/array014-i t/array014-o t/array015-i t/array015-o		\
	t/array016-i t/array016-o t/array020-i t/array020-o		\
	t/array021-i t/array021-o t/array022-i t/array022-o		\
	t/array030-i t/array030-o t/array031-i t/array031-o		\
	t/array040-i t/array040-o t/array041-i t/array041-o		\
	t/array042-i t/array042-o t/array043-i t/array043-o		\
	t/array044-i t/array044-o t/array045-i t/array045-o		\
	t/array050-i t/array050-o t/array051-i t/array051-o		\
	t/array052-i t/array052-o t/array053-i t/array053-o		\
	t/array054-i t/array054-o t/array055-i t/array055-o t/box001-i	\
	t/box001-o t/builtin000-i t/builtin000-o t/builtin001-i		\
	t/builtin t/builtin002-i t/builtin002-o t/builtin003-i		\
	t/builtin003-o t/concat001-i t/concat001-o t/constraint001-i	\
	t/constraint001-o t/constraint002-i t/constraint002-o		\
	t/constraint003-i t/constraint003-o t/constraint004-i		\
	t/constraint004-o t/constraint005-i t/constraint005-o		\
	t/constraint006-i t/constraint006-o t/define001-i		\
	t/define001-o t/define002-i t/define002-o t/draw001-i		\
	t/draw001-o t/draw002-i t/draw002-o t/__empty000-i		\
	t/__empty000-o t/extends001-i t/extends001-o t/extends002-i	\
	t/extends002-o t/extends003-i t/extends003-o t/extends004-i	\
	t/extends004-o t/extends005-i t/extends005-o t/extends006-i	\
	t/extends006-o t/extends007-i t/extends007-o t/extends008-i	\
	t/extends008-o t/inconsistent001-i t/inconsistent0		\
	t/label000-i t/label000-o t/label001-i t/label001-o		\
	t/label002-i t/label002-o t/label003-i t/label003-o		\
	t/label004-i t/label004-o t/label005-i t/label005-o		\
	t/label006-i t/label006-o t/labelbox001 t/labelbox001-o		\
	t/labelbox002-i t/labelbox002-o t/labelbox003-i			\
	t/labelbox003-o t/line001-i t/line001-o t/line002-i		\
	t/line002-o t/line003-i t/line003-o t/param001-i t/param001-o	\
	t/param002-i t/param002-o t/param003-i t/param003-o		\
	t/param004-i t/param004-o t/param005-i t/param005-o		\
	t/param006-i t/param006-o t/param007-i t/param007-o		\
	t/param008-i t/param008-o t/param009-i t/param009-o		\
	t/param010-i t/param010-o t/param012-i t/param012-o		\
	t/param013-i t/param013-o t/param014-i t/param014-o		\
	t/param015-i t/param015-o t/param016-i t/param016-o		\
	t/param017-i t/param017-o t/param018-i t/param018-o		\
	t/param019-i t/param019-o t/param020-i t/param020-o		\
	t/param021-i t/param021-o t/param022-i t/param022-o		\
	t/param023-i t/param023-o t/param024-i t/param024-o		\
	t/param025-i t/param025-o t/param026-i t/param026-o		\
	t/param027-i t/param027-o t/param028-i t/param028-o		\
	t/param029-i t/param029-o t/param030-i t/param030-o		\
	t/param031-i t/param031-o t/param032-i t/param032-o		\
	t/param033-i t/param033-o t/param034-i t/param034-o		\
	t/param035-i t/param035-o t/param036-i t/param036-o		\
	t/param037-i t/param037-o t/param038-i t/param038-o		\
	t/param039-i t/param039-o t/polygon001-i t/polygon001-o		\
	t/polygon002-i t/polygon002-o t/polygon003-i t/polygon003-o	\
	t/pspec001-i t/pspec001-o t/pspec002-i t/pspec002-o		\
	t/regpoly001-i t/regpoly001-o t/simple001-i t/simple001-o	\
	t/simple002-i t/simple002-o t/simple003-i t/simple003-o		\
	t/simple004-i t/simple004-o t/string001-i t/string001-o		\
	t/subfile001-i t/subfile001-o t/tripeq2-i t/tripeq2-o		\
	t/tripeq-i t/tripeq-o t/tuple001-i t/tuple001-o \
	do_tests Makefile

DOC=doc/linogram.txt doc/syntax.txt

DEMO_JPG= demo/curve-demo.jpg demo/curve-demo2.jpg	\
          demo/curve-demo3.jpg demo/demo.jpg

.SUFFIXES: .ps .gif .jpg .lino

.lino.ps:
	perl linogram.pl -P draw/postscript.pl $*.lino > $*.ps

PS2JPG=ps2jpg
PS2GIF=ps2gif

.ps.jpg:
	$(PS2JPG) < $*.ps > $*.jpg

.ps.gif: 
	$(PS2GIF) < $*.ps > $*.gif

default: system-tests

demo: $(DEMO_JPG)

$(DEMO_JPG): linogram.pl draw/postscript.pl $(LINOLIB)

# do_tests linogram.pl $(LIBS) testutils.pl Makefile
test: unit-tests system-tests

system-tests:
	perl do_tests t
	@touch .tested

all-system-tests: nostamps system-tests

unit-tests: .dump-test-notes
	perl -Ilib -Ilib/testutils -MTest::Harness -e 'runtests(@ARGV)' u/*.t


.dump-test-notes:
	@cat u/test-notes
	@sleep 5
	touch .dump-test-notes

nostamps:
	@rm -f t/.*-o

diff:  DIFFS

DIFFS: $(LIBS) linogram.pl
	cvs diff -u > DIFFS

dist: nostamps linogram.tgz linogram.zip

linogram.tgz: $(SOURCE) $(DOC) $(TESTS)
	mkdir linogram
	tar cf - $(SOURCE) $(DOC) $(TESTS) | (cd linogram; tar xf -)
	tar czf linogram.tgz linogram
	rm -rf linogram

linogram.zip: $(SOURCE) $(DOC) $(TESTS)
	mkdir linogram
	tar cf - $(SOURCE) $(DOC) $(TESTS) | (cd linogram; tar xf -)
	zip -q -r linogram.zip linogram
	rm -rf linogram

wc: .wc
	@cat .wc

.wc: $(SOURCE)	
	@wc $(SOURCE) > .wc

print: 
	lp $(SOURCE)

doc: $(DOC)

MOD=/home/mjd/FPP/BOOK
M2T = perl -I$(MOD) $(MOD)/m2t			# MOD-to-text
M2H = perl -I$(MOD) $(MOD)/m2h			# MOD-to-HTML

doc/linogram.txt: doc/linogram.mod 
	$(M2T) doc/linogram.mod

doc/linogram.html: doc/linogram.mod
	$(M2H) doc/linogram.mod


