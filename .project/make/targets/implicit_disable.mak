#===============================================================================
# implicit_disable.mak
#
# Disables Make's built-in (implicit) rules.
#
# https://stackoverflow.com/a/5356500/10001931
#
#===============================================================================

# Config
DISABLE_IMPLICIT ?= true

# Definition
ifeq "$(DISABLE_IMPLICIT)" "true"

.SUFFIXES:
SUFFIXES :=
%.out:
%.a:
%.ln:
%.o:
%: %.o
%.c:
%: %.c
%.ln: %.c
%.o: %.c
%.cc:
%: %.cc
%.o: %.cc
%.C:
%: %.C
%.o: %.C
%.cpp:
%: %.cpp
%.o: %.cpp
%.p:
%: %.p
%.o: %.p
%.f:
%: %.f
%.o: %.f
%.F:
%: %.F
%.o: %.F
%.f: %.F
%.r:
%: %.r
%.o: %.r
%.f: %.r
%.y:
%.ln: %.y
%.c: %.y
%.l:
%.ln: %.l
%.c: %.l
%.r: %.l
%.s:
%: %.s
%.o: %.s
%.S:
%: %.S
%.o: %.S
%.s: %.S
%.mod:
%: %.mod
%.o: %.mod
%.sym:
%.def:
%.sym: %.def
%.h:
%.info:
%.dvi:
%.tex:
%.dvi: %.tex
%.texinfo:
%.info: %.texinfo
%.dvi: %.texinfo
%.texi:
%.info: %.texi
%.dvi: %.texi
%.txinfo:
%.info: %.txinfo
%.dvi: %.txinfo
%.w:
%.c: %.w
%.tex: %.w
%.ch:
%.web:
%.p: %.web
%.tex: %.web
%.sh:
%: %.sh
%.elc:
%.el:
(%): %
%.out: %
%.c: %.w %.ch
%.tex: %.w %.ch
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%
.web.p:
.l.r:
.dvi:
.F.o:
.l:
.y.ln:
.o:
.y:
.def.sym:
.p.o:
.p:
.txinfo.dvi:
.a:
.l.ln:
.w.c:
.texi.dvi:
.sh:
.cc:
.cc.o:
.def:
.c.o:
.r.o:
.r:
.info:
.elc:
.l.c:
.out:
.C:
.r.f:
.S:
.texinfo.info:
.c:
.w.tex:
.c.ln:
.s.o:
.s:
.texinfo.dvi:
.el:
.texinfo:
.y.c:
.web.tex:
.texi.info:
.DEFAULT:
.h:
.tex.dvi:
.cpp.o:
.cpp:
.C.o:
.ln:
.texi:
.txinfo:
.tex:
.txinfo.info:
.ch:
.S.s:
.mod:
.mod.o:
.F.f:
.w:
.S.o:
.F:
.web:
.sym:
.f:
.f.o:

endif
