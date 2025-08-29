#===============================================================================
# lib.mak
#
# Common library of types, constants, and callable functions for use.
#
# Usage:
#
#  Include in makefile:
#
#     include path/to/lib.mak
#
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
#===============================================================================


#===============================================================================
# USER CONFIGURABLE VALUES
#===============================================================================

# Line Formatting ===================== type: [line]
line.indent        ?= $s$s
info.prefix        ?= $e
warning.prefix     ?= >>
error.prefix       ?= >>

MAKE_EXIT_IF_BADSHELL ?= true

# Type Formatting ===================== type: [line]
command.prefix     ?= $(line.indent)$x$s

#===============================================================================



#===============================================================================
# SPECIAL CHARACTERS
#===============================================================================
# Types:
#   str       A string containing any characters.
#   list      A whitespace-separated list of `word`s.
#   var       The name of a variable; no whitespace.
#   char      A single character.
#   [...]     Square brackets [] specify a value which is either empty or nonempty.
#   {...}     Curly brackets {} specify a value which is always nonempty.
#-------------------------------------------------------------------------------

# Empty String ======================== type: [empty]
override empty :=# Empty String

# Logical Values ====================== type: {str}, [empty]
override true  := true
override false := $(empty)

# Whitespace Characters =============== type: {char}
override char.space := $(empty) $(empty)
override char.tab   := $(empty)	$(empty)
override define char.linefeed # BEGIN: definition must contain exactly two empty lines. Do not modify.


endef # END

