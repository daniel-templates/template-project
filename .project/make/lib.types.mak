#===============================================================================
# lib.types.mak
#
# Generates type definitions for 'lib.mak'.
# Not intended for general use.
#
# Usage:
#
# 	make -f .project/make/lib.types.mak [outfile={file}]
#
#===============================================================================
ifeq "$(filter lib.mak,$(notdir $(MAKEFILE_LIST)))" ""
include $(or $(lib.path),$(dir $(lastword $(MAKEFILE_LIST)))/lib.mak)
endif
#===============================================================================

# str := //abspath\to/dir\ name.suffix/
# pack.from    := $(or $(__word.pack.{path}.from),  x          p   bu    u   bv    v   bs    s   bb    b)
# pack.to      := $(or $(__word.pack.{path}.to),   xx         xp xbxu xbxu xbxv xbxv xbxs xbxs xbxb    f)
# pack.strip   :=
# pack.cull    := f
# pack_empty := $(true)

# unpack.from := $(or $(__word.unpack.{path}.from), xb xs xv xu xp xx)
# unpack.to   := $(or $(__word.unpack.{path}.to),    b  s  v  u  p  x)
# unpack_empty := $(true)

# pad.nonws    := $(char.nonws)
# pad.ws       := $(char.vars.ws)

# $(info $e  expr.word.pack)
# $(info $e================================================)
# $(eval func.pack = $(call expr.word.pack,$$1,$(pack_empty),$(pack.from),$(pack.to),$(pack.cull),$(pack.strip)))
# $(info $e str          = [$(str)])
# $(info $e pack.from    = [$(pack.from)])
# $(info $e pack.to      = [$(pack.to)])
# $(info $e pack.strip   = [$(pack.strip)])
# $(info $e pack.cull    = [$(pack.cull)])
# $(info $e pack_empty = [$(pack_empty)])
# $(info $e)
# $(info $e word.pack    = [$(value func.pack)])
# $(info $e            --> [$(call func.pack,$(str))])
# $(info $e)
# $(info $e  expr.word.unpack)
# $(info $e================================================)
# $(eval func.unpack = $(call expr.word.unpack,$$1,$(unpack_empty),$(unpack.from),$(unpack.to)))
# $(info $e str          = [$(call func.pack,$(str))])
# $(info $e unpack.from  = [$(unpack.from)])
# $(info $e unpack.to    = [$(unpack.to)])
# $(info $e unpack_empty = [$(unpack_empty)])
# $(info $e)
# $(info $e word.unpack  = [$(value func.unpack)])
# $(info $e            --> [$(call func.unpack,$(call func.pack,$(str)))])
# $(info $e)
# $(info $e  expr.pad.pack)
# $(info $e================================================)
# $(eval func.pad.pack = $(call expr.pad.pack,$$1,$(pad.nonws),$(pad.ws)))
# $(info $e str          = [$(str)])
# $(info $e pad.nonws    = [$(pad.nonws)])
# $(info $e pad.ws       = [$(pad.ws)])
# $(info $e)
# $(info $e pad.pack     = [$(value func.pad.pack)])
# $(info $e            --> [$(call func.pad.pack,$(str))])
# $(info $e)
# $(error Exiting...)


#===============================================================================
# TYPE DEFINITIONS
#===============================================================================

override types += {str} {str.pattern}
override type.{str}.chars.nonws           := $(char.nonws)
override type.{str}.chars.ws              := s t n
override type.{str.pattern}.chars.nonws   := $(char.nonws)
override type.{str.pattern}.chars.ws      := s t n

override types += {list} {list.pattern}
override type.{list}.chars.nonws          := $(char.nonws)
override type.{list}.chars.ws             := s t n
override type.{list.pattern}.chars.nonws  := $(char.nonws)
override type.{list.pattern}.chars.ws     := s t n

override types += {line} {line.pattern}
override type.{line}.chars.nonws          := $(char.nonws)
override type.{line}.chars.ws             := s t
override type.{line.pattern}.chars.nonws  := $(char.nonws)
override type.{line.pattern}.chars.ws     := s t

override types += {word} {word.pattern}
override type.{word}.chars.nonws          := $(char.nonws)
override type.{word}.chars.ws             :=
override type.{word.pattern}.chars.nonws  := $(char.nonws)
override type.{word.pattern}.chars.ws     :=

