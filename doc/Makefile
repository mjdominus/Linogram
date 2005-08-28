
MOD=/home/mjd/FPP/BOOK
M2T = perl -I$(MOD) $(MOD)/m2t			# MOD-to-text
M2H = perl -I$(MOD) $(MOD)/m2h			# MOD-to-HTML

docs: linogram.txt linogram.html

linogram.txt: linogram.mod 
	$(M2T) linogram.mod

linogram.html: linogram.mod
	$(M2H) linogram.mod