# Symbols ============================= type: {char}
override char.grave  := `
override char.tilde  := ~
override char.excl   := !
override char.commat := @
override char.num    := \#$(empty)
override char.dollar := $$
override char.percnt := %
override char.hat    := ^
override char.amp    := &
override char.ast    := *
override char.lparen := (
override char.rparen := )
override char.hyphen := -
override char.lowbar := _
override char.equals := =
override char.plus   := +
override char.lsqb   := [
override char.rsqb   := ]
override char.lcub   := {
override char.rcub   := }
override char.bsol   := \$(empty)
override char.verbar := |
override char.semi   := ;
override char.colon  := :
override char.apos   := '
override char.quot   := "
override char.comma  := ,
override char.period := .
override char.lt     := <
override char.gt     := >
override char.sol    := /
override char.quest  := ?

# Character Sets ====================== type: {list{char}}
override char.lowers      := a b c d e f g h i j k l m n o p q r s t u v w x y z
override char.uppers      := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
override char.digits      := 0 1 2 3 4 5 6 7 8 9
override char.symbols     := ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , . < > / ?
override char.nonws       := $(char.lowers) $(char.uppers) $(char.digits) $(char.symbols)
override char.vars        := $(char.lowers) $(char.uppers) $(char.digits) $(filter-out = :,$(char.symbols))
override char.alphanums   := $(char.lowers) $(char.uppers) $(char.digits)
override char.letters     := $(char.lowers) $(char.uppers)

# Aliases for Common Sequences ======== type: [str]
override e    := $(empty)#         $e --> [empty]             Empty string
override s    := $(char.space)#    $s --> {space}             Space char
override t    := $(char.tab)#      $t --> {tab}               Tab char
override n    := $(char.linefeed)# $n --> {lf}                Linefeed char
override x    := $(char.dollar)#   $x --> '$'                 Expansion operator
override c    := $(char.comma)#    $c --> ','                 Comma (Argument Separator)
override h    := $(char.tilde)#    $h --> '~'                 On Unixy platforms, represents the user's $(HOME) directory when placed at the start of the path.
override g    := $(char.num)#      $g --> '#'                 Makefile comment
override l    := $(char.lparen)#   $l --> '('                 L Paren
override r    := $(char.rparen)#   $r --> ')'                 R Paren
override j    := $(char.lcub)#     $j --> '{'                 L Brace
override k    := $(char.rcub)#     $k --> '}'                 R Brace
override f    := $(char.sol)#      $f --> '/'                 Forward Slash
override b    := $(char.bsol)#     $b --> '\'                 Backslash (required to escape certain characters in paths and patterns)
override p    := $(char.percnt)#   $p --> '%'                 Wildcard for $(patsubst), $(filter), etc. (type: word.pattern); Matches 0 or more characters in a [word].
override q    := $(char.quest)#    $q --> '?'                 Wildcard for $(wildcard), file targets, prereqs, etc. (type: path.pattern); Matches 1 char in a [path].
override u    := $(char.lsqb)#     $u --> '['                 Wildcard for $(wildcard), file targets, prereqs, etc. (type: path.pattern); Matches 1 from the set of chars [...] in a path.
override v    := $(char.rsqb)#     $v --> ']'                 Wildcard for $(wildcard), file targets, prereqs, etc. (type: path.pattern); Matches 1 from the set of chars [...] in a path.
override w    := $(char.ast)#      $w --> '*'                 Wildcard for $(wildcard), file targets, prereqs, etc. (type: path.pattern); Matches 0 or more chars in a [path].
override ns   := $n$s#          $(ns) --> {lf}{space}         The string when a user passes a multiline string to a function by typing '$n\' at the end of a line.
override bs   := $b$s#          $(bs) --> '\ '                Escape sequence for {space} in [path], [path.pattern].
override bg   := $b$g#          $(bg) --> '\#'                Escape sequence for '#'
override bb   := $b$b#          $(bb) --> '\\'                Escape sequence for '\' in [word.pattern]
override bp   := $b$p#          $(bp) --> '\%'                Escape sequence for '%' in [word.pattern]
override bu   := $b$u#          $(bu) --> '\['                Escape sequence for '[' in [path.pattern]
override bv   := $b$v#          $(bv) --> '\]'                Escape sequence for ']' in [path.pattern]
override xe   := $xe#           $(xe) --> '$e' --> [empty]    Word-packed [empty].
override xs   := $xs#           $(xs) --> '$s' --> {space}    Word-packed {space}.
override xt   := $xt#           $(xt) --> '$t' --> {tab}      Word-packed {tab}.
override xn   := $xn#           $(xn) --> '$n' --> {lf}       Word-packed {linefeed}.
override xx   := $xx#           $(xx) --> '$x' --> '$'        Word-packed '$'.
override xc   := $xc#           $(xc) --> '$c' --> ','        Word-packed ','.
override xh   := $xh#           $(xh) --> '$h' --> '~'        Word-packed '~'.
override xg   := $xg#           $(xg) --> '$g' --> '#'        Word-packed '#'.
override xl   := $xl#           $(xl) --> '$l' --> '('        Word-packed '('.
override xr   := $xr#           $(xr) --> '$r' --> ')'        Word-packed ')'.
override xj   := $xj#           $(xj) --> '$j' --> '{'        Word-packed '{'.
override xk   := $xk#           $(xk) --> '$k' --> '}'        Word-packed '}'.
override xf   := $xf#           $(xf) --> '$f' --> '/'        Word-packed '\'.
override xb   := $xb#           $(xb) --> '$b' --> '\'        Word-packed '\'.
override xp   := $xp#           $(xp) --> '$p' --> '%'        Word-packed '%'.
override xq   := $xq#           $(xq) --> '$q' --> '?'        Word-packed '?'.
override xu   := $xu#           $(xu) --> '$u' --> '['        Word-packed '['.
override xv   := $xv#           $(xv) --> '$v' --> ']'        Word-packed ']'.
override xw   := $xw#           $(xw) --> '$w' --> '*'        Word-packed '*'.
override xnxs := $xn$xs#      $(xnxs) --> '$n$s' --> {lf}' '  Word-packed {lf}{space}
override xbxs := $xb$xs#      $(xbxs) --> '$b$s' --> '\ '     Word-packed '\ '
override xbxg := $xb$xg#      $(xbxg) --> '$b$g' --> '\#'     Word-packed '\#'
override xbxb := $xb$xb#      $(xbxb) --> '$b$b' --> '\\'     Word-packed '\\'
override xbxp := $xb$xp#      $(xbxp) --> '$b$p' --> '\%'     Word-packed '\%'
override xbxu := $xb$xu#      $(xbxu) --> '$b$u' --> '\['     Word-packed '\['
override xbxv := $xb$xv#      $(xbxv) --> '$b$v' --> '\]'     Word-packed '\]'

# TODO: Update 'xbb' etc in lib.mak.md

# Character Namespaces ================ type: {ns{char}}
override char.vars.symbols := char.grave char.tilde char.excl char.commat char.num \
  char.dollar char.percnt char.hat char.amp char.ast char.lparen char.rparen \
  char.hyphen char.lowbar char.equals char.plus char.lsqb char.rsqb char.lcub \
  char.rcub char.bsol char.verbar char.semi char.colon char.apos char.quot \
  char.comma char.period char.lt char.gt char.sol char.quest
override char.vars.ws := char.space char.tab char.linefeed

#-------------------------------------------------------------------------------
# [word{T}] <-- $(call type.{T}.word.pack,[T:val])
# [T]       <-- $(call type.{T}.word.unpack,[word[T]:packed_val])
# [pad]     <-- $(call type.{T}.pad.pack,[T:val])
#
# Low-level type conversion functions. Not intended for general use.
# DO NOT MODIFY: These definitions are auto-generated. See 'lib.types.mak' for details.
#-------------------------------------------------------------------------------
# <lib.types.mak>
override type.{str}.word.pack = $(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $p,$(xp),$(subst $x,$(xx),$1))))))))
override type.{str}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$(subst $(xn),$n,$1))))))))
override type.{str}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{str.pattern}.word.pack = $(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1))))))))
override type.{str.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$(subst $(xn),$n,$1))))))))
override type.{str.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{list}.word.pack = $(subst $s,$xs,$(strip $(subst $xs,$s,$(subst $n,$(xs),$(subst $t,$(xs),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $p,$(xp),$(subst $x,$(xx),$1)))))))))))
override type.{list}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$1))))))
override type.{list}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{list.pattern}.word.pack = $(subst $s,$xs,$(strip $(subst $xs,$s,$(subst $n,$(xs),$(subst $t,$(xs),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1)))))))))))
override type.{list.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$1))))))
override type.{list.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{line}.word.pack = $(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $p,$(xp),$(subst $x,$(xx),$1)))))))
override type.{line}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$1)))))))
override type.{line}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $t,.,$(subst $s,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{line.pattern}.word.pack = $(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1)))))))
override type.{line.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$1)))))))
override type.{line.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $t,.,$(subst $s,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{word}.word.pack = $(subst $b,$(xb),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $p,$(xp),$(subst $x,$(xx),$1)))))
override type.{word}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xb),$b,$1)))))
override type.{word}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{word.pattern}.word.pack = $(subst $b,$(xb),$(subst $v,$(xv),$(subst $u,$(xu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1)))))
override type.{word.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xb),$b,$1)))))
override type.{word.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{path}.word.pack = $(subst $(xt),$t,$(subst $(xn),$n,$(subst $(xe),,$(subst $s,/,$(strip $(subst /,$s,$(xe)$(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$f,$(subst $(bb),$(xbxb),$(subst $s,$(xbxs),$(subst $(bs),$(xbxs),$(subst $v,$(xbxv),$(subst $(bv),$(xbxv),$(subst $u,$(xbxu),$(subst $(bu),$(xbxu),$(subst $p,$(xp),$(subst $x,$(xx),$1))))))))))))$(xe)))))))
override type.{path}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$1))))))
override type.{path}.pad.pack = $(subst /,.,$(subst .,.,$(subst $c,.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{path.pattern}.word.pack = $(subst $(xt),$t,$(subst $(xn),$n,$(subst $(xe),,$(subst $s,/,$(strip $(subst /,$s,$(xe)$(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$f,$(subst $(bb),$(xbxb),$(subst $s,$(xbxs),$(subst $(bs),$(xbxs),$(subst $(bv),$(xbxv),$(subst $(bu),$(xbxu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1))))))))))$(xe)))))))
override type.{path.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xu),$u,$(subst $(xv),$v,$(subst $(xs),$s,$(subst $(xb),$b,$1))))))
override type.{path.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst .,.,$(subst $c,.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{paths}.word.pack = $(subst $(xn),$n,$(subst $s,$xs,$(strip $(subst $xs,$s,$(subst $n,$(xn),$(subst $t,$(xs),$(subst $b,$f,$(subst $(bb),$(xbxb),$(subst $s,$(xs),$(subst $(bs),$(xbxs),$(subst $v,$(xbxv),$(subst $(bv),$(xbxv),$(subst $u,$(xbxu),$(subst $(bu),$(xbxu),$(subst $p,$(xp),$(subst $x,$(xx),$1))))))))))))))))
override type.{paths}.word.unpack = $1
override type.{paths}.pad.pack = $(subst /,.,$(subst .,.,$(subst $c,.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $t,.,$(subst $s,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{paths.pattern}.word.pack = $(subst $(xn),$n,$(subst $s,$xs,$(strip $(subst $xs,$s,$(subst $n,$(xn),$(subst $t,$(xs),$(subst $b,$f,$(subst $(bb),$(xbxb),$(subst $s,$(xs),$(subst $(bs),$(xbxs),$(subst $(bv),$(xbxv),$(subst $(bu),$(xbxu),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1))))))))))))))
override type.{paths.pattern}.word.unpack = $1
override type.{paths.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst .,.,$(subst $c,.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $t,.,$(subst $s,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{int}.word.pack = $(subst $(char.plus),$e,$1)
override type.{int}.word.unpack = $1
override type.{int}.pad.pack = $(subst -,.,$(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1))))))))))))

override type.{int.pattern}.word.pack = $1
override type.{int.pattern}.word.unpack = $1
override type.{int.pattern}.pad.pack = $(subst $p,.,$(subst -,.,$(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1)))))))))))))

override type.{uint}.word.pack = $(subst $(char.plus),$e,$1)
override type.{uint}.word.unpack = $1
override type.{uint}.pad.pack = $(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1)))))))))))

override type.{uint.pattern}.word.pack = $1
override type.{uint.pattern}.word.unpack = $1
override type.{uint.pattern}.pad.pack = $(subst $p,.,$(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1))))))))))))

override type.{idx}.word.pack = $(subst $(char.plus),$e,$1)
override type.{idx}.word.unpack = $1
override type.{idx}.pad.pack = $(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1)))))))))))

override type.{idx.pattern}.word.pack = $1
override type.{idx.pattern}.word.unpack = $1
override type.{idx.pattern}.pad.pack = $(subst $p,.,$(subst +,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$1))))))))))))

override type.{var}.word.pack = $(subst $b,$(xb),$(subst $p,$(xp),$(subst $x,$(xx),$1)))
override type.{var}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xb),$b,$1)))
override type.{var}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{expr}.word.pack = $(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $p,$(xp),$(subst $x,$(xx),$1))))))
override type.{expr}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$(subst $(xn),$n,$1))))))
override type.{expr}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

override type.{expr.pattern}.word.pack = $(subst $n,$(xn),$(subst $t,$(xt),$(subst $b,$(xb),$(subst $s,$(xs),$(subst $(bp),$(xbxp),$(subst $x,$(xx),$1))))))
override type.{expr.pattern}.word.unpack = $(subst $(xx),$x,$(subst $(xp),$p,$(subst $(xs),$s,$(subst $(xb),$b,$(subst $(xt),$t,$(subst $(xn),$n,$1))))))
override type.{expr.pattern}.pad.pack = $(subst ?,.,$(subst /,.,$(subst >,.,$(subst <,.,$(subst .,.,$(subst $c,.,$(subst ",.,$(subst ',.,$(subst :,.,$(subst ;,.,$(subst |,.,$(subst $b,.,$(subst $k,.,$(subst $j,.,$(subst $v,.,$(subst $u,.,$(subst +,.,$(subst =,.,$(subst _,.,$(subst -,.,$(subst $r,.,$(subst $l,.,$(subst *,.,$(subst &,.,$(subst ^,.,$(subst $p,.,$(subst $x,.,$(subst #,.,$(subst @,.,$(subst !,.,$(subst ~,.,$(subst `,.,$(subst 9,.,$(subst 8,.,$(subst 7,.,$(subst 6,.,$(subst 5,.,$(subst 4,.,$(subst 3,.,$(subst 2,.,$(subst 1,.,$(subst 0,.,$(subst Z,.,$(subst Y,.,$(subst X,.,$(subst W,.,$(subst V,.,$(subst U,.,$(subst T,.,$(subst S,.,$(subst R,.,$(subst Q,.,$(subst P,.,$(subst O,.,$(subst N,.,$(subst M,.,$(subst L,.,$(subst K,.,$(subst J,.,$(subst I,.,$(subst H,.,$(subst G,.,$(subst F,.,$(subst E,.,$(subst D,.,$(subst C,.,$(subst B,.,$(subst A,.,$(subst z,.,$(subst y,.,$(subst x,.,$(subst w,.,$(subst v,.,$(subst u,.,$(subst t,.,$(subst s,.,$(subst r,.,$(subst q,.,$(subst p,.,$(subst o,.,$(subst n,.,$(subst m,.,$(subst l,.,$(subst k,.,$(subst j,.,$(subst i,.,$(subst h,.,$(subst g,.,$(subst f,.,$(subst e,.,$(subst d,.,$(subst c,.,$(subst b,.,$(subst a,.,$(subst $n,.,$(subst $t,.,$(subst $s,.,$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

# <\lib.types.mak>

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# word.pack             	[word[T]] <-- $(call word.pack,[type:T],[T:val])
# word.unpack           	[T]       <-- $(call word.unpack,[type:T],[word[T]:packed_val])
#
#	Pack:   Encodes [val] as a single word so that list and filename operations work correctly.
#	          T = '{T}': If [val] is [empty], returns [empty].
#	          T = '[T]': If [val] is [empty], returns '$e' (packed [empty]).
#	Unpack: Decodes a [packed_val], which (typically) returns the original value of [val].
#	          T = '{T}': Occurrances of '$e' are kept while unpacking [val].
#	          T = '[T]': Occurrances of '$e' are removed before unpacking [val].
#
#	Type [type:T] specifies the word encoder/decoder. While type '[str]' works correctly for any
#	  value, using the most specific type is generally the most efficient, and may produce better
#	  results (fixes for problematic formatting, etc.).
#	  [type:T] = ''        No encoder/decoder is used. [val] is returned unmodified.
#	  [type:T] = '{T}'     Specifies a type which is necessarily nonempty. [empty] and '$e' are ignored.
#	  [type:T] = '[T]'     Specifies a type which includes the [empty] string. [empty] and '$e' are handled.
#	  [type:T] = 'T'       Same as [T].
#-------------------------------------------------------------------------------
override word.pack   = $(if $1,$(if $(filter {%},$1),$(if $2,$(call type.$1.word.pack,$2)),$(if $2,$(call type.{$(1:[%]=%)}.word.pack,$2),$(xe))),$2)
override word.unpack = $(if $1,$(if $(filter {%},$1),$(if $2,$(call type.$1.word.unpack,$2)),$(if $2,$(call type.{$(1:[%]=%)}.word.unpack,$(subst $(xe),$e,$2)))),$2)


#-------------------------------------------------------------------------------
# word.repack           	[word[T]] <-- $(call word.repack,[type:T],[word[T]:packed_val])
# normalize             	[T]       <-- $(call normalize,[type:T],[T:val])
#
#	Repack:    Unpacks and re-Packs a word of type [word[T]].
#	Normalize: Packs and Unpacks a string of type [T].
#
#	In most cases, [val] is returned unmodified.
#	However, for some types `word.pack` adjusts or fixes problematic formatting;
#	these functions propagate those changes.
#-------------------------------------------------------------------------------
override word.repack = $(call word.pack,$1,$(call word.unpack,$1,$2))
override normalize   = $(call word.unpack,$1,$(call word.pack,$1,$2))


#-------------------------------------------------------------------------------
# word.join.pair        	[word[T]] <-- $(call word.join.pair,[type:T],[word[T]:sep],[word[T]:1],[word[T]:2])
# normalize.pair        	[T]       <-- $(call normalize.pair,[type:T],[T:sep],[T:1],[T:2])
#
#	Joins two values into one using [sep].
#	If [1] or [2] are [empty] (or unpack to [empty]), no [sep] is added.
#	Result is repacked/normalized.
#	If [T] is omitted, both functions are equivalent to `$(call str.concat.pair,[sep],[1],[2])`.
#
#-------------------------------------------------------------------------------
override word.join.pair = $(call word.pack,$1,$(call str.concat.pair,$2,$(call word.unpack,$1,$3),$(call word.unpack,$1,$4)))
override normalize.pair = $(call normalize,$1,$(call str.concat.pair,$2,$3,$4))


#===============================================================================
# VARIABLES
#===============================================================================



#-------------------------------------------------------------------------------
# var.is.shortname      	[bool:var] <-- $(call var.is.shortname,[var])
# var.is.defined        	[bool:var] <-- $(call var.is.defined,[var])
# var.is.undefined      	[bool:var] <-- $(call var.is.undefined,[var])
# var.is.environment    	[bool:var] <-- $(call var.is.environment,[var])
# var.is.commandline    	[bool:var] <-- $(call var.is.commandline,[var])
# var.is.makefile       	[bool:var] <-- $(call var.is.makefile,[var])
# var.is.internal       	[bool:var] <-- $(call var.is.internal,[var])
# var.is.ws             	[bool:var] <-- $(call var.is.ws,[var])
# var.is.nonws          	[bool:var] <-- $(call var.is.nonws,[var])
# var.is.empty          	[bool:var] <-- $(call var.is.empty,[var])
# var.is.def.empty      	[bool:var] <-- $(call var.is.def.empty,[var])
# var.is.nonempty       	[bool:var] <-- $(call var.is.nonempty,[var])
#-------------------------------------------------------------------------------
override var.is.shortname   = $(filter $(char.vars:\%=\%),$1)
override var.is.defined     = $(if $(filter-out undefined,$(flavor $1)),$1)
override var.is.undefined   = $(if $(filter undefined,$(flavor $1)),$1)
override var.is.environment = $(if $(filter environment,$(origin $1)),$1)
override var.is.commandline = $(if $(filter command,$(origin $1)),$1)
override var.is.makefile    = $(if $(findstring environment,$(origin $1)),,$(if $(filter file override,$(origin $1)),$1))
override var.is.internal    = $(if $(filter default automatic,$(origin $1)),$1)
override var.is.ws          = $(and $($1),$(if $(strip $($1)),,$1))
override var.is.nonws       = $(and $($1),$(if $(or $(findstring $s,$($1)),$(findstring $t,$($1)),$(findstring $n,$($1))),,$1))
override var.is.empty       = $(if $($1),,$1)
override var.is.def.empty   = $(and $(call var.is.empty,$1),$(call var.is.defined,$1))
override var.is.nonempty    = $(if $($1),$1)


#-------------------------------------------------------------------------------
# var.push        	[empty] <-- $(call var.push,[var],[type:T],[T:val])
# var.pop         	[empty] <-- $(call var.pop,[var])
#
#	Push: Stores the current value of a variable to an internal stack structure,
#	      then assigns the new value to the variable.
#	Pop:  Restores the previous value of a variable.
#
#	The variable 'flavor' (simple or recursive) is maintained through push/pop
#	operations.
#	- If [type:T] is nonempty, [val] is treated literally, and is assigned "simply" with ':='.
#	- If [type:T] is omitted, [val] must be a valid expression, and is assigned "recursively" with '='.
#	The internal stack can be accessed via $(var.{var}.stack)
#-------------------------------------------------------------------------------
var.push = $(if $1,$(eval var.$1.stack += $(subst $x,$(xx),$(call word.pack,expr,$1$(if $(filter recursive,$(flavor $1)),=,:=)$(value $1)))$n$1$(if $2,:=$(call word.pack,$2,$3),=$3)))
var.pop  = $(if $1,$(eval $(call word.unpack,expr,$(lastword $(var.$1.stack)))$nvar.$1.stack := $$(wordlist 2,$$(words $$(var.$1.stack)),x $$(var.$1.stack))))


#-------------------------------------------------------------------------------
# var.set       	[empty] <-- $(call var.set,[directives],[var],[type:T],[T:val])
# var.append    	[empty] <-- $(call var.append,[directives],[var],[type:T],[T:val])
#
#	Assigns a value to a variable.
#	- If [type:T] is nonempty, [val] is treated literally, and is assigned "simply" with ':=' or '+='
#	- If [type:T] is omitted, [val] must be a valid expression, and is assigned "recursively" with '=' or '+='.
#-------------------------------------------------------------------------------
var.set    = $(if $2,$(eval $(call expr.assign,$1,$2,$(if $3,:=,=),$(call word.pack,$3,$4))))
var.append = $(if $2,$(eval $(call expr.assign,$1,$2,+=,$(call word.pack,$3,$4))))



#===============================================================================
# LISTS
#===============================================================================
# A list is a whitespace-separated list of words. Many built-in functions
# operate on lists word-for-word. Recipe targets and prerequisites also
# accept lists of files. Therefore, it is extremely useful to have tools
# for manipulating such lists.
#
# Individual words cannot be empty or contain whitespace. Such strings must be
# escaped before list insertion, and de-escaped upon retrieval.
#-------------------------------------------------------------------------------
#
# Types:
#	str           A string containing any characters.
#	line          A {str} containing a single line; may contain whitespace, but no linefeeds.
#	word          A {str} containing a single word; no whitespace.
#	word[type]    A packed [word} containing an escaped string of [type] (which may be {type} or [empty]).
#	                  The original value may have contained any characters allowed for that [type].
#	list          A whitespace-separated list of plain {word} values.
#	                  Operations on a plain `list` take the value of each word literally.
#	list[type]    A list of packed words, where each word is a {word[type]}.
#	                  Operations on a packed `list` transparently pack/unpack each word as-needed;
#	                  For example, `list[str].append` first escapes a nonempty {str} or [empty] value,
#	                    then appends the escaped [str] to the list as a {word[str]}.
#	idx           An integer >= 1 representing a {word}'s position in a `list`.
#	                  idx > $(words [list]) typically results in a no-op.
#	                  idx < 1 is invalid and typically throws an error.
#===============================================================================


#-------------------------------------------------------------------------------
# str.split         	[list[T]] <-- $(call str.split,[type:T],[str],[str:sep])
# list.merge        	[str]     <-- $(call list.merge,[type:T],[list[T]],[str:sep])
#
#	Converts a string to a list, or a list to a string.
#	Split:
#	1. If T is provided, packs both [str] and [sep] as type [word[T]].
#	2. Splits [str] on [sep], resulting in a [list[T]]:
#	   If T == '[T]', then [empty] is a valid string, so empty words are KEPT.
#	   If T == '{T}', then [empty] cannot be encoded/decoded, so empty words are REMOVED.
#
#	Merge:
#	1. If T is provided, packs [sep] as type [word[T]].
#	2. Strips [list], then replaces each space ' ' with [sep].
#	3. Unpacks result to [str].
#	   If T == '[T]', then packed [empty] '$e' values are removed.
#	   If T == '{T}', then '$e' values are returned unmodified.
#
#	Note: Since '$e' is not removed until the final step, empty words
#	  are still wrapped with [sep]. Therefore there will always be
#	  ( $(words [list]) - 1 ) occurrances of [sep] in [str].
#	  To remove empty words in a list, use `list.prune` instead.
#-------------------------------------------------------------------------------
override str.split  = $(if $(call word.pack,$1,$3),$(foreach __word,$(subst $(call word.pack,$1,$3),$(call word.pack,$1)$s$(call word.pack,$1),$(call word.pack,$1,$2)),$(call word.repack,$1,$(__word))),$(call word.pack,$1,$2))
override list.merge = $(call word.unpack,$1,$(subst $s,$(call word.pack,$1,$3),$(strip $2)))



#-------------------------------------------------------------------------------
# list.format       	[list[T]] <-- $(call list.format,[type:T],$n\
#                   	                  item 1$n\
#                   	                  item 2$n\
#                   	              )
#
#	Convenience method for manual list definition.
#	Splits the second argument on {tab} and {lf}, encoding each section as a word-packed T.
#	- Each line must end with '$n\'.
#	- Leading whitespace is removed. Trailing whitespace is kept.
#	- If T == '[T]', then [empty] is a valid string, so empty words are KEPT.
#	- If T == '{T}', then [empty] cannot be encoded/decoded, so empty words are REMOVED.
#-------------------------------------------------------------------------------
override list.format = $(call str.split,$1,$(subst $(ns),$n,$(subst $t,$(ns),$2),$n))



#-------------------------------------------------------------------------------
# list.prune        	[list[T]] <-- $(call list.prune,[type:T],[list[T]])
# list.repack       	[list[T]] <-- $(call list.repack,[type:T],[list[T]])
#
#	Trim:   Removes all occurrances of packed-[empty] from the list.
#	        Words which contain *only* [empty] are removed.
#	Repack: Repacks each individual word in the list.
#	        All occurrances of packed-[empty] are removed,
#	        but words which contain *only* [empty] are reduced to a single [empty].
#
#	For types [T]==[empty] or [T]=='{T}', no packed-[empty] value is defined, so
#	nothing is removed.
#-------------------------------------------------------------------------------
override list.prune  = $(strip $(subst $(call word.pack,$1),,$2))
override list.repack = $(foreach __word,$2,$(call word.repack,$1,$(__word)))



#-------------------------------------------------------------------------------
# list.filter           	[list[T]] <-- $(call list.filter,[type:T],[list[T]],[T:val])
# list.filter-out       	[list[T]] <-- $(call list.filter-out,[type:T],[list[T]],[T:val])
# list.filter-out.start 	[list]    <-- $(call list.filter-out.start,[list:in],[list:filter-out])
# list.filter-out.end   	[list]    <-- $(call list.filter-out.end,[list:in],[list:filter-out])
#
#	Returns a [list] of words equal (or not-equal) to [val].
#-------------------------------------------------------------------------------
override list.filter           = $(filter $(call word.pack,$1,$3),$2)
override list.filter-out       = $(filter-out $(call word.pack,$1,$3),$2)
override list.filter-out.start = $(if $(filter $2,$(firstword $1)),$(call $0,$(wordlist 2,$(words $1),$1),$2),$1)
override list.filter-out.end   = $(if $(filter $2,$(lastword $1)),$(call $0,$(wordlist 2,$(words $1),x $1),$2),$1)



#-------------------------------------------------------------------------------
# list.join     	[list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2])
# list.join.2   	[list[list[T]]] <-- $(call list.join.{N},[list[T]:1],[list[T]:N])
# list.join.3
# list.join.4
#
#	Combines N lists into 1 list[list].
#	1. Iterates over N [list[T]] in parallel.
#	2. For each set of N [word[T]], merges them into a [list[T]],
#	     and packs that list into a single-word {word[list[T]]}.
#        Shorter lists are padded with '$e'. Empty lists are all '$e'.
#	3. Returns the resulting list of word-packed lists: [list[list[T]]],
#	   or [empty] if all lists omitted.
#
#-------------------------------------------------------------------------------
override list.join   = $(call list.join.2,$1,$2)# Alias
override list.join.2 = $(strip $(if $(firstword $1$2)    ,$(call word.pack,{list},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e))$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2))))
override list.join.3 = $(strip $(if $(firstword $1$2$3)  ,$(call word.pack,{list},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e)$s$(or $(firstword $3),$$e))$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3))))
override list.join.4 = $(strip $(if $(firstword $1$2$3$4),$(call word.pack,{list},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e)$s$(or $(firstword $3),$$e)$s$(or $(firstword $4),$$e)$s)$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4))))


#-----------------------------------------------------------
# list.map      	[list[T]] <-- $(call list.map.{N},[type:T],const1],...)
# list.map.1    	                              [func[T]([T:1],...,[T:N],[str:const1],...)],
# list.map.2    	                              [list[T]:1],...,[list[T]:N],
# list.map.3    	                              [str:const1],...
# list.map.4    	               )
#
#	Maps N lists to 1 list.
#	1. Iterates over N [list[T]]s in parallel.
#	2  For each set of N [word[T]], calls [func] with:
#	     [T:1]...[T:N]   Unpacked words from each list.
#	     [const1]...     Additional arguments, passed to [func] unmodified.
#	   The result of [func] is packed as word[T] and appended to a new list.
#	3. Returns the [list[T]] of words produced by [func].
#
#-------------------------------------------------------------------------------
override list.map   = $(call list.map.1,$1,$2,$3,$4,$5,$6,$7)
override list.map.1 = $(foreach __word,$3,$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(__word)),$4,$5,$6,$7)))
override list.map.2 = $(if $(firstword $3$4),    $(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$5,$6,$7,$8,,,$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$5,$6,$7,$8))),$(strip $(11)))
override list.map.3 = $(if $(firstword $3$4$5),  $(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$6,$7,$8,$9,,$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$6,$7,$8,$9))),$(strip $(11)))
override list.map.4 = $(if $(firstword $3$4$5$6),$(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$7,$8,$9,$(10),$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$(call word.unpack,$1,$(firstword $6)),$7,$8,$9,$(10)))),$(strip $(11)))


#-------------------------------------------------------------------------------
# list.reduce       	[str] <-- $(call list.reduce.{N},[type:T],
# list.reduce.1     	                             [func[str]([str:acc],[T:1],...,[T:N],[str:const1],...)],
# list.reduce.2     	                             [str:acc],
# list.reduce.3     	                             [list[T]:1],...,[list[T]:N],
# list.reduce.4     	                             [str:const1],...
#                   	           )
#
#	Maps N lists to 1 string.
#	1. Iterates over N [list[T]]s in parallel.
#	2  For each set of N [word[T]], calls [func] with:
#	     [acc]           The result of the previous iteration.
#	     [T:1]...[T:N]   Unpacked words from each list.
#	     [const1]...     Additional arguments passed to reduce.
#	   The result of [func] is passed to the next iteration's [acc], unmodified.
#	3. Returns the final value of [acc] produced by [func].
#
#-------------------------------------------------------------------------------
override list.reduce   = $(call list.reduce.1,$1,$2,$3,$4,$5,$6,$7,$8)# Alias
override list.reduce.1 = $(if $(firstword $4)      ,$(call $0,$1,$2,$(call $2,$3,$(call word.unpack,$1,$(firstword $4)),$5,$6,$7,$8),$(wordlist 2,$(words $4),$4),$5,$6,$7,$8),$3)
override list.reduce.2 = $(if $(firstword $4$5)    ,$(call $0,$1,$2,$(call $2,$3,$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$6,$7,$8,$9),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$6,$7,$8,$9),$3)
override list.reduce.3 = $(if $(firstword $4$5$6)  ,$(call $0,$1,$2,$(call $2,$3,$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$(call word.unpack,$1,$(firstword $6)),$7,$8,$9,$(10)),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$7,$8,$9,$(10)),$3)
override list.reduce.4 = $(if $(firstword $4$5$6$7),$(call $0,$1,$2,$(call $2,$3,$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$(call word.unpack,$1,$(firstword $6)),$(call word.unpack,$1,$(firstword $7)),$8,$9,$(10),$(11)),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$(wordlist 2,$(words $7),$7),$8,$9,$(10),$(11)),$3)


#-------------------------------------------------------------------------------
# list.reverse      	[list[T]] <-- $(call list.reverse,[list[T]])
#
#	Reverses the order of words in a list.
#
#-------------------------------------------------------------------------------
override list.reverse = $(if $(word 2,$1),$(call list.reverse,$(wordlist 2,$(words $1),$1))$s$(firstword $1),$1)



#-------------------------------------------------------------------------------
# list.idx          	[idx] <-- $(call list.idx,[list[T]],[int:idx])
# list.idx.prev     	[idx] <-- $(call list.idx.prev,[list[T]],[int:idx])
# list.idx.next     	[idx] <-- $(call list.idx.next,[list[T]],[int:idx])
# list.idx.first    	[idx] <-- $(call list.idx.first,[list[T]])
# list.idx.last     	[idx] <-- $(call list.idx.last,[list[T]])
#
#	Returns [idx] if in the range [1,$(words [list])],
#	or [empty] if out-of-range, or if [list] is [empty].
#
#-------------------------------------------------------------------------------
override __list.idx.dec = $(if $2,$(words $(wordlist 2,$2,$1 +1)))# [uint] <-- clamp([uint:2]-1,0,len(list:1))
override __list.idx.inc = $(if $2,$(words $(wordlist 1,$2,$1) +1))# [uint] <-- clamp([uint:2]+1,1,len(list:1)+1)
override list.idx       = $(and $(filter-out 0,$2),$(word $2,$1),$2)
override list.idx.prev  = $(filter-out 0 $(words $1 +1),$(call __list.idx.dec,$1 +1,$2))
override list.idx.next  = $(filter-out   $(words $1 +1),$(call __list.idx.inc,$1   ,$2))
override list.idx.first = $(if $(firstword $1),1)
override list.idx.last  = $(filter-out 0,$(words $1))


#-------------------------------------------------------------------------------
# list.insert   	[list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
# list.prepend  	[list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])
# list.append   	[list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])
#
#	Inserts the value of type [T] at [idx] in the list.
#	Word-packs [val] before storage, if necessary.
#
#-------------------------------------------------------------------------------
override list.insert.N = $(strip $(if $4,$(wordlist 1,$(call __list.idx.dec,$2,$4),$2)$s$(call word.pack,$1,$3)$s$(wordlist $4,$(words $2),$2),$2))
override list.insert   = $(call list.insert.N,$1,$2,$3,$(call list.idx,$2$s$$,$4))
override list.prepend  = $(strip $(call word.pack,$1,$3) $2)
override list.append   = $(strip $2 $(call word.pack,$1,$3))


#-------------------------------------------------------------------------------
# list.remove       	[list[T]] <-- $(call list.remove,[list[T]],[idx])
# list.remove.first 	[list[T]] <-- $(call list.remove.first,[list[T]])
# list.remove.last  	[list[T]] <-- $(call list.remove.last,[list[T]])
#
#	Removes the value at [idx] from the list.
#
#-------------------------------------------------------------------------------
override list.remove.N     = $(strip $(if $2,$(wordlist 1,$(call __list.idx.dec,$1,$2),$1)$s$(wordlist $(call __list.idx.inc,$1,$2),$(words $1),$1),$1))
override list.remove       = $(call list.remove.N,$1,$(call list.idx,$1,$2))
override list.remove.first = $(wordlist 2,$(words $1),$1)
override list.remove.last  = $(wordlist 2,$(words $1),x $1)


#-------------------------------------------------------------------------------
# list.get          	[T] <-- $(call list.get,[type:T],[list[T]],[idx])
# list.get.first    	[T] <-- $(call list.get.first,[type:T],list[T]])
# list.get.last     	[T] <-- $(call list.get.last,[type:T],list[T]])
#
#	Returns the original (unpacked) value of type [T] from [idx].
#
#-------------------------------------------------------------------------------
override list.get.N     = $(call word.unpack,$1,$(if $3,$(word $3,$2)))
override list.get       = $(call list.get.N,$1,$2,$(call list.idx,$2,$3))
override list.get.first = $(call word.unpack,$1,$(firstword $2))
override list.get.last  = $(call word.unpack,$1,$(lastword $2))


#-------------------------------------------------------------------------------
# list.set          	[list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])
# list.set.first    	[list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])
# list.set.last     	[list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])
#
#	Replaces value of type [T] at [idx] with [val]
#	Word-packs [val] before storage, if necessary.
#
#-------------------------------------------------------------------------------
override list.set.N     = $(strip $(if $4,$(wordlist 1,$(call __list.idx.dec,$2,$4),$2)$s$(call word.pack,$1,$3)$s$(wordlist $(call __list.idx.inc,$2,$4),$(words $2),$2),$2))
override list.set       = $(call list.set.N,$1,$2,$3,$(call list.idx,$2,$4))
override list.set.first = $(call list.set.N,$1,$2,$3,$(call list.idx.first,$2))
override list.set.last  = $(call list.set.N,$1,$2,$3,$(call list.idx.last,$2))




#-------------------------------------------------------------------------------
# str.equ   	[str] <-- $(call str.equ,[str:1],[str:2])
# str.neq   	[str] <-- $(call str.neq,[str:1],[str:2])
#
#	Returns {true} if the strings are equal (or notequal).
#-------------------------------------------------------------------------------
override str.equ = $(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(false),$(true))
override str.neq = $(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(true),$(false))



#-------------------------------------------------------------------------------
# str.concat.pair   	[str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
# str.concat        	[str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])
#
#	Concatentates each nonempty [str] argument with the given separator [sep].
#	Each [empty] argument is skipped; no separator is included for them.
#
#-------------------------------------------------------------------------------
override str.concat.pair = $(if $(and $2,$3),$2$1$3,$(or $2,$3))
override str.concat = $(if $(or $3,$4,$5,$6,$7,$8,$9),$(call str.concat.pair,$1,$2,$(call str.concat,$1,$3,$4,$5,$6,$7,$8,$9)),$2)



#-----------------------------------------------------------
# str.map           	[str] <-- $(call str.map.{N},[type:T],
# str.map.1         	              [func[T]([T:1],...,[T:N],[str:const1],...)],
# str.map.2         	              [str:sep],
# str.map.3         	              [str:1],...,[str:N],
# str.map.4         	              [str:const1],...)
#
#	Wrapper for list.map, but operates directly on [str] instead of [list], handling the list conversions internally.
#	1. Splits each string ([str:1] to [str:N]) on [sep], resulting in N lists of type [list[T]].
#	     If T == 'T' or '[T]', empty substrings are KEPT.
#	     If T == '{T}',        empty substrings are REMOVED.
#	2. Iterates over each [list[T]] in parallel. Each iteration, calls [func] with:
#	     [T:1]...[T:N]   Unpacked words from each list.
#	     [const1]...     Additional arguments, passed to [func] unmodified.
#	3. If [T] is nonempty, encodes the value returned by [func] as a packed [word[{T}]]
#	4. Merges the resulting list with [sep], and decodes it to [str].
#
#-------------------------------------------------------------------------------
override str.map   = $(call str.map.1,$1,$2,$3,$4,$5,$6,$7,)
override str.map.1 = $(call list.merge,$1,$(call list.map$(suffix $0),$1,$2,$(call str.split,$1,$4,$3),$5,$6,$7,$8),$3)
override str.map.2 = $(call list.merge,$1,$(call list.map$(suffix $0),$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$6,$7,$8,$9),$3)
override str.map.3 = $(call list.merge,$1,$(call list.map$(suffix $0),$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$(call str.split,$1,$6,$3),$7,$8,$9,$(10)),$3)
override str.map.4 = $(call list.merge,$1,$(call list.map$(suffix $0),$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$(call str.split,$1,$6,$3),$(call str.split,$1,$7,$3),$8,$9,$(10),$(11)),$3)


#-------------------------------------------------------------------------------
# str.indent.add    	[str] <-- $(call str.indent.add,[str:multiline],[str:indent])
# str.indent.set    	[str] <-- $(call str.indent.set,[str:multiline],[str:indent])
#
#	Add: For each line in [multiline], prefixes with [indent].
#	Set: For each line in [multiline], removes leading whitespace, then prefixes with [indent].
#
#-------------------------------------------------------------------------------
override str.indent.add = $2$(subst $n,$n$2,$1)
override str.indent.set = $(call str.indent.add,$(call str.map,line,str.strip.start,$n,$1,s t),$2)



#===============================================================================
# STRING SUBSTITUTION
#===============================================================================
# Arguments:        If Argument Omitted:           If Argument Provided:
#  [var:find]        Nothing is matched             Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [list{var}:find]  Nothing is matched             Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [str:find]        Nothing is matched             Matches   {str}  in [in]
#  [list:find]       Nothing is matched             Matches  {word}  in [in]
#
#  [var:repl]       Nothing is replaced             Replaces matches with $({var})
#  [list{var}:repl] Nothing is replaced             Replaces matches with $({var})
#  [str:repl]       Replaces matches with [empty]   Replaces matches with   {str}
#  [list:repl]      Replaces matches with [empty]   Replaces matches with  {word}
#
#===============================================================================

#-------------------------------------------------------------------------------
# Subst: Single Match, Single Replace
#-------------------------------------------------------------------------------
# str.subst.str2str     	[str] <-- $(call str.subst.str2str,[str:in],[str:find],[str:repl])
# str.subst.str2var     	[str] <-- $(call str.subst.str2var,[str:in],[str:find],[var:repl])
# str.subst.var2str     	[str] <-- $(call str.subst.var2str,[str:in],[var:find],[str:repl])
# str.subst.var2var     	[str] <-- $(call str.subst.var2var,[str:in],[var:find],[var:repl])
# str.prefix.str        	[str] <-- $(call str.prefix.str,[str:in],[str:find],[str:prefix])
# str.prefix.var        	[str] <-- $(call str.prefix.var,[str:in],[var:find],[str:prefix])
# str.suffix.str        	[str] <-- $(call str.suffix.str,[str:in],[str:find],[str:suffix])
# str.suffix.var        	[str] <-- $(call str.suffix.var,[str:in],[var:find],[str:suffix])
# str.wrap.str          	[str] <-- $(call str.wrap.str,[str:in],[str:find],[str:prefix],[str:suffix])
# str.wrap.var          	[str] <-- $(call str.wrap.var,[str:in],[var:find],[str:prefix],[str:suffix])
# str.strip.str         	[str] <-- $(call str.strip.str,[str:in],[str:strip])
# str.strip.str.start   	[str] <-- $(call str.strip.str.start,[str:in],[str:strip])
# str.strip.str.end     	[str] <-- $(call str.strip.str.end,[str:in],[str:strip])
# str.strip.var         	[str] <-- $(call str.strip.var,[str:in],[var:strip])
# str.strip.var.start   	[str] <-- $(call str.strip.var.start,[str:in],[str:strip])
# str.strip.var.end     	[str] <-- $(call str.strip.var.end,[str:in],[str:strip])
#
#-------------------------------------------------------------------------------
#	[word[str]] <-- $(call __str.strip.one      ,[word[str]:in],[word[str]:strip])
#	[word[str]] <-- $(call __str.strip.one.start,[word[str]:in],[word[str]:strip])
#	[word[str]] <-- $(call __str.strip.one.end  ,[word[str]:in],[word[str]:strip])
override __str.strip.one        = $(subst $s,$2,$(strip $(subst $2,$s,$1)))
override __str.strip.one.start  = $(subst $s,,$(call list.filter-out.start,$(subst $2,$s$2$s,$1),$2))
override __str.strip.one.end    = $(subst $s,,$(call list.filter-out.end,$(subst $2,$s$2$s,$1),$2))
#-------------------------------------------------------------------------------
override str.subst.str2str   = $(if         $2     ,$(subst $2,$3,$1),$1)
override str.subst.str2var   = $(if $(and   $2 ,$3),$(subst $2,$($3),$1),$1)
override str.subst.var2str   = $(if       $($2)    ,$(subst $($2),$3,$1),$(if $1,$1,$(if $2,$3)))
override str.subst.var2var   = $(if $(and $($2),$3),$(subst $($2),$($3),$1),$(if $1,$1,$(if $2,$($3))))
override str.prefix.str      = $(if         $2     ,$(subst $2,$3$2,$1),$1)
override str.prefix.var      = $(if       $($2)    ,$(subst $($2),$3$($2),$1),$(if $1,$1,$(if $2,$3)))
override str.suffix.str      = $(if         $2     ,$(subst $2,$2$3,$1),$1)
override str.suffix.var      = $(if       $($2)    ,$(subst $($2),$($2)$3,$1),$(if $1,$1,$(if $2,$3)))
override str.wrap.str        = $(if         $2     ,$(subst $2,$3$2$4,$1),$1)
override str.wrap.var        = $(if       $($2)    ,$(subst $($2),$3$($2)$4,$1),$(if $1,$1,$(if $2,$3)))
override str.strip.str       = $(call word.unpack,[str],$(call __str.strip.one,$(call word.pack,{str},$1),$(call word.pack,{str},$2)))
override str.strip.str.start = $(call word.unpack,[str],$(call __str.strip.one.start,$(call word.pack,{str},$1),$(call word.pack,{str},$2)))
override str.strip.str.end   = $(call word.unpack,[str],$(call __str.strip.one.end,$(call word.pack,{str},$1),$(call word.pack,{str},$2)))
override str.strip.var       = $(call word.unpack,[str],$(call __str.strip.one,$(call word.pack,{str},$1),$(call word.pack,{str},$($2))))
override str.strip.var.start = $(call word.unpack,[str],$(call __str.strip.one.start,$(call word.pack,{str},$1),$(call word.pack,{str},$($2))))
override str.strip.var.end   = $(call word.unpack,[str],$(call __str.strip.one.end,$(call word.pack,{str},$1),$(call word.pack,{str},$($2))))



#-------------------------------------------------------------------------------
# Subst: Multiple Match, Single Replace
#-------------------------------------------------------------------------------
# str.subst.list2str        	[str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])
# str.subst.list2var        	[str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])
# str.subst.vars2str        	[str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])
# str.subst.vars2var        	[str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])
# str.strip.list            	[str] <-- $(call str.strip.list,[str:in],[list:strip])
# str.strip.list.start      	[str] <-- $(call str.strip.list.start,[str:in],[list:strip])
# str.strip.list.end        	[str] <-- $(call str.strip.list.end,[str:in],[list:strip])
# str.strip.vars            	[str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])
# str.strip.vars.start      	[str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])
# str.strip.vars.end        	[str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])
#
#-------------------------------------------------------------------------------
#	[word[str]] <-- $(call __str.strip.many.start,[word[str]:in],[list[str]:strip])
#	[word[str]] <-- $(call __str.strip.many.end  ,[word[str]:in],[list[str]:strip])
override __str.strip.many.start = $(subst $s,,$(call list.filter-out.start,$(subst $$e,$s,$(call __str.treesubst.many2many,$1,$2,$(foreach __word,$2,$$e$(__word)$$e))),$2))
override __str.strip.many.end   = $(subst $s,,$(call list.filter-out.end,$(subst $$e,$s,$(call __str.treesubst.many2many,$1,$2,$(foreach __word,$2,$$e$(__word)$$e))),$2))
#-------------------------------------------------------------------------------
override str.subst.list2str     = $(call list.reduce.1,,str.subst.str2str,$1,$2,$3)
override str.subst.list2var     = $(call list.reduce.1,,str.subst.str2var,$1,$2,$3)
override str.subst.vars2str     = $(call list.reduce.1,,str.subst.var2str,$1,$2,$3)
override str.subst.vars2var     = $(call list.reduce.1,,str.subst.var2var,$1,$2,$3)
override str.strip.list         = $(call list.reduce.1,,str.strip.str,$1,$2)
override str.strip.list.start   = $(call word.unpack,{str},$(call __str.strip.many.start,$(call word.pack,{str},$1),$(call word.pack,{word},$2)))
override str.strip.list.end     = $(call word.unpack,{str},$(call __str.strip.many.end,$(call word.pack,{str},$1),$(call word.pack,{word},$2)))
override str.strip.vars         = $(call list.reduce.1,,str.strip.var,$1,$2)
override str.strip.vars.start   = $(call word.unpack,{str},$(call __str.strip.many.start,$(call word.pack,{str},$1),$(foreach __var,$2,$(call word.pack,{str},$($(__var))))))
override str.strip.vars.end     = $(call word.unpack,{str},$(call __str.strip.many.end,$(call word.pack,{str},$1),$(foreach __var,$2,$(call word.pack,{str},$($(__var))))))



#-------------------------------------------------------------------------------
# Subst: Multiple Match, Multiple Replace
#-------------------------------------------------------------------------------
#	str.subst.list2list     	[str] <-- $(call str.subst.list2list,[str:in],[list:find],[list:repl])
#	str.subst.list2vars     	[str] <-- $(call str.subst.list2vars,[str:in],[list:find],[list{var}:repl])
#	str.subst.vars2list     	[str] <-- $(call str.subst.vars2list,[str:in],[list{var}:find],[list:repl])
#	str.subst.vars2vars     	[str] <-- $(call str.subst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
#	str.prefix.list         	[str] <-- $(call str.prefix.list,[str:in],[list:find],[str:prefix])
#	str.prefix.vars         	[str] <-- $(call str.prefix.vars,[str:in],[list{var}:find],[str:prefix])
#	str.suffix.list         	[str] <-- $(call str.suffix.list,[str:in],[list:find],[str:suffix])
#	str.suffix.vars         	[str] <-- $(call str.suffix.vars,[str:in],[list{var}:find],[str:suffix])
#	str.wrap.list           	[str] <-- $(call str.wrap.list,[str:in],[list:find],[str:prefix],[str:suffix])
#	str.wrap.vars           	[str] <-- $(call str.wrap.vars,[str:in],[list{var}:find],[str:prefix],[str:suffix])
#
#-------------------------------------------------------------------------------
override str.subst.list2list = $(call list.reduce.2,,str.subst.str2str,$1,$2,$3)
override str.subst.list2vars = $(call list.reduce.2,,str.subst.str2var,$1,$2,$3)
override str.subst.vars2list = $(call list.reduce.2,,str.subst.var2str,$1,$2,$3)
override str.subst.vars2vars = $(call list.reduce.2,,str.subst.var2var,$1,$2,$3)
override str.prefix.list     = $(call list.reduce.1,,str.prefix.str,$1,$2,$3)
override str.prefix.vars     = $(call list.reduce.1,,str.prefix.var,$1,$2,$3)
override str.suffix.list     = $(call list.reduce.1,,str.suffix.str,$1,$2,$3)
override str.suffix.vars     = $(call list.reduce.1,,str.suffix.var,$1,$2,$3)
override str.wrap.list       = $(call list.reduce.1,,str.wrap.str,$1,$2,$3,$4)
override str.wrap.vars       = $(call list.reduce.1,,str.wrap.var,$1,$2,$3,$4)


#-------------------------------------------------------------------------------
# Subst: Tree Match, Multiple Replace
#-------------------------------------------------------------------------------
# str.treesubst.list2list     	[str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
# str.treesubst.list2vars     	[str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])
# str.treesubst.vars2list     	[str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])
# str.treesubst.vars2vars     	[str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
#
# Similar to `str.subst` but prevents later substitutions from clobbering the values
# of earlier substitutions.
# Empty values of [find] are ignored.
#
# Ex:
#	$(call str.subst.list2list,     i < >, <i> << , <string>) --> '<<str<<i>>ng>>'
#	$(call str.treesubst.list2list, i < >, <i> >> , <string>) --> '<<str<i>ng>>'
#
# Tree Split Algorithm:
#	1. Split [in] on first value of [find].
#	2. For each substring,
#		Recurse on substring with remaining values of [find], [repl].
#	3. Merge substrings using first value of [repl].
#
# This algorithm is significantly more expensive than `str.subst` functions.
# The number of recursive calls scales with *both* $(words [find]) and the
# number of matches.
#-------------------------------------------------------------------------------
#	[word[str]] <-- $(call __str.treesubst.many2one,[word[str]:in],[list[str]:find],[word[str]:repl])
#	[word[str]] <-- $(call __str.treesubst.many2many,[word[str]:in],[list[str]:find],[list[str]:repl])
override __str.treesubst.many2one  = $(if $(and $1,$(firstword $2)),$(subst $s,$3,$(strip $(foreach __word,$(subst $(or $(subst $$e,,$(firstword $2)),$s),$$e$s$$e,$1),$(if $(subst $$e,,$(__word)),$(call $0,$(__word),$(wordlist 2,$(words $2),$2),$3),$(__word))))),$1)
override __str.treesubst.many2many = $(if $(and $1,$(firstword $2)),$(subst $s,$(firstword $3),$(strip $(foreach __word,$(subst $(or $(subst $$e,,$(firstword $2)),$s),$$e$s$$e,$1),$(if $(subst $$e,,$(__word)),$(call $0,$(__word),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3)),$(__word))))),$1)
override str.treesubst.list2list = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(call word.pack,{word},$2),$(call word.pack,{word},$3)))
override str.treesubst.list2vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(call word.pack,{word},$2),$(foreach __var,$3,$(call word.pack,str,$($(__var))))))
override str.treesubst.vars2list = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(foreach __var,$2,$(call word.pack,str,$($(__var)))),$(call word.pack,{word},$3)))
override str.treesubst.vars2vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(foreach __var,$2,$(call word.pack,str,$($(__var)))),$(foreach __var,$3,$(call word.pack,str,$($(__var))))))


#-------------------------------------------------------------------------------
#	str.escape.vars         	[str] <-- $(call str.escape.vars,[str],[list{var}])
#	str.expand.vars         	[str] <-- $(call str.expand.vars,[str],[list{var}])
#
#	Escape: Substitutes the value of each variable with a reference to that variable.
#	        - The value of each single-letter variable 'v' is substituted with '$v';
#	          multi-letter variables 'var' are substituted with '$(var)'.
#	        - If [str] may contain '$', the user is responsible for including 'x' in
#	          the list of variables.
#	        - Substitutions are performed using 'treesubst' so substitutions cannot
#	          overwrite other substitutions.
#	Expand: Restores the original value of each variable reference.
#	        - All possible reference forms are searched; '$v', '$(var)', '${var}'.
#
#-------------------------------------------------------------------------------
override __str.escape.vars.singlechars := $(char.lowers) $(char.uppers) $(char.digits) ` ~ ! @ \# $$ \% ^ & * ( ) - _ + [ ] { } \ | ; ' " , . < > / ?
override str.escape.vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(foreach __var,$2,$(call word.pack,str,$($(__var)))),$(call word.pack,{word},$(foreach __var,$2,$(if $(filter $(__str.escape.vars.singlechars),$(__var)),$$$(__var),$$($(__var)))))))
override str.expand.vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(call word.pack,{word},$(foreach __var,$2,$(if $(filter $(__str.escape.vars.singlechars),$(__var)),$$$(__var)) $$($(__var)) $${$(__var)})),$(foreach __var,$2,$(subst x,$(call word.pack,str,$($(__var))),x x $(if $(filter $(__str.escape.vars.singlechars),$(__var)),x)))))


#-------------------------------------------------------------------------------
# str.to.lower      	[lower] <-- $(call str.to.lower,[str])
# str.to.upper      	[upper] <-- $(call str.to.upper,[str])
#
#	Returns [lower]-case or [upper]-case of [str].
#
#-------------------------------------------------------------------------------
override str.to.lower = $(call str.subst.list2list,$1,$(char.uppers),$(char.lowers))
override str.to.upper = $(call str.subst.list2list,$1,$(char.lowers),$(char.uppers))




#-------------------------------------------------------------------------------
# Path: Components
#-------------------------------------------------------------------------------
# path.abspath          	[path]       <-- $(call path.abspath,[path])
# path.realpath         	[path]       <-- $(call path.realpath,[path])
# path.dir              	[path]       <-- $(call path.dir,[path])
# path.notdir           	[path]       <-- $(call path.notdir,[path])
# path.parent           	[path]       <-- $(call path.parent,[path])
# path.name             	[path]       <-- $(call path.name,[path])
# path.name.base        	[path]       <-- $(call path.name.base,[path])
# path.basename         	[path]       <-- $(call path.basename,[path])
# path.suffix           	[path]       <-- $(call path.suffix,[path])
# list.path.abspath     	[list[path]] <-- $(call list.path.abspath,[list[path]])
# list.path.realpath    	[list[path]] <-- $(call list.path.realpath,[list[path]])
# list.path.dir         	[list[path]] <-- $(call list.path.dir,[list[path]])
# list.path.notdir      	[list[path]] <-- $(call list.path.notdir,[list[path]])
# list.path.parent      	[list[path]] <-- $(call list.path.parent,[list[path]])
# list.path.name        	[list[path]] <-- $(call list.path.name,[list[path]])
# list.path.name.base   	[list[path]] <-- $(call list.path.name.base,[list[path]])
# list.path.basename    	[list[path]] <-- $(call list.path.basename,[list[path]])
# list.path.suffix      	[list[path]] <-- $(call list.path.suffix,[list[path]])
#
#	Returns a path component from the input [path], or from each path in a [list[path]].
#
#	Path Components:
#
#	 path        /path/to/file.ext    /path/to/dir.ext/     /            [empty]
#	 ===========================================================================
#	 dir         /path/to/            /path/to/dir.ext/     /            ./
#	 notdir               file.ext    [empty]               [empty]      [empty]
#	 parent      /path/to             /path/to              [empty]      .
#	 name                 file.ext             dir.ext      [empty]      [empty]
#	 name.base            file                 dir          [empty]      [empty]
#	 basename    /path/to/file        /path/to/dir.ext/     /            [empty]
#	 suffix                   .ext    [empty]               [empty]      [empty]
#
#-------------------------------------------------------------------------------
override __list.path.op = $(call word.unpack,[path],$(call list.$0,$(call word.pack,[path],$1),$2,$3,$4,$5))
override path.abspath   = $(__list.path.op)
override path.realpath  = $(__list.path.op)
override path.dir       = $(__list.path.op)
override path.notdir    = $(__list.path.op)
override path.parent    = $(__list.path.op)
override path.name      = $(__list.path.op)
override path.name.base = $(__list.path.op)
override path.basename  = $(__list.path.op)
override path.suffix    = $(__list.path.op)

override list.path.abspath     = $(foreach __path,$1,$(or $(abspath $(__path)),$(xe)))
override list.path.realpath    = $(foreach __path,$1,$(or $(call word.pack,{path},$(realpath $(call word.unpack,{path},$(__path)))),$(xe)))
override __list.path.mark      = $(foreach __path,$1,$(call word.join.pair,[path],/,$(if $(__path:/%=),,/)<MARK>/..,$(__path)))
override list.path.dir         = $(foreach __path,$1,$(or $(dir $(__path)),$(xe)))
override list.path.notdir      = $(foreach __path,$1,$(or $(notdir $(__path)),$(xe)))
override list.path.parent      = $(foreach __path,$1,$(or $(patsubst %/,%,$(dir $(patsubst %/,%,$(__path)))),$(xe)))
override list.path.name        = $(foreach __path,$1,$(or $(notdir $(patsubst %/,%,$(__path))),$(xe)))
override list.path.name.base   = $(foreach __path,$1,$(or $(basename $(notdir $(patsubst %/,%,$(__path)))),$(xe)))
override list.path.name.suffix = $(foreach __path,$1,$(or $(suffix $(notdir $(patsubst %/,%,$(__path)))),$(xe)))
override list.path.basename    = $(foreach __path,$1,$(or $(basename $(__path)),$(xe)))
override list.path.suffix      = $(foreach __path,$1,$(or $(suffix $(__path)),$(xe)))


#-------------------------------------------------------------------------------
# Path: Prefix/Suffix
#-------------------------------------------------------------------------------
# path.addprefix        	[path]       <-- $(call path.addprefix,[path],[path:prefix])
# path.addsuffix        	[path]       <-- $(call path.addsuffix,[path],[path:suffix])
# list.path.addprefix   	[list[path]] <-- $(call list.path.addprefix,[list[path]],[path:prefix])
# list.path.addsuffix   	[list[path]] <-- $(call list.path.addsuffix,[list[path]],[path:suffix])
#
#	Adds a prefix or suffix to the input [path], or to each path in a [list[path]].
#
#-------------------------------------------------------------------------------
override path.addprefix = $(__list.path.op)
override path.addsuffix = $(__list.path.op)
override list.path.addprefix = $(addprefix $(call word.pack,[path],$2),$1)
override list.path.addsuffix = $(addsuffix $(call word.pack,[path],$2),$1)


#-------------------------------------------------------------------------------
# Path: Substitutions
#-------------------------------------------------------------------------------
# path.subst                    	[path]       <-- $(call path.subst,[path:in],[path:find],[path:repl])
# path.patsubst                 	[path]       <-- $(call path.patsubst,[path:in],[path.pattern:find],[path.pattern:repl])
# path.patsubst.dir             	[path]       <-- $(call path.patsubst.dir,[path:in],[path.pattern:dir],[path.pattern:repl])
# path.patsubst.notdir          	[path]       <-- $(call path.patsubst.notdir,[path:in],[path.pattern:notdir],[path.pattern:repl])
# path.patsubst.parent          	[path]       <-- $(call path.patsubst.parent,[path:in],[path.pattern:parent],[path.pattern:repl])
# path.patsubst.name            	[path]       <-- $(call path.patsubst.name,[path:in],[path.pattern:name],[path.pattern:repl])
# path.patsubst.name.base       	[path]       <-- $(call path.patsubst.name.base,[path:in],[path.pattern:name.base],[path.pattern:repl])
# path.patsubst.basename        	[path]       <-- $(call path.patsubst.basename,[path:in],[path.pattern:basename],[path.pattern:repl])
# path.patsubst.suffix          	[path]       <-- $(call path.patsubst.suffix,[path:in],[path.pattern:suffix],[path.pattern:repl])
# list.path.subst               	[list[path]] <-- $(call list.path.subst,[list[path]:in],[path:find],[path:repl])
# list.path.patsubst            	[list[path]] <-- $(call list.path.patsubst,[list[path]:in],[path.pattern:find],[path.pattern:repl])
# list.path.patsubst.dir        	[list[path]] <-- $(call list.path.patsubst.dir,[list[path]:in],[path.pattern:dir],[path.pattern:repl])
# list.path.patsubst.notdir     	[list[path]] <-- $(call list.path.patsubst.notdir,[list[path]:in],[path.pattern:notdir],[path.pattern:repl])
# list.path.patsubst.parent     	[list[path]] <-- $(call list.path.patsubst.parent,[list[path]:in],[path.pattern:parent],[path.pattern:repl])
# list.path.patsubst.name       	[list[path]] <-- $(call list.path.patsubst.name,[list[path]:in],[path.pattern:name],[path.pattern:repl])
# list.path.patsubst.name.base  	[list[path]] <-- $(call list.path.patsubst.name.base,[list[path]:in],[path.pattern:name.base],[path.pattern:repl])
# list.path.patsubst.name.suffix	[list[path]] <-- $(call list.path.patsubst.name.suffix,[list[path]:in],[path.pattern:name.suffix],[path.pattern:repl])
# list.path.patsubst.basename   	[list[path]] <-- $(call list.path.patsubst.basename,[list[path]:in],[path.pattern:basename],[path.pattern:repl])
# list.path.patsubst.suffix     	[list[path]] <-- $(call list.path.patsubst.suffix,[list[path]:in],[path.pattern:suffix],[path.pattern:repl])
#
#	Performs a find/replace operation on the input [path],
#	or within each [path] in the input [list[path]].
#
#	subst:           Match/Replace every occurrance of [find] in [in].
#	patsubst:        Pattern-matches against whole path [in].
#	patsubst.{PART}: Pattern-matches within only the specific {PART} of [in];
#	                 the rest of [in] is returned unmodified.
#
#	Path Components:
#
#	 path        /path/to/file.ext    /path/to/dir.ext/     /            [empty]
#	 ===========================================================================
#	 dir         /path/to/            /path/to/dir.ext/     /            ./
#	 notdir               file.ext    [empty]               [empty]      [empty]
#	 parent      /path/to             /path/to              [empty]      .
#	 name                 file.ext             dir.ext      [empty]      [empty]
#	 name.base            file                 dir          [empty]      [empty]
#	 basename    /path/to/file        /path/to/dir.ext/     /            [empty]
#	 suffix                   .ext    [empty]               [empty]      [empty]
#
#-------------------------------------------------------------------------------
override path.subst                     = $(__list.path.op)
override path.patsubst                  = $(__list.path.op)
override path.patsubst.dir              = $(__list.path.op)
override path.patsubst.notdir           = $(__list.path.op)
override path.patsubst.parent           = $(__list.path.op)
override path.patsubst.name             = $(__list.path.op)
override path.patsubst.name.base        = $(__list.path.op)
override path.patsubst.basename         = $(__list.path.op)
override path.patsubst.suffix           = $(__list.path.op)
override list.path.subst                = $(subst $(call word.pack,[path],$2),$(call word.pack,[path],$3),$(call list.repack,[path],$1))
override list.path.patsubst             = $(patsubst $(call word.pack,[path.pattern],$2),$(call word.pack,[path.pattern],$3),$(call list.repack,[path],$1))
override list.path.patsubst.dir         = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(patsubst $(__find),$(__repl),$(call list.path.dir,$(__in))),$(call list.path.notdir,$(__in))))))
override list.path.patsubst.notdir      = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.dir,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.notdir,$(__in)))))))
override list.path.patsubst.parent      = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(patsubst $(__find),$(__repl),$(call list.path.parent,$(__in))),$(call list.path.name,$(__in))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name        = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.name,$(__in)))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name.base   = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.name.base,$(__in)))$(call list.path.name.suffix,$(__in))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name.suffix = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(call list.path.name.base,$(__in))$(patsubst $(__find),$(__repl),$(call list.path.name.suffix,$(__in)))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.basename    = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],,$(patsubst $(__find),$(__repl),$(call list.path.basename,$(__in))),$(call list.path.suffix,$(__in))))))
override list.path.patsubst.suffix      = $(foreach __find,$(call word.pack,[path.pattern],$2),$(foreach __repl,$(call word.pack,[path.pattern],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],,$(call list.path.basename,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.suffix,$(__in)))))))


#-------------------------------------------------------------------------------
# Path: Search
#-------------------------------------------------------------------------------
# path.wildcard     	[list[path]] <-- $(call path.wildcard,[path.pattern:find])
# list.path.wildcard	[list[path]] <-- $(call list.path.wildcard,[list[path.pattern]:find])
#
#	Returns a list of word-packed paths which match the wildcard pattern(s).
#	- Unlike built-in $(wildcard), these functions fully support spaces in both
#	  the input and output paths.
#	- Matches only directories if [find] ends with '/' AND contains a wildcard;
#	  otherwise both files and directories are returned.
#	Returns [empty] if there are no paths matching [find].
#
#	Notes on type [path.pattern]:
#	- May contain any valid filename characters, plus zero or more wildcards:
#	 '*'     matches zero or more characters within a file/directory name
#	 '?'     matches exactly 1 character within a file/directory name
#	 '[...]' matches 1 character from the list
#	- Spaces ' ' are automatically escaped with '\ '.
#	- Special characters '%', '\', '[', ']', '?', '*' must be escaped manually.
#	- Non-escape '\' are replaced with '/'.
#	- Redundant '/' are removed.
#
#-------------------------------------------------------------------------------
override path.wildcard      = $(call list.path.wildcard,$(call word.pack,[path.pattern],$1))
override list.path.wildcard = $(if $1,$(call str.split,{path},$(subst <MARK>/..,,$(subst <MARK>/../,,$(subst /<MARK>/..,,$(subst $s<MARK>/../,<SPLIT>,$(subst $s/<MARK>/..,<SPLIT>,$(wildcard $(foreach __path,$(call __list.path.mark,$1),$(call word.unpack,[path.pattern],$(__path))))))))),<SPLIT>))


#-------------------------------------------------------------------------------
# Path: Test Existence
#-------------------------------------------------------------------------------
# path.exists           	[path]       <-- $(call path.exists,[path])
# file.exists           	[path]       <-- $(call dir.exists,[path])
# dir.exists            	[path]       <-- $(call file.exists,[path])
# list.path.exists      	[list[path]] <-- $(call list.path.exists,[list[path]])
# list.file.exists      	[list[path]] <-- $(call list.dir.exists,[list[path]])
# list.dir.exists       	[list[path]] <-- $(call list.file.exists,[list[path]])
#
#	Returns [path] if it exists (and is a file/directory/either).
#	Functions which accept [list[path]] set each nonexistant path to packed-[empty].
#
#-------------------------------------------------------------------------------
#	[word[path]] <-- $(call __list.filter.*,[word[path]],[list[path]])
override __list.filter.path = $(if $(filter $1,$2),$1,$(xe))
override __list.filter.dir  = $(if $(filter $(1:%/=%)/,$2),$1,$(xe))
override __list.filter.file = $(if $(and $(if $(filter $(1:%/=%)/,$2),,T),$(filter $1,$2)),$1,$(xe))

override path.exists = $(__list.path.op)
override dir.exists  = $(__list.path.op)
override file.exists = $(__list.path.op)
override list.path.exists = $(call list.map.1,,__list.filter.path,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $(xe),$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))
override list.dir.exists  = $(call list.map.1,,__list.filter.dir,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $(xe),$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))
override list.file.exists = $(call list.map.1,,__list.filter.file,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $(xe),$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))


#-------------------------------------------------------------------------------
# paths.format       	[paths] <-- $(call paths.format,$n\
#                   	                  /path/to a/file.1	$n\
#                   	                  path/to a/dir/	$n\
#                   	            )
#
#	Convenience method for manual [paths] definition.
#	Splits the second argument on {tab} and {lf}, encoding each section as a word-packed [path],
#	then merges the resulting list into a [paths] string.
#	- Each line must end with '$n\'.
#	- Leading whitespace is removed. Trailing {space} is kept. Trailing {tab} and {lf} are removed.
#-------------------------------------------------------------------------------
override paths.format = $(call word.unpack,{path.pattern},$(call list.format,{path.pattern},$1))




#===============================================================================
# NUMERICS
#===============================================================================
# Numeric Types
# [int] can be any integer; positive, negative, or 0, or the empty string.
# [uint] can be any positive integer, 0, or the empty string.
#
#-------------------------------------------------------------------------------
# Trim:
#  Removes whitespace and '+' characters from a numeric value.
#
#  [int]  <-- $(call int.trim,[int])
#  [uint] <-- $(call uint.trim,[uint])
#  [idx]  <-- $(call idx.trim,[idx])
#
#-----------------------------------------------------------
# Integer Math
#  [int]  <-- $(call int.inc,[int])        Increments [int] by 1. Returns empty if [int] is empty.
#  [int]  <-- $(call int.dec,[int])        Decrements [int] by 1. Returns empty if [int] is empty.
#  [int]  <-- $(call int.abs,[int])        Returns absolute value of [int], or empty if [int] is empty.
#  [int]  <-- $(call int.neg,[int])        Returns negation of [int], or empty if [int] is empty.
#
#-----------------------------------------------------------
# Comparison (can be replaced with $(intcmp) on Make 4.4+)
#  {bool} <-- $(call int.equ,[int],[int])  Returns true (nonempty) if the arguments are equal; false (empty) if notequal or if either argument is empty.
#  {bool} <-- $(call int.neq,[int],[int])  Returns true (nonempty) if the arguments are not equal; false (empty) if equal or if either argument is empty.
#  {bool} <-- $(call int.equ.0,[int])      Returns true (nonempty) if [int] == 0; false (empty) if [int] != 0 or if [int] is empty.
#  {bool} <-- $(call int.neq.0,[int])      Returns true (nonempty) if [int] != 0.
#  {bool} <-- $(call int.gtr.0,[int])      Returns true (nonempty) if [int] >  0.
#  {bool} <-- $(call int.geq.0,[int])      Returns true (nonempty) if [int] >= 0.
#  {bool} <-- $(call int.leq.0,[int])      Returns true (nonempty) if [int] <= 0.
#  {bool} <-- $(call int.lss.0,[int])      Returns true (nonempty) if [int] <  0.
#
#-------------------------------------------------------------------------------

# Integer Math
override int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))
override int.dec = $(if $(filter 0 -%,$1),-)$(subst .,,$(call int.$(if $(filter 0 -%,$1),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))

override int.inc.recurse = $(if $(basename $1),$(if $(1:%9=),$(basename $1)$(call digit.inc,$(suffix $1),.),$(if $1,$(call int.inc.recurse,$(basename $1)).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $1),.),$(if $1,.1.0)))
override int.dec.recurse = $(if $(basename $1),$(if $(1:%0=),$(basename $1)$(call digit.dec,$(suffix $1),.),$(if $1,$(filter-out .0,$(call int.dec.recurse,$(basename $1))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $1),.)))

# [str] <-- $(call str.digits.addprefix,[prefix],[str])
override str.digits.addprefix = $(subst 9,$19,$(subst 8,$18,$(subst 7,$17,$(subst 6,$16,$(subst 5,$15,$(subst 4,$14,$(subst 3,$13,$(subst 2,$12,$(subst 1,$11,$(subst 0,$10,$2))))))))))

# {digit} <-- $(call digit.inc,[digit],[prefix])     Over/underflow wraps to 0/9. empty is treated as digit=0.
# {digit} <-- $(call digit.dec,[digit],[prefix])
override digit.inc  = $(addprefix $2,$(word 1$(1:$2%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
override digit.dec  = $(addprefix $2,$(word 1$(1:$2%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))

override int.abs = $(1:-%=%)
override int.neg = $(if $(1:-%=),$(if $(1:0=),-$1,$1),$(1:-%=%))

# Comparison
override int.equ    = $(filter $2,$1)
override int.neq    = $(filter-out $2,$1)
override int.equ.0  = $(filter 0,$1)
#int.equ.0 = $(if $(1:0=),,true)
override int.neq.0  = $(1:0=)
override int.gtr.0  = $(filter-out 0 -%,$1)
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
override int.geq.0  = $(1:-%=)
override int.leq.0  = $(filter 0 -%,$1)
override int.lss.0  = $(filter -%,$1)
#int.lss.0 = $(if $(1:-%=),,true)


# Trim
override int.trim   = $(strip $(subst +,,$1))
override uint.trim  = $(strip $(subst +,,$1))
override idx.trim   = $(strip $(subst +,,$1))
#===============================================================================






#===============================================================================
# ITERATORS
#===============================================================================
#
# {empty} <-- $(call iter.inc.define,{var:name},[int:start],[int:end])
#
# Returns empty. As a side effect, defines the following variables:
#
#    [int:current] <-- $({name})            Returns current value of the iterator.
#                                             Initially at [start], or '0' if [start] is empty.
#                                             Returns empty if iterator has exceeded [end].
#
#    [int:next]    <-- $({name}.next)       Increments iterator and returns the incremented value.
#                                             Returns empty if iterator == [end], or if iterator is empty.
#-------------------------------------------------------------------------------

# {name} := [start,0]
# {name}.next = $(eval {name} := $(if $(filter-out [end],$({name})),$(call int.inc,$({name}))))$({name})
override iter.inc.define = $(eval $1 := $(or $2,0))$(eval $1.next = $$(eval $1 := $$(if $$(filter-out $3,$$($1)),$$(call int.inc,$$($1))))$$($1))
#===============================================================================






#===============================================================================
# EXPRESSIONS, DYNAMIC PROGRAMMING
#===============================================================================

#-----------------------------------------------------------
# [expr[T]] <-- $(call expr.const,[type:T],[T:val])
# [expr]    <-- $(call expr.ref,[expr[var]:name],[expr[word.pattern]:find],[expr[str.pattern]:repl])
# [expr]    <-- $(call expr.builtin,[expr[builtin]:name],[list[expr]:args])
# [expr]    <-- $(call expr.call,[expr[func]:name],[list[expr]:args])
# [expr]    <-- $(call expr.assign,[list[expr]:directives],[expr[var]:name],[expr:assign_operator],[expr:value])
# [expr]    <-- $(call expr.target,[expr[paths]:targets],\
#                   [expr[paths]:prereqs],[expr[paths]:orderonly],\
#                   [expr[paths]:prereqs_of],[expr[paths]:orderonly_of],\
#                   [list[expr]:assignments],\
#                   [list[expr]:commands]
#               )
# [expr]    <-- $(call expr.target,$(call paths.format,$n\
#                       /target/paths$n\
#                   ),$(call paths.format,$n\
#                       /prereq/paths$n\
#                   ),$(call paths.format,$n\
#                       /orderonly/paths$n\
#                   ),$(call paths.format,$n\
#                       /prereqs/of$n\
#                   ),$(call paths.format,$n\
#                       /orderonly/of$n\
#                   ),$(call list.format,expr,$n\
#                       localvar := value$n\
#                   ),$(call list.format,expr,$n\
#                       commands$n\
#                   )\
#               )
#-----------------------------------------------------------
override expr.const   = $(call str.subst.vars2vars,$(call word.pack,$1,$2),c l r j k,xc xl xr xj xk)
override expr.ref     = $(if $1,$(if $2$3,$$($1:$2=$3),$(if $(call var.is.shortname,$1),$$$1,$$($1))))
override expr.builtin = $(if $1,$$($1 $(call list.merge,expr,$2,$c)))
override expr.call    = $(if $1,$(call expr.builtin,call,$(call word.pack,expr,$1) $2))
override expr.assign  = $(if $2,$(call str.concat.pair,$n,$(call str.concat,$s,$(filter-out define,$1),$(if $(findstring $n,$4),define),$2,$(or $3,=),$(findstring $n,$4)$4),$(if $(findstring $n,$4),endef)))
override expr.target  = $(if $1,$n$(call __$0,$1,$2,$3,$4,$5,$(call list.prune,expr,$6),$(call list.prune,expr,$7)))
override define __expr.target
$(if $4,$4: $1)
$(if $5,$5: | $1)
$(if $6,$(call list.merge,expr,$(addprefix $(call word.pack,expr,$1:$s),$6),$n))
$1:$(if $2, $2)$(if $3, | $3)
$(if $7,$(or $(.RECIPEPREFIX),$t)$(call list.merge,expr,$7,$n$(or $(.RECIPEPREFIX),$t)))
$n
endef





#-----------------------------------------------------------
# [expr[str]([str:in])] <-- $(call expr.subst.expr2expr,[expr[str]([str:in])],[expr[str]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2expr,[expr[str]([str:in])],[list[expr[str]]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2exprs,[expr[str]([str:in])],[list[expr[str]]:from],[list[expr[str]]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.const2const,[expr[str]([str:in])],[str:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.const2ref,[expr[str]([str:in])],[str:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.ref2const,[expr[str]([str:in])],[var:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.ref2ref,[expr[str]([str:in])],[var:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.consts2const,[expr[str]([str:in])],[list:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.consts2ref,[expr[str]([str:in])],[list:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.refs2const,[expr[str]([str:in])],[list[var]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.refs2ref,[expr[str]([str:in])],[list[var]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.consts2consts,[expr[str]([str:in])],[list:from],[list:to])
# [expr[str]([str:in])] <-- $(call expr.subst.consts2refs,[expr[str]([str:in])],[list:from],[list[var]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.refs2consts,[expr[str]([str:in])],[list[var]:from],[list:to])
# [expr[str]([str:in])] <-- $(call expr.subst.refs2refs,[expr[str]([str:in])],[list[var]:from],[list[var]:to])
#-----------------------------------------------------------
#
# Generates an `eval`-uatable expression which performs one or more `subst`-itutions in series.
# 'expr[str]' is an expression which expands to a [str]. It may contain any combination of the following:
#             - Variable References: '$v', '$(var)', '${var}', '$(var:[word.pattern:find]=[str.pattern:repl])', etc.
#               Use `expr.ref` to generate a variable reference.
#             - Function Calls:      '$({builtin} [arg:1],...)', '$(call {func},[arg:1],...)'
#               Use `expr.call` to generate a function call.
#             - Literal Strings: Constants embedded in an expression. Must abide by the following rules
#               to ensure correct parsing:
#               - Literals may not contain whitespace; use variable references '$s', '$t', '$n' instead.
#               - Literals may not contain unpaired '{', '}', '(', ')'; use '$j', '$k', '$l', '$r' instead.
#               - Literals may not ','; use '$c' instead.
#               Use `expr.const` to generate an embeddable literal from an arbitrary string.
#-----------------------------------------------------------
override expr.subst.expr2expr     = $(if $(and $1,$2),$(if $(call expr.is.empty,$2),$$(or $1$c$3),$$(subst $2$c$3$c$1)),$1)
override expr.subst.exprs2expr    = $(if $(and $1,$(firstword $2)),$(call expr.subst.expr2expr,$(call $0,$1,$(wordlist 2,$(words $2),x $2),$3),$(call word.unpack,expr,$(lastword $2)),$3),$1)
override expr.subst.exprs2exprs   = $(if $(and $1,$(firstword $2),$(firstword $3)),$(call expr.subst.expr2expr,$(call $0,$1,$(wordlist 2,$(words $2),x $2),$(wordlist 2,$(words $3),x $3)),$(call word.unpack,expr,$(lastword $2)),$(call word.unpack,expr,$(lastword $3))),$1)
override expr.subst.const2const   = $(call expr.subst.expr2expr,$1,$(call expr.const,str,$2),$(call expr.const,str,$3))
override expr.subst.const2ref     = $(call expr.subst.expr2expr,$1,$(call expr.const,str,$2),$(call expr.ref,$3))
override expr.subst.ref2const     = $(call expr.subst.expr2expr,$1,$(call expr.ref,$2),$(call expr.const,str,$3))
override expr.subst.ref2ref       = $(call expr.subst.expr2expr,$1,$(call expr.ref,$2),$(call expr.ref,$3))
override expr.subst.consts2const  = $(call expr.subst.exprs2expr,$1,$(foreach __wrd,$2,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))),$(call expr.const,str,$3))
override expr.subst.consts2ref    = $(call expr.subst.exprs2expr,$1,$(foreach __wrd,$2,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))),$(call expr.ref,$3))
override expr.subst.refs2const    = $(call expr.subst.exprs2expr,$1,$(foreach __var,$2,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))),$(call expr.const,str,$3))
override expr.subst.refs2ref      = $(call expr.subst.exprs2expr,$1,$(foreach __var,$2,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))),$(call expr.ref,$3))
override expr.subst.consts2consts = $(call expr.subst.exprs2exprs,$1,$(foreach __wrd,$2,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))),$(foreach __wrd,$3,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))))
override expr.subst.consts2refs   = $(call expr.subst.exprs2exprs,$1,$(foreach __wrd,$2,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))),$(foreach __var,$3,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))))
override expr.subst.refs2consts   = $(call expr.subst.exprs2exprs,$1,$(foreach __var,$2,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))),$(foreach __wrd,$3,$(call word.pack,expr,$(call expr.const,word,$(__wrd)))))
override expr.subst.refs2refs     = $(call expr.subst.exprs2exprs,$1,$(foreach __var,$2,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))),$(foreach __var,$3,$(call word.pack,expr,$(call expr.ref,$(call word.unpack,var,$(__var))))))

#-----------------------------------------------------------
# [expr[str]] <-- $(call expr.strip.consts,[expr[str]:in],[list[str]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.strip.vars,[expr[str]:in],[list[var]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.cull.consts,[expr[str]:in],[list[str]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.cull.vars,[expr[str]:in],[list[var]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.strip.ws,[expr[str]:in],[list[var]:ws])
#-----------------------------------------------------------
# [expr]       <-- $(call __expr.is.empty,[expr])
# [expr[word]] <-- $(call __expr.strip.pre,[expr[str]:in],[list[var]:noescape])
# [expr[str]]  <-- $(call __expr.strip.post,[expr[word]:in],[list[var]:noescape])
# [expr[word]] <-- $(call __expr.strip.expr,[expr[word]:in],[expr[word]:strip])
# [expr[word]] <-- $(call __expr.strip.const,[expr[word]:in],[str:strip],[list[var]:noescape])
override __expr.is.empty    = $(filter $(xe) $$e $$(e) $${e} $$(empty) $${empty},$1)
override __expr.strip.pre   = $(call expr.subst.refs2refs,$1,$(filter-out $(subst %,\%,$2),x s t n),$(addprefix x,$(filter-out $(subst %,\%,$2),x s t n)))
override __expr.strip.post  = $(call expr.subst.refs2refs,$1,$(addprefix x,$(filter-out $(subst %,\%,$2),n t s x)),$(filter-out $(subst %,\%,$2),n t s x))
override __expr.strip.expr  = $(if $(and $1,$2),$(if $(call __expr.is.empty,$2),$1,$$(subst$s$(xs)$c$2$c$$(strip$s$$(subst$s$2$c$(xs)$c$1)))),$1)
override __expr.strip.const = $(call __expr.strip.expr,$1,$(call expr.const,word,$(call str.subst.vars2vars,$2,$(filter-out $(subst %,\%,$3),x s t n),$(addprefix x,$(filter-out $(subst %,\%,$3),x s t n)))))

override expr.strip.consts  = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$(call list.reduce.1,str,__expr.strip.const,$(call __expr.strip.pre,$1,$3),$2,$3),$3),$1)
override expr.strip.vars    = $(call expr.strip.consts,$1,$(foreach var,$2,$(call word.pack,str,$($(var)))),$3)
override expr.cull.consts   = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$$(subst $$(xe)$c$c$(call list.reduce.1,str,__expr.strip.const,$$(xe)$(call __expr.strip.pre,$1,$3)$$(xe),$2,$3)),$3),$1)
override expr.cull.vars     = $(call expr.cull.consts,$1,$(foreach var,$2,$(call word.pack,str,$($(var)))),$3)
override expr.strip.ws      = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$$(strip $(call __expr.strip.pre,$1,$2)),$2),$1)





#-----------------------------------------------------------
# $(call variable.set_with_alternatives,{variable},{assignment_operator},[initial_value],[list of alternatives],[value_if_still_empty])
#-----------------------------------------------------------
# Sets a variable to the value of the first variable in the list.
#   If still empty, sets equal to the second variable in the list.
#   If no non-empty alternatives, expands and sets to [value_if_still_empty].
#
# {variable}               Name of variable to assign
# {assignment_operator}    Typically ?= , := , or = .
#                            If using ?=, a variable which is defined but empty will remain empty.
# [list of alternatives]   Space-separated list of variable names
# [value_if_still_empty]   Expanded as the final alternative.
#                            Can contain makefile syntax for use with 'eval'.
#                            To exit make if variable is still empty, use:
#                                $$(error ...)
#-----------------------------------------------------------

override variable.set_with_alternatives = $(eval $(strip $1) $(strip $2) $(if $(or $3,$(strip $4),$5),$$(or $(if $3,$3$c)$(subst $s,$c,$(foreach var,$(strip $4),$$($(var))))$(if $5,$c$5))))


#-------------------------------------------------------------------------------
# $(this.filepath)
# $(this.filename)
# $(this.dirpath)
# $(this.dirname)
#-------------------------------------------------------------------------------
# Returns parts of the path to this makefile.
# Must be expanded BEFORE any "include..." statements!
# Use Simple (immediate) Expansion ':=' early in the file to ensure correct results.
# Ex:
#    filename := $(this.filename)
#-------------------------------------------------------------------------------
override this.filepath = $(abspath $(lastword $(MAKEFILE_LIST)))
override this.filename = $(notdir $(lastword $(MAKEFILE_LIST)))
override this.dirpath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
override this.dirname = $(notdir $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))





#===============================================================================
# STRING PADDING
#===============================================================================
# A [pad] is a string of zero or more '.' characters representing the
# "column width" of a string.
# - For strings without tabs or linefeeds, a [pad] is equal in length to the string.
# - Tabs are replaced with $(pad.tab) during the pad conversion.
# - Linefeeds are treated as separators; each [line] is padded individually, and
#   the resulting [pad] is equal in length to the longest [line].
#
# Example:
#   pad := ..............................
#   line := Some Text
#   $(info [$(pad)])                                    -->  [..............................]
#   $(info [$(str)])                                    -->  [Some Text]
#   $(info [$(call line.justify.r,$(line),$(pad))]) -->  [Some Text                     ]
#   $(info [$(call line.justify.l,$(line),$(pad))])  -->  [                     Some Text]
#
#-------------------------------------------------------------------------------
#
# Pad Differences:
#  [pad]  <-- $(call pad.diff,[pad],[pad])          Returns a [pad] equal to the difference in lengths of the two arguments.
#
# Right/Left Justification:
#  [str]  <-- $(call str.justify.r,[str],[pad],[char])      Right-pads each line of [str] with [char]s up to the length of [pad].
#  [str]  <-- $(call str.justify.l,[str],[pad],[char])       Left-pads each line of [str]. Similar to a right-justify.
#                                                             [pad] defaults to a pad the length of the longest line in [str].
#                                                             [char] defaults to $s.
#
#  [line] <-- $(call line.justify.r,[line],[pad],[char])    Same as str.pad, but optimized for various other types.
#  [line] <-- $(call line.justify.l,[line],[pad],[char])
#  [line] <-- $(call word.justify.r,[word],[pad],[char])
#  [line] <-- $(call word.justify.l,[word],[pad],[char])
#  [line] <-- $(call int.justify.r,[int],[pad],[char])
#  [line] <-- $(call int.justify.l,[int],[pad],[char])
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# str.to.pad
#
#	[pad] <-- $(call str.to.list[pad],[str:lines])              For singular multiline types: Returns a [pad] equal to the length of the longest line in [str].
#	[pad] <-- $(call {T}.to.pad,[T:val])                  For all other singular types: Returns a [pad] equal to the length of [val].
#	[pad] <-- $(call list.to.list[pad],[list:vals])             For normal lists:             Returns a [pad] equal to the length of the longest [word] in [list].
#	[pad] <-- $(call list[{T}].to.pad,[list[T]:vals])     For packed-word lists:        Returns a [pad] equal to the length of the longest {T} value in [list[T]].
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# pad.to.str
#
#	[str] <-- $(call pad.to.str,[pad],[char])
#
#	Returns a sequence of [char] equal in length to [pad].
#	Uses space ' ' if [char] is omitted.
#-------------------------------------------------------------------------------
override pad.to.str = $(subst .,$(or $2,$s),$(strip $1))



# String Padding ====================== type: [pad]
override pad.line.indent    = $(call line.to.pad,$(line.indent))
override pad.tab            = $(pad.line.indent)
override pad.info.prefix    = $(call line.to.pad,$(info.prefix))
override pad.warning.prefix = $(call line.to.pad,$(warning.prefix))
override pad.error.prefix   = $(call line.to.pad,$(error.prefix))


# Pad Differences ===================== type: [pad]
override pad.diff           = $(filter-out $1,$(1:$2%=%))

# Left/Right Justification ============ type: [str]
override T.justify.r    = $(call pad.to.str,$(call pad.diff,$3,$(call $1.to.pad,$2)),$4)$2
override T.justify.l    = $2$(call pad.to.str,$(call pad.diff,$3,$(call $1.to.pad,$2)),$4)

override str.justify.r  = $(call pad.to.str,$(call pad.diff,$(or $2,$(call str.to.list[pad],$1)),$(call line.to.pad,$(subst $t,$(pad.tab),$1))),$3)
#override str.justify.l  =
override line.justify.r = $(call T.justify.r,line,$1,$2,$3)
override line.justify.l = $(call T.justify.l,line,$1,$2,$3)
override word.justify.r = $(call T.justify.r,word,$(strip $1),$2,$3)
override word.justify.l = $(call T.justify.l,word,$(strip $1),$2,$3)
override int.justify.r  = $(call T.justify.r,int,$(strip $1),$2,$3)
override int.justify.l  = $(call T.justify.l,int,$(strip $1),$2,$3)
override uint.justify.r = $(call T.justify.r,uint,$(strip $1),$2,$3)
override uint.justify.l = $(call T.justify.l,uint,$(strip $1),$2,$3)
override idx.justify.r  = $(call T.justify.r,idx,$(strip $1),$2,$3)
override idx.justify.l  = $(call T.justify.l,idx,$(strip $1),$2,$3)
#===============================================================================


#===============================================================================
# PRINTING
#===============================================================================
# Info
# $(call print.info,{msg},[indent])
# $(call print.vars,{vars},[indent],[col])
# $(call print.list,[list],[indent],[col])
# $(call print.debug,{msg},[indent])
# $(call print.trace,{msg},[indent])
# Warnings
#-------------------------------------------------------------------------------


override print.var =
# $(call print.var,{var},{indent},{col},{prefix},{suffix})
override print.var = $(info $2$(call str.justify.l,$1,$3)=$4$(subst $n,$5$n$2$(subst .,$s,$3.)$4,$($1))$5)




override print.vars = $(if $2,$(if $3,$(foreach var,$1,$(call print.var,$(var),$2,$3,[,])),$(call print.vars,$1,$2,$(call print.vars.col,$1))),$(call print.vars,$1,$(line.indent),$3))

# $(call print.vars.col,{vars})
override print.vars.col = $(lastword $(sort $(call str.subst.list2str,$1,$(var.char.list),.)))

override print.break = $(info )$(call print.vars,$1)$(info )$(error Breakpoint reached. Exiting...)

override print.debug.enable ?= false
override print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $1)))

override print.trace.enable ?= false
override print.trace = $(if $(findstring $(print.trace.enable),true),$(info $n======= $(if $(strip $1),$(strip $1),make $@) =======))

# [str]   <-- $(call str.lines.wrap,[str],[str:prefix],[str:suffix])
override str.lines.wrap = $2$(subst $n,$3$n$2,$1)$3

# [str]   <-- $(call str.info.var,[var],[col])
override str.info.var = $(if $(strip $1),$(call str.justify.l,$1,$2)=$4$(subst $n,$5$n$(subst .,$s,$2.)$4,$($1))$5)





#===============================================================================
# ERROR HANDLING
#===============================================================================
# [str] <-- $(error.prefix)          Error message line prefix
# [str] <-- $(line.indent)          Error message line indentation
#
# Error Message Strings:
#  [str] <-- $(call str.error.dynamic,[str:dynamic],[str:details])
#  [str] <-- $(call str.error.expansion,[str:expr],[str:details])
#  [str] <-- $(call str.error.call,[func],[str:details])
#  [str] <-- $(call str.error.arg,[func],[idx:argnum],[word:argspec],[str:argval],[str:details])
#  [str] <-- $(call str.error.arg.empty,[func],[idx:argnum],[word:argspec])
#  [str] <-- $(call str.error.arg.nowords,[func],[idx:argnum],[word:argspec])
#  [str] <-- $(call str.error.arg.multiline,[func],[idx:argnum],[word:argspec])
#
# Assert:
#  [empty] <-- $(assert.{N}.is.nonempty)    Throws $(error) if function argument $({N}) is [empty].
#  [empty] <-- $(assert.{N}.has.words)      Throws $(error) if function argument $({N}) has 0 words.
#  [empty] <-- $(assert.{N}.is.line)        Throws $(error) if function argument $({N}) contains linefeeds.
#  [empty] <-- $(assert.{N}.is.word)        Throws $(error) if function argument $({N}) does not have exactly 1 word.
#
#-------------------------------------------------------------------------------
# str.error =========================== type: [str]
override str.error.dynamic         = Error $(if $1,at $1,{unspecified})$(if $2,:$(subst $n,$n$(error.prefix)$(line.indent),$n$2))$n
override str.error.expansion       = $(call str.error.dynamic,$$($(or $(strip $1),...)),$2)
override str.error.call            = $(call str.error.expansion,call$(if $(strip $1),$s$(strip $1)),$2)
override str.error.arg             = $(call str.error.call,$1,Invalid argument $(if $(strip $2),$(strip $2):$s)$(if $(strip $3),$(strip $3)$s$(if $4,=$s))$(if $4,"$4")$(if $5,$(subst $n,$n$(str.error.INDENT),$n$5)))
override str.error.arg.empty       = $(call str.error.arg,$1,$2,$3,,Must be nonempty.)
override str.error.arg.nowords     = $(call str.error.arg,$1,$2,$3,,Must contain at least one word.)
override str.error.arg.multiline   = $(call str.error.arg,$1,$2,$3,,Must not contain multiple lines.)
override str.error.arg.multiword   = $(call str.error.arg,$1,$2,$3,,Must contain exactly 1 word.)

# assert ============================== type: [empty]
override assert.1.is.nonempty      = $(if $1,,$(error $(call str.error.arg.empty,$0,1)))
override assert.2.is.nonempty      = $(if $2,,$(error $(call str.error.arg.empty,$0,2)))
override assert.3.is.nonempty      = $(if $3,,$(error $(call str.error.arg.empty,$0,3)))
override assert.4.is.nonempty      = $(if $4,,$(error $(call str.error.arg.empty,$0,4)))

override assert.1.has.words        = $(if $(strip $1),,$(error $(call str.error.arg.nowords,$0,1)))
override assert.2.has.words        = $(if $(strip $2),,$(error $(call str.error.arg.nowords,$0,2)))
override assert.3.has.words        = $(if $(strip $3),,$(error $(call str.error.arg.nowords,$0,3)))
override assert.4.has.words        = $(if $(strip $4),,$(error $(call str.error.arg.nowords,$0,4)))

override assert.1.is.line          = $(if $(findstring $n,$1),$(error $(call str.error.arg.multiline,$0,1)))
override assert.2.is.line          = $(if $(findstring $n,$2),$(error $(call str.error.arg.multiline,$0,2)))
override assert.3.is.line          = $(if $(findstring $n,$3),$(error $(call str.error.arg.multiline,$0,3)))
override assert.4.is.line          = $(if $(findstring $n,$4),$(error $(call str.error.arg.multiline,$0,4)))

override assert.1.is.word          = $(if $(filter-out 1,$(words $1)),$(error $(call str.error.arg.multiword,$0,1)))
override assert.2.is.word          = $(if $(filter-out 1,$(words $2)),$(error $(call str.error.arg.multiword,$0,2)))
override assert.3.is.word          = $(if $(filter-out 1,$(words $3)),$(error $(call str.error.arg.multiword,$0,3)))
override assert.4.is.word          = $(if $(filter-out 1,$(words $4)),$(error $(call str.error.arg.multiword,$0,4)))
#===============================================================================






#===============================================================================
# BOOLEAN LOGIC
#===============================================================================
#-------------------------------------------------------------------------------
# For use in conditional evaluation.
#
# $(call is.truthy,{val})
# $(call is.falsey,{val})
# Returns $(TRUE.m) if {val} is truthy or falsey, respectively.
# Otherwise, returns $(FALSE.m).
#
# "Truthy" values are listed in $(TRUE.l).
# "Falsey" values are listed in $(FALSE.l). Empty is also considered falsey.
#-------------------------------------------------------------------------------

# "Boolean" types that are printable
override TRUE.p := true
override FALSE.p := false

# "Boolean" types that follow make's convention for conditional evaluation
override TRUE.m := true
override FALSE.m := $e

# "Boolean" types that follow shell conventions for exitcodes (and also C language)
override TRUE.s := 0
override FALSE.s := 1

# "Boolean" types that are actually binary in the traditional sense
override TRUE.b := 1
override FALSE.b := 0

# Lists of truthy values and falsy values, for interactive purposes
override TRUE.l := TRUE True true YES Yes yes Y y 1
override FALSE.l := FALSE False false NO No no N n 0

override is.truthy = $(if $(filter $(TRUE.l),$(strip $1)),$(TRUE.m),$(FALSE.m))
override is.falsey = $(if $(filter $(FALSE.l),$(or $(strip $1),false)),$(TRUE.m),$(FALSE.m))
#===============================================================================



#-------------------------------------------------------------------------------
# make.exit.if.badshell 	[empty] <-- $(call make.exit.if.badshell,[str:command])
#-------------------------------------------------------------------------------
#	Exits Make with an error message if:
#	- $(MAKE_EXIT_IF_BADSHELL) is [true], and
#	- The most recent recipe command or $(shell) invocation failed to start due to
#	  an improperly specified SHELL or .SHELLFLAGS.
#-------------------------------------------------------------------------------
make.exit.if.badshell = $(and $(MAKE_EXIT_IF_BADSHELL),$(filter 127,$(.SHELLSTATUS)),$(error Failed to start shell process:$n  SHELL       = [$(SHELL)]$n  .SHELLFLAGS = [$(.SHELLFLAGS)]$n$(if $1,  Command:      [$1])$n$n))


#-------------------------------------------------------------------------------
# shell.push    	[empty] <-- $(call shell.push,[path:shell],[str:flags])
# shell.pop     	[empty] <-- $(call shell.pop)
#-------------------------------------------------------------------------------
#	Push: Stores the current values of SHELL, .SHELLFLAGS, and .SHELLSTATUS,
#	      then assigns new values to SHELL and/or .SHELLFLAGS.
#	      No-op if [shell] is omitted.
#	Pop:  Restores the previous values of SHELL, .SHELLFLAGS, and .SHELLSTATUS.
#	      No-op if there is no previous value of SHELL.
#-------------------------------------------------------------------------------
shell.push = $(if $1,$(call var.push,SHELL,path,$1)$(call var.push,.SHELLFLAGS,str,$2)$(call var.push,.SHELLSTATUS,int,))
shell.pop  = $(if $(var.SHELL.stack),$(call var.pop,.SHELLSTATUS)$(call var.pop,.SHELLFLAGS)$(call var.pop,SHELL))


#-------------------------------------------------------------------------------
# shell.run     	[str:stdout]   <-- $(call shell.run,[str:command],[var:exitcode],[path:shell],[str:flags])
# shell.test    	[bool:success] <-- $(call shell.test,[str:command],[var:stdout],[path:shell],[str:flags])
#-------------------------------------------------------------------------------
#	Run:  Expands to the stdout of the command.
#	      Optionally stores the exit code for later use.
#	Test: Expands to the '0' if the command was successful, or [empty] if the command failed.
#	      Optionally stores the stdout for later use.
#
#	If [shell] is specified, [command] is run in the alternate [shell]. The original values of
#	  SHELL, .SHELLFLAGS, and .SHELLSTATUS are restored afterward.
#-------------------------------------------------------------------------------
shell.run  = $(if $1,$(if $3,$(call shell.push,$3,$4))$(shell $1)$(call make.exit.if.badshell,$1)$(call var.set,,$2,int,$(.SHELLSTATUS))$(if $3,$(call shell.pop)))
shell.test = $(if $1,$(if $3,$(call shell.push,$3,$4))$(call var.set,,$2,str,$(shell $1))$(call make.exit.if.badshell,$1)$(filter 0,$(.SHELLSTATUS))$(if $3,$(call shell.pop)))



shell = cmd.exe
shellflags = /Q /D /E:ON /F:OFF /V:OFF /S /C

SHELL = $(shell)
.SHELLFLAGS = $(shellflags)
$(info $e)
$(info SHELL = $(SHELL))
$(info .SHELLFLAGS = $(.SHELLFLAGS))
$(info $e)

# Subshell and `exit` are required to prevent spawning orphan processes in some cases
shell.prompt = (cmd.exe /Q /D /E:ON /F:OFF /V:ON /S /C "set /p in=&echo$l!in!&exit 0") 2>nul & exit 0

prompt.str = $(if $1,$(info $1))$(call shell.run,$(shell.prompt))

$(info [$(call prompt.str,Enter a string:)])


$(error Done.)