override types += {path} {path.pattern}
override type.{path}.chars.nonws          := $(filter-out < > " | * ?,$(char.nonws))
override type.{path}.chars.ws             := s
override type.{path.pattern}.chars.nonws  := $(filter-out < > " |,$(char.nonws))
override type.{path.pattern}.chars.ws     := s

override types += {paths} {paths.pattern}
override type.{paths}.chars.nonws         := $(filter-out < > " | * ?,$(char.nonws))
override type.{paths}.chars.ws            := s t
override type.{paths.pattern}.chars.nonws := $(filter-out < > " |,$(char.nonws))
override type.{paths.pattern}.chars.ws    := s t

override types += {int} {int.pattern} {uint} {uint.pattern} {idx} {idx.pattern}
override type.{int}.chars.nonws           := $(char.digits) + -
override type.{int}.chars.ws              :=
override type.{int.pattern}.chars.nonws   := $(char.digits) + - %
override type.{int.pattern}.chars.ws      :=
override type.{uint}.chars.nonws          := $(char.digits) +
override type.{uint}.chars.ws             :=
override type.{uint.pattern}.chars.nonws  := $(char.digits) + %
override type.{uint.pattern}.chars.ws     :=
override type.{idx}.chars.nonws           := $(char.digits) +
override type.{idx}.chars.ws              :=
override type.{idx.pattern}.chars.nonws   := $(char.digits) + %
override type.{idx.pattern}.chars.ws      :=

override types += {var}
override type.{var}.chars.nonws           := $(char.vars)
override type.{var}.chars.ws              :=
override type.{var.pattern}.chars.nonws   := $(char.vars)
override type.{var.pattern}.chars.ws      :=

override types += {expr} {expr.pattern}
override type.{expr}.chars.nonws          := $(char.nonws)
override type.{expr}.chars.ws             := s t n
override type.{expr.pattern}.chars.nonws  := $(char.nonws)
override type.{expr.pattern}.chars.ws     := s t n

#                                     String:       $   \%    %   \[    [   \]    ] \{s}  {s}   \\    \  {t}  {n}
#                                        Var:       x   bp    p   bu    u   bv    v   bs    s   bb    b    t    n
#                                                ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____
override type.{str}.word.pack.from            :=    x         p         u         v         s         b    t    n
override type.{str}.word.pack.to              :=   xx        xp        xu        xv        xs        xb   xt   xn
override type.{str.pattern}.word.pack.from    :=    x   bp              u         v         s         b    t    n
override type.{str.pattern}.word.pack.to      :=   xx xbxp             xu        xv        xs        xb   xt   xn

override type.{list}.word.pack.from           :=    x         p         u         v         s         b    t    n
override type.{list}.word.pack.to             :=   xx        xp        xu        xv        xs        xb   xs   xs
override type.{list}.word.pack.strip          :=                                                               xs
override type.{list.pattern}.word.pack.from   :=    x   bp              u         v         s         b    t    n
override type.{list.pattern}.word.pack.to     :=   xx xbxp             xu        xv        xs        xb   xs   xs
override type.{list.pattern}.word.pack.strip  :=                                                               xs

override type.{line}.word.pack.from           :=   x          p         u         v         s         b    t
override type.{line}.word.pack.to             :=  xx         xp        xu        xv        xs        xb   xt
override type.{line.pattern}.word.pack.from   :=   x    bp              u         v         s         b    t
override type.{line.pattern}.word.pack.to     :=  xx  xbxp             xu        xv        xs        xb   xt

override type.{word}.word.pack.from           :=   x          p         u         v                   b
override type.{word}.word.pack.to             :=  xx         xp        xu        xv                  xb
override type.{word.pattern}.word.pack.from   :=   x    bp              u         v                   b
override type.{word.pattern}.word.pack.to     :=  xx  xbxp             xu        xv                  xb

override type.{path}.word.pack.from           :=   x          p   bu    u   bv    v   bs    s   bb    b
override type.{path}.word.pack.to             :=  xx         xp xbxu xbxu xbxv xbxv xbxs xbxs xbxb    f
override type.{path}.word.pack.cull           :=                                                      f
override type.{path.pattern}.word.pack.from   :=   x    bp        bu        bv        bs    s   bb    b
override type.{path.pattern}.word.pack.to     :=  xx  xbxp      xbxu      xbxv      xbxs xbxs xbxb    f
override type.{path.pattern}.word.pack.cull   :=                                                      f

override type.{paths}.word.pack.from          :=   x          p   bu    u   bv    v   bs    s   bb    b    t
override type.{paths}.word.pack.to            :=  xx         xp xbxu xbxu xbxv xbxv xbxs   xs xbxb    f   xs
override type.{paths}.word.pack.strip         :=                                           xs
override type.{paths.pattern}.word.pack.from  :=   x    bp        bu        bv        bs    s   bb    b    t
override type.{paths.pattern}.word.pack.to    :=  xx  xbxp      xbxu      xbxv      xbxs   xs xbxb    f   xs
override type.{paths.pattern}.word.pack.strip :=                                           xs

override type.{int}.word.pack.from  := char.plus
override type.{int}.word.pack.to    := e
override type.{uint}.word.pack.from := char.plus
override type.{uint}.word.pack.to   := e
override type.{idx}.word.pack.from  := char.plus
override type.{idx}.word.pack.to    := e

override type.{var}.word.pack.from            :=    x         p                                       b
override type.{var}.word.pack.to              :=   xx        xp                                      xb
override type.{var.pattern}.word.pack.from    :=    x   bp                                            b
override type.{var.pattern}.word.pack.to      :=   xx xbxp                                           xb

override type.{expr}.word.pack.from           :=    x         p                             s         b    t    n
override type.{expr}.word.pack.to             :=   xx        xp                            xs        xb   xt   xn
override type.{expr.pattern}.word.pack.from   :=    x   bp                                  s         b    t    n
override type.{expr.pattern}.word.pack.to     :=   xx xbxp                                 xs        xb   xt   xn

#                                     String:     $x $t $b $s $v $u $p $x
#                                        Var:     xn xt xb xs xv xu xp xx
#                                                 __ __ __ __ __ __ __ __
override type.{str}.word.unpack.from          :=  xn xt xb xs xv xu xp xx
override type.{str}.word.unpack.to            :=   n  t  b  s  v  u  p  x
override type.{str.pattern}.word.unpack.from  :=  xn xt xb xs xv xu xp xx
override type.{str.pattern}.word.unpack.to    :=   n  t  b  s  v  u  p  x

override type.{list}.word.unpack.from         :=        xb xs xv xu xp xx
override type.{list}.word.unpack.to           :=         b  s  v  u  p  x
override type.{list.pattern}.word.unpack.from :=        xb xs xv xu xp xx
override type.{list.pattern}.word.unpack.to   :=         b  s  v  u  p  x

override type.{line}.word.unpack.from         :=     xt xb xs xv xu xp xx
override type.{line}.word.unpack.to           :=      t  b  s  v  u  p  x
override type.{line.pattern}.word.unpack.from :=     xt xb xs xv xu xp xx
override type.{line.pattern}.word.unpack.to   :=      t  b  s  v  u  p  x

override type.{word}.word.unpack.from         :=        xb    xv xu xp xx
override type.{word}.word.unpack.to           :=         b     v  u  p  x
override type.{word.pattern}.word.unpack.from :=        xb    xv xu xp xx
override type.{word.pattern}.word.unpack.to   :=         b     v  u  p  x

override type.{path}.word.unpack.from         :=        xb xs xv xu xp xx
override type.{path}.word.unpack.to           :=         b  s  v  u  p  x
override type.{path.pattern}.word.unpack.from :=        xb xs xv xu xp xx
override type.{path.pattern}.word.unpack.to   :=         b  s  v  u  p  x

override type.{expr}.word.unpack.from         :=  xn xt xb xs       xp xx
override type.{expr}.word.unpack.to           :=   n  t  b  s        p  x
override type.{expr.pattern}.word.unpack.from :=  xn xt xb xs       xp xx
override type.{expr.pattern}.word.unpack.to   :=   n  t  b  s        p  x

override type.{var}.word.unpack.from          :=        xb          xp xx
override type.{var}.word.unpack.to            :=         b           p  x
override type.{var.pattern}.word.unpack.from  :=        xb          xp xx
override type.{var.pattern}.word.unpack.to    :=         b           p  x


#===============================================================================

# expr.word.pack        	[expr[word[T]]([T])] <-- $(call expr.word.pack,[expr[T]:in],[bool:pack_empty],[list[var]:from],[list[var]:to],[list[var]:cull],[list[var]:strip])
# expr.word.unpack      	[expr[T]([word[T]])] <-- $(call expr.word.unpack,[expr[T]:in],[bool:unpack_empty],[list[var]:from],[list[var]:to])
# expr.pad.pack         	[expr[pad]]          <-- $(call expr.pad.pack,[expr[T]:in],[list{char}:nonws],[list{var}:ws])
override expr.word.pack   = $(if $2,$$$lif $1$c)$(call expr.strip.vars,$(call expr.cull.vars,$(call expr.subst.refs2refs,$1,$3,$4),$5,$3),$6,$3)$(if $2,$c$$(xe)$r)
override expr.word.unpack = $(call expr.subst.refs2refs,$1,$(if $2,xe) $3,$(if $2,e) $4)
override expr.pad.pack    = $(call expr.subst.consts2const,$(call expr.subst.refs2const,$1,$3,.),$2,.)

ifdef outfile
$(warning Writing type definitions to $(outfile)...)
$(file > $(outfile),$g$s<lib.types.mak>)
$(foreach type,$(types),\
$(file >> $(outfile),override type.$(type).word.pack = $(call expr.word.pack,$$1,$(false),$(type.$(type).word.pack.from),$(type.$(type).word.pack.to),$(type.$(type).word.pack.cull),$(type.$(type).word.pack.strip)))\
$(file >> $(outfile),override type.$(type).word.unpack = $(call expr.word.unpack,$$1,$(false),$(type.$(type).word.unpack.from),$(type.$(type).word.unpack.to)))\
$(file >> $(outfile),override type.$(type).pad.pack = $(call expr.pad.pack,$$1,$(type.$(type).chars.nonws),$(type.$(type).chars.ws)))\
$(file >> $(outfile),$e)\
)
$(file >> $(outfile),$g$s<$blib.types.mak>)\
$(warning Complete.)
$(error Exiting...)
endif


#===============================================================================