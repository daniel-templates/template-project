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

# Empty String ======================== type: [empty], [char], [false]
override char.empty :=# Empty String

# Logical Values ====================== type: {str}, [empty]
override true  := true
override false := $(char.empty)

# Whitespace Characters =============== type: {char}
override char.space := $(char.empty) $(char.empty)
override char.tab   := $(char.empty)	$(char.empty)
override define char.linefeed # BEGIN: definition must contain exactly two empty lines. Do not modify.


endef # END

# Symbols ============================= type: {char}
override char.grave  := `
override char.tilde  := ~
override char.excl   := !
override char.commat := @
override char.num    := \#$(char.empty)
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
override char.bsol   := \$(char.empty)
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

# Aliases for Common Sequences ======== type: [char]
override e := $(char.empty)#    $e --> [empty]    Empty string
override s := $(char.space)#    $s --> {space}    Space character
override t := $(char.tab)#      $t --> {tab}      Tab character
override n := $(char.linefeed)# $n --> {lf}       Linefeed character
override x := $(char.dollar)#   $x --> '$'        Expansion operator
override c := $(char.comma)#    $c --> ','        Comma (Argument Separator)
override g := $(char.num)#      $g --> '#'        Makefile line-comment
override l := $(char.lparen)#   $l --> '('        L Parenthesis
override r := $(char.rparen)#   $r --> ')'        R Parenthesis
override j := $(char.lcub)#     $j --> '{'        L Brace
override k := $(char.rcub)#     $k --> '}'        R Brace
override f := $(char.sol)#      $f --> '/'        Forward Slash
override b := $(char.bsol)#     $b --> '\'        Backslash (required to escape certain characters in paths and patterns)
override p := $(char.percnt)#   $p --> '%'        Wildcard char for $(patsubst), $(filter), pattern targets; Matches 0 or more characters in a [word].
override q := $(char.quest)#    $q --> '?'        Wildcard char for $(wildcard), file targets, prereqs, etc; Matches 1 char in a [path].
override u := $(char.lsqb)#     $u --> '['        Wildcard char for $(wildcard), file targets, prereqs, etc; Matches 1 from the set of chars [...] in a path.
override v := $(char.rsqb)#     $v --> ']'        Wildcard char for $(wildcard), file targets, prereqs, etc; Matches 1 from the set of chars [...] in a path.
override w := $(char.ast)#      $w --> '*'        Wildcard char for $(wildcard), file targets, prereqs, etc; Matches 0 or more chars in a [path].


# Character Sets ====================== type: list[char]
override char.lowers     := a b c d e f g h i j k l m n o p q r s t u v w x y z
override char.uppers     := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
override char.digits     := 0 1 2 3 4 5 6 7 8 9
#                                     #   $   %         (   )               {   }   \             ,
override char.symbols    := ` ~ ! @ $$g $$x $$p ^ & * $$l $$r - _ = + [ ] $$j $$k $$b | ; : ' " $$c . < > / ?
#                         space tab newline
override char.whitespace := $$s $$t $$n



#-------------------------------------------------------------------------------
#> chars.split          	[list{char}] <-- $(call chars.split,[type:T],[T:val])
#-------------------------------------------------------------------------------
override chars.split = $(if $1,$(if $2,$(call chars.split.{$(patsubst [%],%,$(1:{%}=%))},$2)),$2)

# <lib.generics.mak>
override chars.split.{alphanum} = $(strip $(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(call word.pack.{alphanum},$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{alpha} = $(strip $(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(call word.pack.{alpha},$1))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{bool} = $(strip $(subst u,u$s,$(subst t,t$s,$(subst r,r$s,$(subst e,e$s,$(call word.pack.{bool},$1))))))
override chars.split.{char} = $1
override chars.split.{digit} = $1
override chars.split.{expr} = $(chars.split.{str})
override chars.split.{flavor} = $(chars.split.{alpha})
override chars.split.{idx} = $(chars.split.{int})
override chars.split.{int} = $(strip $(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst -,-$s,$(subst +,+$s,$(call word.pack.{int},$1))))))))))))))
override chars.split.{line} = $(strip $(subst ~,~$s,$(subst |,|$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst >,>$s,$(subst =,=$s,$(subst <,<$s,$(subst ;,;$s,$(subst :,:$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst &,&$s,$(subst ","$s,$(subst !,!$s,$(subst $$t,$$t$s,$(subst $$s,$$s$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{line},$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{list} = $(strip $(subst ~,~$s,$(subst |,|$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst >,>$s,$(subst =,=$s,$(subst <,<$s,$(subst ;,;$s,$(subst :,:$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst &,&$s,$(subst ","$s,$(subst !,!$s,$(subst $$s,$$s$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{list},$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{origin} = $(chars.split.{list})
override chars.split.{path} = $(strip $(subst ~,~$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst =,=$s,$(subst ;,;$s,$(subst :,:$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst !,!$s,$(subst $$s,$$s$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{path},$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{str} = $(strip $(subst ~,~$s,$(subst |,|$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst >,>$s,$(subst =,=$s,$(subst <,<$s,$(subst ;,;$s,$(subst :,:$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst &,&$s,$(subst ","$s,$(subst !,!$s,$(subst $$t,$$t$s,$(subst $$s,$$s$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$n,$$n$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{str},$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{type} = $(chars.split.{word})
override chars.split.{uint} = $(strip $(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst +,+$s,$(call word.pack.{uint},$1)))))))))))))
override chars.split.{var} = $(strip $(subst ~,~$s,$(subst |,|$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst >,>$s,$(subst <,<$s,$(subst ;,;$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst &,&$s,$(subst ","$s,$(subst !,!$s,$(subst $$t,$$t$s,$(subst $$s,$$s$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$n,$$n$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{var},$1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
override chars.split.{word} = $(strip $(subst ~,~$s,$(subst |,|$s,$(subst z,z$s,$(subst y,y$s,$(subst x,x$s,$(subst w,w$s,$(subst v,v$s,$(subst u,u$s,$(subst t,t$s,$(subst s,s$s,$(subst r,r$s,$(subst q,q$s,$(subst p,p$s,$(subst o,o$s,$(subst n,n$s,$(subst m,m$s,$(subst l,l$s,$(subst k,k$s,$(subst j,j$s,$(subst i,i$s,$(subst h,h$s,$(subst g,g$s,$(subst f,f$s,$(subst e,e$s,$(subst d,d$s,$(subst c,c$s,$(subst b,b$s,$(subst a,a$s,$(subst `,`$s,$(subst _,_$s,$(subst ^,^$s,$(subst ],]$s,$(subst [,[$s,$(subst Z,Z$s,$(subst Y,Y$s,$(subst X,X$s,$(subst W,W$s,$(subst V,V$s,$(subst U,U$s,$(subst T,T$s,$(subst S,S$s,$(subst R,R$s,$(subst Q,Q$s,$(subst P,P$s,$(subst O,O$s,$(subst N,N$s,$(subst M,M$s,$(subst L,L$s,$(subst K,K$s,$(subst J,J$s,$(subst I,I$s,$(subst H,H$s,$(subst G,G$s,$(subst F,F$s,$(subst E,E$s,$(subst D,D$s,$(subst C,C$s,$(subst B,B$s,$(subst A,A$s,$(subst @,@$s,$(subst ?,?$s,$(subst >,>$s,$(subst =,=$s,$(subst <,<$s,$(subst ;,;$s,$(subst :,:$s,$(subst 9,9$s,$(subst 8,8$s,$(subst 7,7$s,$(subst 6,6$s,$(subst 5,5$s,$(subst 4,4$s,$(subst 3,3$s,$(subst 2,2$s,$(subst 1,1$s,$(subst 0,0$s,$(subst /,/$s,$(subst .,.$s,$(subst -,-$s,$(subst +,+$s,$(subst *,*$s,$(subst ','$s,$(subst &,&$s,$(subst ","$s,$(subst !,!$s,$(subst $$r,$$r$s,$(subst $$p,$$p$s,$(subst $$l,$$l$s,$(subst $$k,$$k$s,$(subst $$j,$$j$s,$(subst $$g,$$g$s,$(subst $$c,$$c$s,$(subst $$b,$$b$s,$(subst $$x,$$x$s,$(call word.pack.{word},$1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
# <\lib.generics.mak>



#-------------------------------------------------------------------------------
#> word.pack             	[word[T]] <-- $(call word.pack,[type:T],[T:val])
#> word.unpack           	[T]       <-- $(call word.unpack,[type:T],[word[T]:packed_val])
#-------------------------------------------------------------------------------
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
override word.pack   = $(if $1,$(or $(call word.pack.{$(patsubst [%],%,$(1:{%}=%))},$2),$(if $(1:{%}=),$$e)),$2)
override word.unpack = $(if $1,$(call word.unpack.{$(patsubst [%],%,$(1:{%}=%))},$(subst $(if $(1:{%}=),$$e),,$2)),$2)

# <lib.generics.mak>
override word.pack.{alphanum} = $1
override word.pack.{alpha} = $1
override word.pack.{bool} = $1
override word.pack.{char} = $(word.pack.{str})
override word.pack.{digit} = $1
override word.pack.{expr} = $(word.pack.{str})
override word.pack.{flavor} = $(word.pack.{alpha})
override word.pack.{idx} = $(word.pack.{int})
override word.pack.{int} = $(subst +,,$1)
override word.pack.{line} = $(subst $t,$$t,$(subst $s,$$s,$(subst $r,$$r,$(subst $$p,$$p,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1)))))))))))
override word.pack.{list} = $(subst $s,$$s,$(subst $r,$$r,$(subst $$p,$$p,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1))))))))))
override word.pack.{origin} = $(word.pack.{list})
override word.pack.{path} = $(subst $xt,$t,$(subst $xn,$n,$(subst $s,/,$(strip $(subst /,$s,$(subst $n,$xn,$(subst $t,$xt,$(subst $b,/,$(subst $s,$b$s,$(subst $b$s,$b$s,$(subst $b],$b],$(subst $b[,$b[,$(subst $b$b,$b$b,$(subst $b,$b,$(subst $s,$$s,$(subst $r,$$r,$(subst $$p,$$p,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1))))))))))))))))))))))))
override word.pack.{str} = $(subst $t,$$t,$(subst $s,$$s,$(subst $r,$$r,$(subst $$p,$$p,$(subst $n,$$n,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1))))))))))))
override word.pack.{type} = $(word.pack.{word})
override word.pack.{uint} = $(word.pack.{int})
override word.pack.{var} = $(subst $t,$$t,$(subst $s,$$s,$(subst $r,$$r,$(subst $$p,$$p,$(subst $n,$$n,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1))))))))))))
override word.pack.{word} = $(subst $r,$$r,$(subst $$p,$$p,$(subst $l,$$l,$(subst $k,$$k,$(subst $j,$$j,$(subst $g,$$g,$(subst $c,$$c,$(subst $b,$$b,$(subst $$,$$x,$1)))))))))

override word.unpack.{alphanum} = $1
override word.unpack.{alpha} = $1
override word.unpack.{bool} = $1
override word.unpack.{char} = $(word.unpack.{str})
override word.unpack.{digit} = $1
override word.unpack.{expr} = $(word.unpack.{str})
override word.unpack.{flavor} = $(word.unpack.{alpha})
override word.unpack.{idx} = $(word.unpack.{int})
override word.unpack.{int} = $1
override word.unpack.{line} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$p,$$p,$(subst $$r,$r,$(subst $$s,$s,$(subst $$t,$t,$1)))))))))))
override word.unpack.{list} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$p,$$p,$(subst $$r,$r,$(subst $$s,$s,$1))))))))))
override word.unpack.{origin} = $(word.unpack.{list})
override word.unpack.{path} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$p,$$p,$(subst $$r,$r,$(subst $$s,$s,$1))))))))))
override word.unpack.{str} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$n,$n,$(subst $$p,$$p,$(subst $$r,$r,$(subst $$s,$s,$(subst $$t,$t,$1))))))))))))
override word.unpack.{type} = $(word.unpack.{word})
override word.unpack.{uint} = $1
override word.unpack.{var} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$n,$n,$(subst $$p,$$p,$(subst $$r,$r,$(subst $$s,$s,$(subst $$t,$t,$1))))))))))))
override word.unpack.{word} = $(subst $$x,$$,$(subst $$b,$b,$(subst $$c,$c,$(subst $$g,$g,$(subst $$j,$j,$(subst $$k,$k,$(subst $$l,$l,$(subst $$p,$$p,$(subst $$r,$r,$1)))))))))
# <\lib.generics.mak>



#-------------------------------------------------------------------------------
#> word.repack          	[word[T]] <-- $(call word.repack,[type:T],[word[T]:packed_val])
#> normalize            	[T]       <-- $(call normalize,[type:T],[T:val])
#-------------------------------------------------------------------------------
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
#> word.join.pair       	[word[T]] <-- $(call word.join.pair,[type:T],[word[T]:sep],[word[T]:1],[word[T]:2])
#> normalize.pair       	[T]       <-- $(call normalize.pair,[type:T],[T:sep],[T:1],[T:2])
#-------------------------------------------------------------------------------
#
#	Joins two values into one using [sep].
#	If [1] or [2] are [empty] (or unpack to [empty]), no [sep] is added.
#	Result is repacked/normalized.
#	If [T] is omitted, both functions are equivalent to `$(call str.concat.pair,[sep],[1],[2])`.
#
#-------------------------------------------------------------------------------
override word.join.pair = $(call word.pack,$1,$(call str.concat.pair,$2,$(call word.unpack,$1,$3),$(call word.unpack,$1,$4)))
override normalize.pair = $(call normalize,$1,$(call str.concat.pair,$2,$3,$4))



#-------------------------------------------------------------------------------
#> str.equ          	[str] <-- $(call str.equ,[str:1],[str:2],[bool:case_insensitive])
#> str.neq          	[str] <-- $(call str.neq,[str:1],[str:2],[bool:case_insensitive])
#-------------------------------------------------------------------------------
#
#	Returns {true} if the strings are equal (or notequal).
#	Case-sensitive by default.
#
#-------------------------------------------------------------------------------
override str.equ = $(if $3,$(call str.equ,$(call str.lower,$1),$(call str.lower,$2)),$(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(false),$(true)))
override str.neq = $(if $3,$(call str.equ,$(call str.lower,$1),$(call str.lower,$2)),$(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(true),$(false)))



#-------------------------------------------------------------------------------
#> str.len          	[uint] <-- $(call str.len,[type:T],[T:str])
#> str.sub          	[T]    <-- $(call str.sub,[type:T],[T:str],[idx:start],[uint:end])
#> str.cnt          	[uint] <-- $(call str.cnt,[type:T],[T:find],[T:in])
#-------------------------------------------------------------------------------
#
#	str.len:   Returns the number of characters in a string.
#	           - If [type] is omitted, assumes [type] = list{char}.
#	str.sub:   Returns the substring between two character positions, inclusive.
#	           - First character has index 1.
#	           - If [type] is omitted, assumes [type] = list{char}.
#	           - If [start] is omitted, returns [empty].
#	           - If [end] is omitted, returns substring to end of [str].
#	str.cnt:   Returns the number of occurrances of the substring [find] in [in].
#	           - If [type] is omitted, assumes [type] = word[str].
#	           - If [type] includes [empty] (bracketed [type]), [find] = [empty] matches [empty].
#	           - If [type] excludes [empty] (braced {type}),    [find] = [empty] matches nothing.
#-------------------------------------------------------------------------------
override str.len = $(if $1,$(call $0,,$(call chars.split,$1,$2)),$(words $2))
override str.sub = $(if $3,$(if $1,$(call word.unpack,$1,$(subst $s,,$(call $0,,$(call chars.split,$1,$2),$3,$4))),$(wordlist $3,$(or $4,$(words $2)),$2)))
override str.cnt = $(if $1,$(call $0,,$(call word.pack,$1,$2),$(call word.pack,$1,$3)),$(words $(call list.remove.first,$(if $2,$(subst $2,.$s.,$(subst $$$2,$$$$,$3))))))



#-------------------------------------------------------------------------------
#> str.concat.pair   	[str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
#> str.concat        	[str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])
#
#	Concatentates each nonempty [str] argument with the given separator [sep].
#	Empty arguments are skipped; no separator is included for them.
#
#-------------------------------------------------------------------------------
override str.concat.pair = $(if $(and $2,$3),$2$1$3,$(or $2,$3))
override str.concat      = $(if $(or $3,$4,$5,$6,$7,$8,$9),$(call str.concat.pair,$1,$2,$(call str.concat,$1,$3,$4,$5,$6,$7,$8,$9)),$2)



#-------------------------------------------------------------------------------
#> str.lower      	[lower] <-- $(call str.lower,[str])
#> str.upper      	[upper] <-- $(call str.upper,[str])
#
#	Returns [lower]-case or [upper]-case of [str].
#
#-------------------------------------------------------------------------------
override str.lower = $(call str.subst.list2list,$1,$(char.uppers),$(char.lowers))
override str.upper = $(call str.subst.list2list,$1,$(char.lowers),$(char.uppers))



#-------------------------------------------------------------------------------
#> str.indent.add    	[str] <-- $(call str.indent.add,[str:multiline],[str:indent])
#> str.indent.set    	[str] <-- $(call str.indent.set,[str:multiline],[str:indent])
#
#	Add: For each line in [multiline], prefixes with [indent].
#	Set: For each line in [multiline], removes leading whitespace, then prefixes with [indent].
#
#-------------------------------------------------------------------------------
override str.indent.add = $2$(subst $n,$n$2,$1)
override str.indent.set = $(call str.indent.add,$(call str.map,line,str.strip.start,$n,$1,s t),$2)



#-------------------------------------------------------------------------------
#> str.to.block         	{block} <-- $(call str.to.block,[type:T],[T:str],[T:pad],[left|right])
#> block.to.str         	[str]   <-- $(call block.to.str,[block])
#-------------------------------------------------------------------------------
#
#	Conversion to/from character block: {list[list{char}]}.
#	- Each item in the outer list represents one line.
#		- Lines may be empty (0 characters); represented as '$e'.
#		- The [empty] string is represented as a single empty line '$e'.
#	- Each item in the inner list represents one character.
#		- Tabs ($t) are replaced with the value of $(line.indent).
#		- Linefeeds ($n) are used to split the outer list, so are never present in the inner list.
#		- Empty characters ($e) are not allowed here.
#
#-------------------------------------------------------------------------------
# [block] <-- $(call __str.to.block,[list{char}],{word{char}:pad},{left|right})
override __str.to.block = $(call __block.resize,$(call str.split,line,$1,$$n),$2,$(subst $$e,$$e$s,$(lastword $(sort $(subst $$n$$e,$s,$(subst $s,,$(filter $$n $$e,$(addsuffix $s$$e,$1))))))),extend,$(subst left,end,$(3:right=start)),,extend,end)
override str.to.block = $(if $1,$(call __$0,$(call chars.split,$1,$(subst $t,$(line.indent),$2)),$(call word.pack,$1,$(or $3,$s)),$(or $4,left)),$2)
override block.to.str = $(call word.unpack,line,$(subst $s,,$(call list.merge,line,$1,$n)))



#-------------------------------------------------------------------------------
#> block.hresize     	[block] <-- $(call block.hresize,[block],[block:width],[char:pad],[extend|resize],[end|start])
#> block.vresize     	[block] <-- $(call block.vresize,[block],[block:height],[char:pad],[extend|resize],[end|start])
#-------------------------------------------------------------------------------
# [block] <-- $(call __block.resize,[block],{word{char}:pad},[list:width],{extend|resize},{end|start},[list:height],{extend|resize},{end|start})
override __block.resize = $(if $1,$(foreach line,$(if $6,$(call list.$7.$8,line,$1,$6,$(3:%=$2)),$1),$(call word.pack,line,$(call list.$4.$5,,$(call word.unpack,line,$(line)),$3,$2))),$1)
override block.hresize  = $(call __block.resize,$(strip $1),$(if $3,$(call word.pack,{char},$3),$$s),$(call word.unpack,line,$(or $(firstword $2),$(firstword $1))),$(or $4,extend),$(or $5,end),,extend,end)
override block.vresize  = $(call __block.resize,$(strip $1),$(if $3,$(call word.pack,{char},$3),$$s),$(call word.unpack,line,$(firstword $1)),extend,end,$(strip $2),$(or $4,extend),$(or $5,end))



#-------------------------------------------------------------------------------
#> block.hreshape   	[block] <-- $(call block.hreshape,[block],[block:width],[char:pad]
#-------------------------------------------------------------------------------
# [block] <-- $(call __line.reshape,{list{char}},{word{char}:pad},[list:width],[block:append])
override __block.hreshape = $(if $1,$(if $3,$(call $0,$(wordlist $(words x $3),$(words $1),$1),$2,$3,$4 $(call word.pack,line,$(call list.extend.end,,$(wordlist 1,$(words $3),$1),$3,$2))),$4),$4)
override block.hreshape   = $(if $(and $1,$2),$(foreach pad,$(if $3,$(call word.pack,{char},$3),$$s),$(or $(foreach width,$(subst $s,_,$(patsubst %,$$e,$(call word.unpack,line,$(firstword $2)))),$(foreach line,$1,$(call __$0,$(call word.unpack,line,$(line)),$(pad),$(subst _,$s,$(width))))),$1)),$1)



#-------------------------------------------------------------------------------
#> block.hstack      	[block] <-- $(call block.hstack,[block:1],[block:2],[char:pad])
#> block.vstack      	[block] <-- $(call block.vstack,[block:1],[block:2],[char:pad])
#-------------------------------------------------------------------------------
#
#	+----------------------------+----------------------------+----------------------------------+
#	| HSTACK                     | HSTACK                     | HSTACK                           |
#	|   [1..] [A]  --> [1..A.]   |   [A]  [1..] --> [A.1..]   |   [1..] --> [1..] [] --> [1..]   |
#	|   [2.]  [B.] --> [2..B.]   |   [B.] [2.]  --> [B.2..]   |   [2.]  --> [2.]  [] --> [2..]   |
#	|   [3]        --> [3....]   |        [3]   --> [..3..]   |   [3]   --> [3]   [] --> [3..]   |
#	+----------------------------+----------------------------+----------------------------------+
#	| VSTACK                     | VSTACK                     | VSTACK                           |
#	|   [1..] [A]  --> [1..]     |   [A]  [1..] --> [A..]     |   [1..] --> [1..]                |
#	|   [2.]  [B.] --> [2..]     |   [B.] [2.]  --> [B..]     |   [2.]  --> [2..]                |
#	|   [3]        --> [3..]     |        [3]   --> [1..]     |   [3]   --> [3..]                |
#	|              --> [A..]     |              --> [2..]     |                                  |
#	|              --> [B..]     |              --> [3..]     |                                  |
#	+----------------------------+----------------------------+----------------------------------+
#
#-------------------------------------------------------------------------------
override block.hstack = $(foreach line,$(join $(call block.vresize,$1,$2,$3),$(addprefix $$s,$(call block.vresize,$2,$1,$3))),$(call word.pack,line,$(strip $(call word.unpack,line,$(line)))))
override block.vstack = $(strip $(call block.hresize,$1,$2,$3) $(call block.hresize,$2,$1,$3))



#-----------------------------------------------------------
#> str.map           	[str] <-- $(call str.map.{N},[type:T],
#> str.map.1         	              [func[T]([T:1],...,[T:N],[str:const1],...)],
#> str.map.2         	              [str:sep],
#> str.map.3         	              [str:1],...,[str:N],
#> str.map.4         	              [str:const1],...)
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
override str.map.1 = $(call list.merge,$1,$(call list.map.1,$1,$2,$(call str.split,$1,$4,$3),$5,$6,$7,$8),$3)
override str.map.2 = $(call list.merge,$1,$(call list.map.2,$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$6,$7,$8,$9),$3)
override str.map.3 = $(call list.merge,$1,$(call list.map.3,$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$(call str.split,$1,$6,$3),$7,$8,$9,$(10)),$3)
override str.map.4 = $(call list.merge,$1,$(call list.map.4,$1,$2,$(call str.split,$1,$4,$3),$(call str.split,$1,$5,$3),$(call str.split,$1,$6,$3),$(call str.split,$1,$7,$3),$8,$9,$(10),$(11)),$3)




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
#> str.subst.list2str        	[str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])
#> str.subst.list2var        	[str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])
#> str.subst.vars2str        	[str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])
#> str.subst.vars2var        	[str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])
#> str.strip.list            	[str] <-- $(call str.strip.list,[str:in],[list:strip])
#> str.strip.list.start      	[str] <-- $(call str.strip.list.start,[str:in],[list:strip])
#> str.strip.list.end        	[str] <-- $(call str.strip.list.end,[str:in],[list:strip])
#> str.strip.vars            	[str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])
#> str.strip.vars.start      	[str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])
#> str.strip.vars.end        	[str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])
#
#-------------------------------------------------------------------------------
#	[word[str]] <-- $(call __str.strip.many.start,[word[str]:in],[list[str]:strip])
#	[word[str]] <-- $(call __str.strip.many.end  ,[word[str]:in],[list[str]:strip])
override __str.strip.many.start = $(subst $s,,$(call list.filter-out.start,$(subst $$e,$s,$(call __str.treesubst.many2many,$1,$2,$(foreach word,$2,$$e$(word)$$e))),$2))
override __str.strip.many.end   = $(subst $s,,$(call list.filter-out.end,$(subst $$e,$s,$(call __str.treesubst.many2many,$1,$2,$(foreach word,$2,$$e$(word)$$e))),$2))
#-------------------------------------------------------------------------------
override str.subst.list2str     = $(call list.reduce.1,,str.subst.str2str,$1,$2,$3)
override str.subst.list2var     = $(call list.reduce.1,,str.subst.str2var,$1,$2,$3)
override str.subst.vars2str     = $(call list.reduce.1,,str.subst.var2str,$1,$2,$3)
override str.subst.vars2var     = $(call list.reduce.1,,str.subst.var2var,$1,$2,$3)
override str.strip.list         = $(call list.reduce.1,,str.strip.str,$1,$2)
override str.strip.list.start   = $(call word.unpack,{str},$(call __str.strip.many.start,$(call word.pack,{str},$1),$(call word.pack,{word},$2)))
override str.strip.list.end     = $(call word.unpack,{str},$(call __str.strip.many.end,$(call word.pack,{str},$1),$(call word.pack,{word},$2)))
override str.strip.vars         = $(call list.reduce.1,,str.strip.var,$1,$2)
override str.strip.vars.start   = $(call word.unpack,{str},$(call __str.strip.many.start,$(call word.pack,{str},$1),$(foreach var,$2,$(call word.pack,{str},$($(var))))))
override str.strip.vars.end     = $(call word.unpack,{str},$(call __str.strip.many.end,$(call word.pack,{str},$1),$(foreach var,$2,$(call word.pack,{str},$($(var))))))



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
#> str.treesubst.list2list     	[str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
#> str.treesubst.list2vars     	[str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])
#> str.treesubst.vars2list     	[str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])
#> str.treesubst.vars2vars     	[str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
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
override __str.treesubst.many2one  = $(if $(and $1,$(firstword $2)),$(subst $s,$3,$(strip $(foreach word,$(subst $(or $(subst $$e,,$(firstword $2)),$s),$$e$s$$e,$1),$(if $(subst $$e,,$(word)),$(call $0,$(word),$(wordlist 2,$(words $2),$2),$3),$(word))))),$1)
override __str.treesubst.many2many = $(if $(and $1,$(firstword $2)),$(subst $s,$(firstword $3),$(strip $(foreach word,$(subst $(or $(subst $$e,,$(firstword $2)),$s),$$e$s$$e,$1),$(if $(subst $$e,,$(word)),$(call $0,$(word),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3)),$(word))))),$1)
override str.treesubst.list2list = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(call word.pack,{word},$2),$(call word.pack,{word},$3)))
override str.treesubst.list2vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(call word.pack,{word},$2),$(foreach var,$3,$(call word.pack,str,$($(var))))))
override str.treesubst.vars2list = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(foreach var,$2,$(call word.pack,str,$($(var)))),$(call word.pack,{word},$3)))
override str.treesubst.vars2vars = $(call word.unpack,str,$(call __str.treesubst.many2many,$(call word.pack,str,$1),$(foreach var,$2,$(call word.pack,str,$($(var)))),$(foreach var,$3,$(call word.pack,str,$($(var))))))









#===============================================================================

#===============================================================================
# VARIABLES
#===============================================================================



#-------------------------------------------------------------------------------
#> var.is.shortname      	[bool:var] <-- $(call var.is.shortname,[var])
#> var.is.defined        	[bool:var] <-- $(call var.is.defined,[var])
#> var.is.undefined      	[bool:var] <-- $(call var.is.undefined,[var])
#> var.is.environment    	[bool:var] <-- $(call var.is.environment,[var])
#> var.is.commandline    	[bool:var] <-- $(call var.is.commandline,[var])
#> var.is.makefile       	[bool:var] <-- $(call var.is.makefile,[var])
#> var.is.internal       	[bool:var] <-- $(call var.is.internal,[var])
#> var.is.ws             	[bool:var] <-- $(call var.is.ws,[var])
#> var.is.nonws          	[bool:var] <-- $(call var.is.nonws,[var])
#> var.is.empty          	[bool:var] <-- $(call var.is.empty,[var])
#> var.is.def.empty      	[bool:var] <-- $(call var.is.def.empty,[var])
#> var.is.nonempty       	[bool:var] <-- $(call var.is.nonempty,[var])
#-------------------------------------------------------------------------------
override var.is.shortname   = $(filter $(filter-out $$%,$(char.{var}:\%=\%)),$1)
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
#> var.push        	[empty] <-- $(call var.push,[var],[type:T],[T:val])
#> var.pop         	[empty] <-- $(call var.pop,[var])
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
var.push = $(if $1,$(eval var.$1.stack += $(subst $x,$$x,$(call word.pack,expr,$1$(if $(filter recursive,$(flavor $1)),=,:=)$(value $1)))$n$1$(if $2,:=$(call word.pack,$2,$3),=$3)))
var.pop  = $(if $1,$(eval $(call word.unpack,expr,$(lastword $(var.$1.stack)))$nvar.$1.stack := $$(wordlist 2,$$(words $$(var.$1.stack)),x $$(var.$1.stack))))


#-------------------------------------------------------------------------------
#> var.set       	[empty] <-- $(call var.set,[directives],[var],[type:T],[T:val])
#> var.append    	[empty] <-- $(call var.append,[directives],[var],[type:T],[T:val])
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
#> str.split         	[list[T]] <-- $(call str.split,[type:T],[T:str],[T:sep])
#> list.merge        	[str]     <-- $(call list.merge,[type:T],[list[T]],[T:sep])
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
# [list[T]] <-- $(call str.split,[type:T],[T:str],[T:sep],[T:empty],[bool:phase2])
override str.split  = $(if $5,$(strip $(foreach word,$(subst $$$$,$(if $1,$$$3,$$$$),$(subst $3,$4$s$4,$(subst $(if $1,$$$3,$$$$),$$$$,$2))),$(or $(subst $4,,$(word)),$4))),$(call $0,$1,$(call word.pack,$1,$2),$(call word.pack,$1,$3),$(call word.pack,$1,$e),$(true)))
override list.merge = $(call word.unpack,$1,$(subst $s,$(call word.pack,$1,$3),$(strip $2)))



#-------------------------------------------------------------------------------
#> list.format      	[list[T]] <-- $(call list.format,[type:T],\
#>                  	                  item 1    $n\
#>                  	                  item 2    $n\
#>                  	              )
#
#	Convenience method for manual list definition.
#	Splits the second argument on linefeed ($n), encoding each line as a word-packed T.
#	- Each line must end with '$n\'.
#	- Leading and trailing whitespace are stripped.
#-------------------------------------------------------------------------------
override list.format = $(foreach line,$(call word.pack,{line},$(subst $n$s,$n,$n$2)),$(call word.pack,$1,$(call word.unpack,{line},$(subst $s,,$(call list.filter-out.end,$(subst $$t,$s$$t,$(subst $$s,$s$$s,$(line))),$$s $$t)))))


#-------------------------------------------------------------------------------
#> list.prune        	[list[T]] <-- $(call list.prune,[type:T],[list[T]])
#> list.repack       	[list[T]] <-- $(call list.repack,[type:T],[list[T]])
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
override list.repack = $(foreach word,$2,$(call word.repack,$1,$(word)))



#-------------------------------------------------------------------------------
#> list.filter           	[list[T]] <-- $(call list.filter,[type:T],[list[T]],[T:val])
#> list.filter-out       	[list[T]] <-- $(call list.filter-out,[type:T],[list[T]],[T:val])
#> list.filter-out.start 	[list]    <-- $(call list.filter-out.start,[list:in],[list:filter-out])
#> list.filter-out.end   	[list]    <-- $(call list.filter-out.end,[list:in],[list:filter-out])
#
#	Returns a [list] of words equal (or not-equal) to [val].
#
#-------------------------------------------------------------------------------
override list.filter           = $(filter $(call word.pack,$1,$3),$2)
override list.filter-out       = $(filter-out $(call word.pack,$1,$3),$2)
override list.filter-out.start = $(if $(filter $2,$(firstword $1)),$(call $0,$(wordlist 2,$(words $1),$1),$2),$1)
override list.filter-out.end   = $(if $(filter $2,$(lastword $1)),$(call $0,$(wordlist 2,$(words $1),x $1),$2),$1)



#-------------------------------------------------------------------------------
#> list.extend.start     	[list[T]] <-- $(call list.extend.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
#> list.extend.end       	[list[T]] <-- $(call list.extend.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
#> list.resize.start     	[list[T]] <-- $(call list.resize.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
#> list.resize.end       	[list[T]] <-- $(call list.resize.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
#
#	Extend: Appends new items to (start, end) of [list:from] until equal in size to [list:to].
#	        If [from] is longer than [to], it is returned unmodified.
#
#	Resize: Appends new items to (start, end) of [list:from] until equal in size to [list:to].
#	        If [from] is longer than [to], removes items from (start, end) until sizes are equal.
#
#-------------------------------------------------------------------------------
override list.extend.start = $(strip    $(foreach pad,$(call word.pack,$1,$4),$(foreach word,$(wordlist $(words x $2),$(words $3),$3),$(pad))) $2)
override list.extend.end   = $(strip $2 $(foreach pad,$(call word.pack,$1,$4),$(foreach word,$(wordlist $(words x $2),$(words $3),$3),$(pad)))   )
override list.resize.start = $(if $5,$(wordlist $(words x $2),$(words $3 $2),$3 $2),$(call $0,$1,$(call list.extend.start,$1,$2,$3,$4),$3,$4,$(true)))
override list.resize.end   = $(if $5,$(wordlist             1,$(words $3   ),   $2),$(call $0,$1,$(call list.extend.end,$1,$2,$3,$4),$3,$4,$(true)))


#-------------------------------------------------------------------------------
#> list.join     	[list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2])
#> list.join.2   	[list[list[T]]] <-- $(call list.join.{N},[list[T]:1],[list[T]:N])
#> list.join.3
#> list.join.4
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
override list.join.2 = $(strip $(if $(firstword $1$2)    ,$(call word.pack,{str},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e))$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2))))
override list.join.3 = $(strip $(if $(firstword $1$2$3)  ,$(call word.pack,{str},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e)$s$(or $(firstword $3),$$e))$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3))))
override list.join.4 = $(strip $(if $(firstword $1$2$3$4),$(call word.pack,{str},$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e)$s$(or $(firstword $3),$$e)$s$(or $(firstword $4),$$e)$s)$s$(call $0,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4))))


#-----------------------------------------------------------
#> list.map      	[list[T]] <-- $(call list.map.{N},[type:T],const1],...)
#> list.map.1    	                              [func[T]([T:1],...,[T:N],[str:const1],...)],
#> list.map.2    	                              [list[T]:1],...,[list[T]:N],
#> list.map.3    	                              [str:const1],...
#> list.map.4    	               )
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
override list.map.1 = $(foreach word,$3,$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(word)),$4,$5,$6,$7)))
override list.map.2 = $(if $(firstword $3$4),    $(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$5,$6,$7,$8,,,$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$5,$6,$7,$8))),$(strip $(11)))
override list.map.3 = $(if $(firstword $3$4$5),  $(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$6,$7,$8,$9,,$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$6,$7,$8,$9))),$(strip $(11)))
override list.map.4 = $(if $(firstword $3$4$5$6),$(call $0,$1,$2,$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$7,$8,$9,$(10),$(11)$s$(call word.pack,$1,$(call $2,$(call word.unpack,$1,$(firstword $3)),$(call word.unpack,$1,$(firstword $4)),$(call word.unpack,$1,$(firstword $5)),$(call word.unpack,$1,$(firstword $6)),$7,$8,$9,$(10)))),$(strip $(11)))


#-------------------------------------------------------------------------------
#> list.reduce       	[str] <-- $(call list.reduce.{N},[type:T],
#> list.reduce.1     	                             [func[str]([str:acc],[T:1],...,[T:N],[str:const1],...)],
#> list.reduce.2     	                             [str:acc],
#> list.reduce.3     	                             [list[T]:1],...,[list[T]:N],
#> list.reduce.4     	                             [str:const1],...
#>                   	           )
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
#> list.reverse      	[list[T]] <-- $(call list.reverse,[list[T]])
#
#	Reverses the order of words in a list.
#
#-------------------------------------------------------------------------------
override list.reverse = $(if $(word 2,$1),$(call list.reverse,$(wordlist 2,$(words $1),$1))$s$(firstword $1),$1)



#-------------------------------------------------------------------------------
#> list.idx          	[idx] <-- $(call list.idx,[list[T]],[int:idx])
#> list.idx.prev     	[idx] <-- $(call list.idx.prev,[list[T]],[int:idx])
#> list.idx.next     	[idx] <-- $(call list.idx.next,[list[T]],[int:idx])
#> list.idx.first    	[idx] <-- $(call list.idx.first,[list[T]])
#> list.idx.last     	[idx] <-- $(call list.idx.last,[list[T]])
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
#> list.insert   	[list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
#> list.prepend  	[list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])
#> list.append   	[list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])
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
#> list.remove       	[list[T]] <-- $(call list.remove,[list[T]],[idx])
#> list.remove.first 	[list[T]] <-- $(call list.remove.first,[list[T]])
#> list.remove.last  	[list[T]] <-- $(call list.remove.last,[list[T]])
#
#	Removes the value at [idx] from the list.
#
#-------------------------------------------------------------------------------
override list.remove.N     = $(strip $(if $2,$(wordlist 1,$(call __list.idx.dec,$1,$2),$1)$s$(wordlist $(call __list.idx.inc,$1,$2),$(words $1),$1),$1))
override list.remove       = $(call list.remove.N,$1,$(call list.idx,$1,$2))
override list.remove.first = $(wordlist 2,$(words $1),$1)
override list.remove.last  = $(wordlist 2,$(words $1),x $1)


#-------------------------------------------------------------------------------
#> list.get          	[T] <-- $(call list.get,[type:T],[list[T]],[idx])
#> list.get.first    	[T] <-- $(call list.get.first,[type:T],list[T]])
#> list.get.last     	[T] <-- $(call list.get.last,[type:T],list[T]])
#
#	Returns the original (unpacked) value of type [T] from [idx].
#
#-------------------------------------------------------------------------------
override list.get.N     = $(call word.unpack,$1,$(if $3,$(word $3,$2)))
override list.get       = $(call list.get.N,$1,$2,$(call list.idx,$2,$3))
override list.get.first = $(call word.unpack,$1,$(firstword $2))
override list.get.last  = $(call word.unpack,$1,$(lastword $2))


#-------------------------------------------------------------------------------
#> list.set          	[list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])
#> list.set.first    	[list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])
#> list.set.last     	[list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])
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
# Path: Components
#-------------------------------------------------------------------------------
#> path.abspath          	[path]       <-- $(call path.abspath,[path])
#> path.realpath         	[path]       <-- $(call path.realpath,[path])
#> path.dir              	[path]       <-- $(call path.dir,[path])
#> path.notdir           	[path]       <-- $(call path.notdir,[path])
#> path.parent           	[path]       <-- $(call path.parent,[path])
#> path.name             	[path]       <-- $(call path.name,[path])
#> path.name.base        	[path]       <-- $(call path.name.base,[path])
#> path.basename         	[path]       <-- $(call path.basename,[path])
#> path.suffix           	[path]       <-- $(call path.suffix,[path])
#> list.path.abspath     	[list[path]] <-- $(call list.path.abspath,[list[path]])
#> list.path.realpath    	[list[path]] <-- $(call list.path.realpath,[list[path]])
#> list.path.dir         	[list[path]] <-- $(call list.path.dir,[list[path]])
#> list.path.notdir      	[list[path]] <-- $(call list.path.notdir,[list[path]])
#> list.path.parent      	[list[path]] <-- $(call list.path.parent,[list[path]])
#> list.path.name        	[list[path]] <-- $(call list.path.name,[list[path]])
#> list.path.name.base   	[list[path]] <-- $(call list.path.name.base,[list[path]])
#> list.path.basename    	[list[path]] <-- $(call list.path.basename,[list[path]])
#> list.path.suffix      	[list[path]] <-- $(call list.path.suffix,[list[path]])
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

override list.path.abspath     = $(foreach __path,$1,$(or $(abspath $(__path)),$$e))
override list.path.realpath    = $(foreach __path,$1,$(or $(call word.pack,{path},$(realpath $(call word.unpack,{path},$(__path)))),$$e))
override __list.path.mark      = $(foreach __path,$1,$(call word.join.pair,[path],/,$(if $(__path:/%=),,/)<MARK>/..,$(__path)))
override list.path.dir         = $(foreach __path,$1,$(or $(dir $(__path)),$$e))
override list.path.notdir      = $(foreach __path,$1,$(or $(notdir $(__path)),$$e))
override list.path.parent      = $(foreach __path,$1,$(or $(patsubst %/,%,$(dir $(patsubst %/,%,$(__path)))),$$e))
override list.path.name        = $(foreach __path,$1,$(or $(notdir $(patsubst %/,%,$(__path))),$$e))
override list.path.name.base   = $(foreach __path,$1,$(or $(basename $(notdir $(patsubst %/,%,$(__path)))),$$e))
override list.path.name.suffix = $(foreach __path,$1,$(or $(suffix $(notdir $(patsubst %/,%,$(__path)))),$$e))
override list.path.basename    = $(foreach __path,$1,$(or $(basename $(__path)),$$e))
override list.path.suffix      = $(foreach __path,$1,$(or $(suffix $(__path)),$$e))


#-------------------------------------------------------------------------------
# Path: Prefix/Suffix
#-------------------------------------------------------------------------------
#> path.addprefix        	[path]       <-- $(call path.addprefix,[path],[path:prefix])
#> path.addsuffix        	[path]       <-- $(call path.addsuffix,[path],[path:suffix])
#> list.path.addprefix   	[list[path]] <-- $(call list.path.addprefix,[list[path]],[path:prefix])
#> list.path.addsuffix   	[list[path]] <-- $(call list.path.addsuffix,[list[path]],[path:suffix])
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
#> path.subst                    	[path]       <-- $(call path.subst,[path:in],[path:find],[path:repl])
#> path.patsubst                 	[path]       <-- $(call path.patsubst,[path:in],[path:find],[path:repl])
#> path.patsubst.dir             	[path]       <-- $(call path.patsubst.dir,[path:in],[path:dir],[path:repl])
#> path.patsubst.notdir          	[path]       <-- $(call path.patsubst.notdir,[path:in],[path:notdir],[path:repl])
#> path.patsubst.parent          	[path]       <-- $(call path.patsubst.parent,[path:in],[path:parent],[path:repl])
#> path.patsubst.name            	[path]       <-- $(call path.patsubst.name,[path:in],[path:name],[path:repl])
#> path.patsubst.name.base       	[path]       <-- $(call path.patsubst.name.base,[path:in],[path:name.base],[path:repl])
#> path.patsubst.basename        	[path]       <-- $(call path.patsubst.basename,[path:in],[path:basename],[path:repl])
#> path.patsubst.suffix          	[path]       <-- $(call path.patsubst.suffix,[path:in],[path:suffix],[path:repl])
#> list.path.subst               	[list[path]] <-- $(call list.path.subst,[list[path]:in],[path:find],[path:repl])
#> list.path.patsubst            	[list[path]] <-- $(call list.path.patsubst,[list[path]:in],[path:find],[path:repl])
#> list.path.patsubst.dir        	[list[path]] <-- $(call list.path.patsubst.dir,[list[path]:in],[path:dir],[path:repl])
#> list.path.patsubst.notdir     	[list[path]] <-- $(call list.path.patsubst.notdir,[list[path]:in],[path:notdir],[path:repl])
#> list.path.patsubst.parent     	[list[path]] <-- $(call list.path.patsubst.parent,[list[path]:in],[path:parent],[path:repl])
#> list.path.patsubst.name       	[list[path]] <-- $(call list.path.patsubst.name,[list[path]:in],[path:name],[path:repl])
#> list.path.patsubst.name.base  	[list[path]] <-- $(call list.path.patsubst.name.base,[list[path]:in],[path:name.base],[path:repl])
#> list.path.patsubst.name.suffix	[list[path]] <-- $(call list.path.patsubst.name.suffix,[list[path]:in],[path:name.suffix],[path:repl])
#> list.path.patsubst.basename   	[list[path]] <-- $(call list.path.patsubst.basename,[list[path]:in],[path:basename],[path:repl])
#> list.path.patsubst.suffix     	[list[path]] <-- $(call list.path.patsubst.suffix,[list[path]:in],[path:suffix],[path:repl])
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
override list.path.patsubst             = $(patsubst $(call word.pack,[path],$2),$(call word.pack,[path],$3),$(call list.repack,[path],$1))
override list.path.patsubst.dir         = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(patsubst $(__find),$(__repl),$(call list.path.dir,$(__in))),$(call list.path.notdir,$(__in))))))
override list.path.patsubst.notdir      = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.dir,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.notdir,$(__in)))))))
override list.path.patsubst.parent      = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(patsubst $(__find),$(__repl),$(call list.path.parent,$(__in))),$(call list.path.name,$(__in))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name        = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.name,$(__in)))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name.base   = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.name.base,$(__in)))$(call list.path.name.suffix,$(__in))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.name.suffix = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],/,$(call list.path.parent,$(__in)),$(call list.path.name.base,$(__in))$(patsubst $(__find),$(__repl),$(call list.path.name.suffix,$(__in)))$(and $(filter-out /,$(__in)),$(if $(__in:%/=),,/))))))
override list.path.patsubst.basename    = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],,$(patsubst $(__find),$(__repl),$(call list.path.basename,$(__in))),$(call list.path.suffix,$(__in))))))
override list.path.patsubst.suffix      = $(foreach __find,$(call word.pack,[path],$2),$(foreach __repl,$(call word.pack,[path],$3),$(foreach __in,$(call list.repack,[path],$1),$(call word.join.pair,[path],,$(call list.path.basename,$(__in)),$(patsubst $(__find),$(__repl),$(call list.path.suffix,$(__in)))))))


#-------------------------------------------------------------------------------
# Path: Search
#-------------------------------------------------------------------------------
#> path.wildcard     	[list[path]] <-- $(call path.wildcard,[path:find])
#> list.path.wildcard	[list[path]] <-- $(call list.path.wildcard,[list[path]:find])
#
#	Returns a list of word-packed paths which match the wildcard pattern(s).
#	- Unlike built-in $(wildcard), these functions fully support spaces in both
#	  the input and output paths.
#	- Matches only directories if [find] ends with '/' AND contains a wildcard;
#	  otherwise both files and directories are returned.
#	Returns [empty] if there are no paths matching [find].
#
#	Notes on type [path]:
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
override path.wildcard      = $(call list.path.wildcard,$(call word.pack,[path],$1))
override list.path.wildcard = $(if $1,$(call str.split,{path},$(subst <MARK>/..,,$(subst <MARK>/../,,$(subst /<MARK>/..,,$(subst $s<MARK>/../,<SPLIT>,$(subst $s/<MARK>/..,<SPLIT>,$(wildcard $(foreach __path,$(call __list.path.mark,$1),$(call word.unpack,[path],$(__path))))))))),<SPLIT>))


#-------------------------------------------------------------------------------
# Path: Test Existence
#-------------------------------------------------------------------------------
#> path.exists           	[path]       <-- $(call path.exists,[path])
#> file.exists           	[path]       <-- $(call dir.exists,[path])
#> dir.exists            	[path]       <-- $(call file.exists,[path])
#> list.path.exists      	[list[path]] <-- $(call list.path.exists,[list[path]])
#> list.file.exists      	[list[path]] <-- $(call list.dir.exists,[list[path]])
#> list.dir.exists       	[list[path]] <-- $(call list.file.exists,[list[path]])
#
#	Returns [path] if it exists (and is a file/directory/either).
#	Functions which accept [list[path]] set each nonexistant path to packed-[empty].
#
#-------------------------------------------------------------------------------
#	[word[path]] <-- $(call __list.filter.*,[word[path]],[list[path]])
override __list.filter.path = $(if $(filter $1,$2),$1,$$e)
override __list.filter.dir  = $(if $(filter $(1:%/=%)/,$2),$1,$$e)
override __list.filter.file = $(if $(and $(if $(filter $(1:%/=%)/,$2),,T),$(filter $1,$2)),$1,$$e)

override path.exists = $(__list.path.op)
override dir.exists  = $(__list.path.op)
override file.exists = $(__list.path.op)
override list.path.exists = $(call list.map.1,,__list.filter.path,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $$e,$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))
override list.dir.exists  = $(call list.map.1,,__list.filter.dir,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $$e,$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))
override list.file.exists = $(call list.map.1,,__list.filter.file,$(call list.repack,[path],$1),$(call list.path.wildcard,$(foreach __path,$(call list.repack,[path],$1),$(if $(filter-out $$e,$(__path)),$(__path:%/=%)$s$(__path:%/=%)/))))


#-------------------------------------------------------------------------------
#> multipath.create 	[multipath] <-- $(call multipath.create,$n\
#>                  	                  /path/to a/file.1	$n\
#>                  	                  path/to a/dir/	$n\
#>                  	                )
#
#	Convenience method for manual [multipath] definition.
#	Splits the second argument on {tab} and {lf}, encoding each section as a word-packed [path],
#	then merges the resulting list into a [multipath] string.
#	- Each line must end with '$n\'.
#	- Leading whitespace is removed. Trailing {space} is kept. Trailing {tab} and {lf} are removed.
#-------------------------------------------------------------------------------
override multipath.create = $(call word.unpack,{path},$(call list.format,{path},$1))




#------------------------------------------------------------------------------------------------#
# {digit/carry} <-- $(call __digit.add,[digit:A],[digit:A],[0|1:C])
# {digit/carry} <-- $(call __digit.sub,[digit:B],[digit:B],[0|1:C])
#                     __digit.add                                  __digit.sub                   #
#                     ((A+C)+B)/C                                  ((A-C)-B)/C                   #
#     B: 0   1   2   3   4   5   6   7   8   9       B: 0   1   2   3   4   5   6   7   8   9    #
# A+C:                                           A-C:                                            #
#   0   0/0 1/0 2/0 3/0 4/0 5/0 6/0 7/0 8/0 9/0   -1   9/1 8/1 7/1 6/1 5/1 4/1 3/1 2/1 1/1 0/1   #
#   1   1/0 2/0 3/0 4/0 5/0 6/0 7/0 8/0 9/0 0/1    0   0/0 9/1 8/1 7/1 6/1 5/1 4/1 3/1 2/1 1/1   #
#   2   2/0 3/0 4/0 5/0 6/0 7/0 8/0 9/0 0/1 1/1    1   1/0 0/0 9/1 8/1 7/1 6/1 5/1 4/1 3/1 2/1   #
#   3   3/0 4/0 5/0 6/0 7/0 8/0 9/0 0/1 1/1 2/1    2   2/0 1/0 0/0 9/1 8/1 7/1 6/1 5/1 4/1 3/1   #
#   4   4/0 5/0 6/0 7/0 8/0 9/0 0/1 1/1 2/1 3/1    3   3/0 2/0 1/0 0/0 9/1 8/1 7/1 6/1 5/1 4/1   #
#   5   5/0 6/0 7/0 8/0 9/0 0/1 1/1 2/1 3/1 4/1    4   4/0 3/0 2/0 1/0 0/0 9/1 8/1 7/1 6/1 5/1   #
#   6   6/0 7/0 8/0 9/0 0/1 1/1 2/1 3/1 4/1 5/1    5   5/0 4/0 3/0 2/0 1/0 0/0 9/1 8/1 7/1 6/1   #
#   7   7/0 8/0 9/0 0/1 1/1 2/1 3/1 4/1 5/1 6/1    6   6/0 5/0 4/0 3/0 2/0 1/0 0/0 9/1 8/1 7/1   #
#   8   8/0 9/0 0/1 1/1 2/1 3/1 4/1 5/1 6/1 7/1    7   7/0 6/0 5/0 4/0 3/0 2/0 1/0 0/0 9/1 8/1   #
#   9   9/0 0/1 1/1 2/1 3/1 4/1 5/1 6/1 7/1 8/1    8   8/0 7/0 6/0 5/0 4/0 3/0 2/0 1/0 0/0 9/1   #
#  10   0/1 1/1 2/1 3/1 4/1 5/1 6/1 7/1 8/1 9/1    9   9/0 8/0 7/0 6/0 5/0 4/0 3/0 2/0 1/0 0/0   #
#------------------------------------------------------------------------------------------------#
override __digit.add = $(word 1$(or $2,0),x x x x x x x x x $(wordlist $(word 1$(or $1,0),$(if $(3:0=),,x) x x x x x x x x 1 2 3 4 5 6 7 8 9 10 11),20,0/0 1/0 2/0 3/0 4/0 5/0 6/0 7/0 8/0 9/0 0/1 1/1 2/1 3/1 4/1 5/1 6/1 7/1 8/1 9/1))
override __digit.sub = $(word 1$(or $2,0),x x x x x x x x x $(wordlist $(word 1$(or $1,0),$(if $(3:0=),x,) x x x x x x x x 11 10 9 8 7 6 5 4 3 2 1),20,9/0 8/0 7/0 6/0 5/0 4/0 3/0 2/0 1/0 0/0 9/1 8/1 7/1 6/1 5/1 4/1 3/1 2/1 1/1 0/1))



#-------------------------------------------------------------------------------
#> digits.add       	{list{digit|-}} = $(call digits.add,[list{digit|-}:A],[list{digit|-}:B])
#> digits.sub       	{list{digit|-}} = $(call digits.sub,[list{digit|-}:A],[list{digit|-}:B])
#-------------------------------------------------------------------------------
#                                                            | (-)+(-) = -(|A|+|B|)               | (-)+(+) = |B|-|A|                                     | (+)+(-) = |A|-|B|                | (+)+(+) = ...             add each pair of digits, starting with the rightmost digit, until empty or only leading 0s remain                  extract carry                 | result: strip carry              | if leftmost carry=1, carry the 1.
override digits.add = $(if $(filter -,$1),$(if $(filter -,$2),- $(call digits.add,$(1:-=),$(2:-=)),$(call digits.sub,$(2:-=),$(1:-=))),$(if $(filter -,$2),$(call digits.sub,$(1:-=),$(2:-=)),$(if $(filter-out 0,$1 $2),$(call $0,$(call list.remove.last,$1),$(call list.remove.last,$2),$(call __digit.add,$(lastword $1),$(lastword $2),$(notdir $(firstword $3))) $3),$(patsubst %/0,%,$(patsubst %/1,%,$(if $(filter %/1,$(firstword $3)),1 $3,$(or $3,0)))))))
#                                                            | (-)-(-) = |B|-|A|                  | (-)-(+) = -(|A|+|B|)                                  | (+)-(-) = |A|+|B|                | (+)-(+) = ...             sub each pair of digits, starting with the rightmost digit, until empty or only leading 0s remain                  extract carry                 | result: strip carry              | if leftmost carry=1, then |A|<|B|, so redo calculation as -(|B|-|A|)
override digits.sub = $(if $(filter -,$1),$(if $(filter -,$2),$(call digits.sub,$(2:-=),$(1:-=)),- $(call digits.add,$(1:-=),$(2:-=))),$(if $(filter -,$2),$(call digits.add,$(1:-=),$(2:-=)),$(if $(filter-out 0,$1 $2),$(call $0,$(call list.remove.last,$1),$(call list.remove.last,$2),$(call __digit.sub,$(lastword $1),$(lastword $2),$(notdir $(firstword $3))) $3),$(patsubst %/0,%,$(patsubst %/1,%,$(if $(filter %/1,$(firstword $3)),- $(call $0,1 $(3:%=0),$(patsubst %/0,%,$(3:%/1=%))),$(or $(call list.filter-out.start,$3,0/%),0)))))))



#-------------------------------------------------------------------------------
#> int.trim         	{int} <-- $(call int.trim,[int])
#> int.add          	{int} <-- $(call int.add,[int:A],[int:B])
#> int.sub          	{int} <-- $(call int.sub,[int:A],[int:B])
#> int.max          	{int} <-- $(call int.max,[int:A],[int:B])
#> int.min          	{int} <-- $(call int.min,[int:A],[int:B])
#> int.abs          	{int} <-- $(call int.abs,[int])
#> int.neg          	{int} <-- $(call int.neg,[int])
#> int.equ.0        	[bool] <-- $(call int.equ.0,[int])
#> int.neq.0        	[bool] <-- $(call int.neq.0,[int])
#> int.gtr.0        	[bool] <-- $(call int.gtr.0,[int])
#> int.geq.0        	[bool] <-- $(call int.geq.0,[int])
#> int.leq.0        	[bool] <-- $(call int.leq.0,[int])
#> int.lss.0        	[bool] <-- $(call int.lss.0,[int])
#> int.equ          	[bool] <-- $(call int.equ,[int:A],[int:B])
#> int.neq          	[bool] <-- $(call int.neq,[int:A],[int:B])
#> int.gtr          	[bool] <-- $(call int.gtr,[int:A],[int:B])
#> int.geq          	[bool] <-- $(call int.geq,[int:A],[int:B])
#> int.leq          	[bool] <-- $(call int.leq,[int:A],[int:B])
#> int.lss          	[bool] <-- $(call int.lss,[int:A],[int:B])
#-------------------------------------------------------------------------------
override int.trim  = $(and $(subst 0,,$(subst -,,$1)),$(findstring -,$1),-)$(or $(subst $s,,$(call list.filter-out.start,$(subst 0,0$s,$(subst -,,$1)),0)),0)

override int.add   = $(subst $s,,$(call $(0:int.%=digits.%),$(call chars.split,int,$1),$(call chars.split,int,$2)))
override int.sub   = $(subst $s,,$(call $(0:int.%=digits.%),$(call chars.split,int,$1),$(call chars.split,int,$2)))
override int.max   = $(or $(if $(call int.gtr,$1,$2),$1,$2),0)
override int.min   = $(or $(if $(call int.lss,$1,$2),$1,$2),0)
override int.abs   = $(subst -,,$(call int.trim,$1))
override int.neg   = $(foreach int,$(call int.trim,$1),$(if $(findstring -,$(int)),$(int:-%=%),$(int)))

override int.equ.0 = $(filter     0   ,$(call int.trim,$1))
override int.neq.0 = $(filter-out 0   ,$(call int.trim,$1))
override int.gtr.0 = $(filter-out 0 -%,$(call int.trim,$1))
override int.geq.0 = $(filter-out   -%,$(call int.trim,$1))
override int.leq.0 = $(filter     0 -%,$(call int.trim,$1))
override int.lss.0 = $(filter       -%,$(call int.trim,$1))

override int.equ   = $(filter     $(call int.trim,$2),$(call int.trim,$1))
override int.neq   = $(filter-out $(call int.trim,$2),$(call int.trim,$1))
override int.gtr   = $(filter-out 0 -%,$(call int.sub,$1,$2))
override int.geq   = $(filter-out   -%,$(call int.sub,$1,$2))
override int.leq   = $(filter     0 -%,$(call int.sub,$1,$2))
override int.lss   = $(filter       -%,$(call int.sub,$1,$2))





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
# {name}.next = $(eval {name} := $(if $(filter-out [end],$({name})),$(call int.add,$({name}),1)))$({name})
override iter.inc.define = $(eval $1 := $(or $2,0))$(eval $1.next = $$(eval $1 := $$(if $$(filter-out $3,$$($1)),$$(call int.add,$$($1),1)))$$($1))
#===============================================================================






#===============================================================================
# EXPRESSIONS, DYNAMIC PROGRAMMING
#===============================================================================

#-----------------------------------------------------------
# [str]         	<-- $(call expr.expand,[expr])
# [expr]        	<-- $(call expr.assign,[list[expr]:directives],[expr[var]:name],[expr:assign_operator],[expr:value])
# [expr]        	<-- $(call expr.str,[str])
# [list[expr]]  	<-- $(call expr.list,[list[str]])
# [expr]        	<-- $(call expr.var,[expr[var]:name],[expr[word]:find],[expr[str]:repl])
# [list[expr]]  	<-- $(call expr.vars,[list[var]])
# [expr]        	<-- $(call expr.builtin,{expr[builtin]:name},[expr:arg1],[expr:arg2],...)
# [expr]        	<-- $(call expr.call,{expr[func]:name},[expr:arg1],[expr:arg2],...)
# [expr]        	<-- $(call expr.if,[expr:cond],[expr:ifnonempty],[expr:ifempty])
# [expr]        	<-- $(call expr.or,[expr:1],[expr:2],...)
# [expr]        	<-- $(call expr.and,[expr:1],[expr:2],...)
# [expr]        	<-- $(call expr.foreach,[expr[var]],[expr[list]:in],[expr[str](var)])
# [expr]        	<-- $(call expr.subst,[expr:from],[expr:to],[expr([str:in])])
# [expr]        	<-- $(call expr.strip,[expr([str:in])])
# [expr]        	<-- $(call expr.target,[expr[multipath]:targets],\
#               	        [expr[multipath]:prereqs],[expr[multipath]:orderonly],\
#               	        [expr[multipath]:prereqs_of],[expr[multipath]:orderonly_of],\
#               	        [list[expr]:assignments],\
#               	        [list[expr]:commands]
#               	    )
# [expr]        	<-- $(call expr.target,$(call multipath.create,$n\
#               	            /target/multipath$n\
#               	        ),$(call multipath.create,$n\
#               	            /prereq/multipath$n\
#               	        ),$(call multipath.create,$n\
#               	            /orderonly/multipath$n\
#               	        ),$(call multipath.create,$n\
#               	            /prereqs/of$n\
#               	        ),$(call multipath.create,$n\
#               	            /orderonly/of$n\
#               	        ),$(call list.format,expr,$n\
#               	            localvar := value$n\
#               	        ),$(call list.format,expr,$n\
#               	            commands$n\
#               	        )\
#               	    )
#-----------------------------------------------------------
override expr.expand  = $(eval override $0.tmp := $$e$1$$e)$($0.tmp)$(eval override $0.tmp :=)
override expr.assign  = $(if $2,$(call str.concat.pair,$n,$(call str.concat,$s,$(filter-out define,$1),$(if $(findstring $n,$4),define),$2,$(or $3,=),$(findstring $n,$4)$4),$(if $(findstring $n,$4),endef)))
override expr.str     = $(call word.pack,{str},$1)
override expr.list    = $(foreach word,$1,$(call word.pack,expr,$(call expr.str,$(call word.unpack,str,$(word)))))
override expr.var     = $(if $2$3,$$($1:$2=$3),$(if $(call var.is.shortname,$1),$$$1,$$($1)))
override expr.vars    = $(foreach word,$1,$(call word.pack,expr,$(call expr.var,$(call word.unpack,var,$(word)))))
override expr.builtin = $(if $1,$$($1 $(call expr.builtin,,$2,$3,$4,$5,$6,$7,$8,$9)),$(if $(or $3,$4,$5,$6,$7,$8,$9),$2$c$(call expr.builtin,,$3,$4,$5,$6,$7,$8,$9),$2))
override expr.call    = $(call expr.builtin,call,$1,$2,$3,$4,$5,$6,$7,$8,$9)
override expr.if      = $(call expr.builtin,if,$1,$2,$3)
override expr.or      = $(call expr.builtin,or,$1,$2,$3,$4,$5,$6,$7,$8,$9)
override expr.and     = $(call expr.builtin,and,$1,$2,$3,$4,$5,$6,$7,$8,$9)
override expr.foreach = $(call expr.builtin,foreach,$1,$2,$3)
override expr.subst   = $(call expr.builtin,subst,$1,$2,$3)
override expr.strip   = $(call expr.builtin,strip,$1)
override expr.target  = $(if $1,$n$(call __$0,$1,$2,$3,$4,$5,$(call list.prune,expr,$6),$(call list.prune,expr,$7)))
override define __expr.target
$(if $4,$4: $1)
$(if $5,$5: | $1)
$(if $6,$(call list.merge,expr,$(addprefix $(call word.pack,expr,$1:$s),$6),$n))
$1:$(if $2, $2)$(if $3, | $3)
$(if $7,$(or $(.RECIPEPREFIX),$t)$(call list.merge,expr,$7,$n$(or $(.RECIPEPREFIX),$t)))
$n
endef



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
shell.run  = $(if $1,$(if $3,$(call shell.push,$3,$4))$(shell $1)$(call make.exit.if.badshell,,,$1)$(call var.set,,$2,int,$(.SHELLSTATUS))$(if $3,$(call shell.pop)))
shell.test = $(if $1,$(if $3,$(call shell.push,$3,$4))$(call var.set,,$2,str,$(shell $1))$(call make.exit.if.badshell,,,$1)$(filter 0,$(.SHELLSTATUS))$(if $3,$(call shell.pop)))




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


str := this is$na multiline$nstring

# print.tee     	[str] <-- $(call print.tee,type,)
override print.val = $(call )


$(info $e)
$(info $(call str.format))
$(info $e)
$(error )

# file.tee      	[str] <-- $(call file.tee,[>>|>],[path],[str])
override file.tee = $(if $2,$(file $(or $1,>>) $2,$3))$3


COLOR_GREEN=\033[0;32m
COLOR_RED=\033[0;31m
COLOR_BLUE=\033[0;34m
COLOR_END=\033[0m

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



# msg.trace                 	[word[str]] <-- $(msg.trace)
# msg.trace                 	[str] <-- $(call msg.trace,[str:trace])
#
# msg.block                 	[str] <-- $(call msg.block,[str:header],[str:body])
# msg.info.variables        	[str] <-- $(call msg.info.variables,[str:title],[list[var]])
# msg.info.variables        	[str] <-- $(call msg.info.variables,[list[var]])
# msg.info.command          	[str] <-- $(call msg.info.command,[str:title],[str:trace],[str:subject],[str:details],[list[var]:print])
#
# msg.error                 	[str] <-- $(call str.trace,[str:title],[str:trace],[str:subject],[str:details],[list[var]:print])
# msg.error.value           	[str] <-- $(call msg.error.value,[str:trace],[str:label],[str:value],[str:details],[list[var]:print])
# msg.error.argument        	[str] <-- $(call msg.error.argument,[str:trace],[idx:argnum],[str:value],[str:details],[list[var]:print])
# msg.error.variable        	[str] <-- $(call msg.error.variable,[str:trace],[var],[str:details],[list[var]:print])
# msg.error.file            	[str] <-- $(call msg.error.file,[str:trace],[file:path],[str:details],[list[var]:print])
# msg.error.shell           	[str] <-- $(call msg.error.shell,[str:trace],[str:command],[str:details],[list[var]:print])
#
# assert.value.empty        	[empty] <-- $(call assert.empty,[str:label],[str:value],[str:details],[str:trace])
# assert.value.nonempty     	[empty] <--
# assert.value.is.word      	[empty] <--
# assert.value.var.is.nonempty    	[empty] <--
#
#-------------------------------------------------------------------------------
# [str] <-- $(error.prefix)          Error message line prefix
# [str] <-- $(line.indent)          Error message line indentation
#

override msg.block                 = $(if $1,$(if $(strip $1),$1$n$(call str.indent.add,$2,$s$s),$n$2),$2)


override msg.trace                 = $(if $(filter msg.trace,$0),$(if $(or $@,$(strip $1)),$(call str.indent.add,$(call str.concat,$n,$(if $@,Target: $@),$(if $(strip $1),$(call word.unpack,{line},$(subst $s,$n,$(strip $1)))))-->$s)),$(call word.pack,{line},$(if $0,$x(call $0))))

override msg.error                 = $(call str.concat,$n,$(or $1,Error),$(call msg.trace,$2),$(if $3,$3),$(if $4,$(call str.indent.add,$4,$s$s)),$(if $5,$(call str.indent.add,$5,$s$s)))
override msg.error.value           = $(call msg.error,$1 $(msg.trace),$(or $(strip $2),Value) = [$3]$(if $4,:$n$(call str.indent.add,$4,$s$s)),$5)
override msg.error.argument        = $(call msg.error.value,$1 $(msg.trace),Invalid argument$(if $2,$s$x$2),$3,$4,$5)
override msg.error.variable        = $(call msg.error.value,$1 $(msg.trace),Invalid $(if $2,$s$x($2)),$($2),$3,$4)
override msg.error.file            = $(call msg.error.value,$1 $(msg.trace),File Error,$3,$4)
override msg.error.shell           = $(call msg.error.value,$1 $(msg.trace),Shell,$3,$4)


# $(ASSERT_LEVEL)
# [empty] <-- $(call _assert.failed,{word:errortype},$(str.trace),[args]...)
override _assert.failed            = $(call $(or $(ASSERT_LEVEL),error),$n$(call msg.error.$1,$2 $(str.trace),$3,$4,$5,$6,$7,$8,$9)$n)
override assert.value.empty        = $(if $1,$(call assert,$(true),$2,$x(call),),)
override assert.value.nonempty     = $(if $1,,$(error $(call msg.error.var.empty,$0,1)))
override assert.var.has.words      = $(if $(strip $1),,$(error $(call msg.error.var.nowords,$0,1)))
override assert.var.is.line        = $(if $(findstring $n,$1),$(error $(call msg.error.var.multiline,$0,1)))
override assert.var.is.word        = $(if $(filter-out 1,$(words $1)),$(error $(call msg.error.var.multiword,$0,1)))

#-------------------------------------------------------------------------------
# assert.shell.success 	[empty] <-- $(call make.exit.if.badshell,[path:shell],[str:flags],[str:command])
#-------------------------------------------------------------------------------
#	Exits Make with an error message if $(MAKE_EXIT_IF_BADSHELL) is [true],
#	and either:
#	- The most recent recipe command or $(shell) invocation failed to start due to
#	  an improperly specified SHELL or .SHELLFLAGS.
#	- The value of $(SHELL) is invalid
#-------------------------------------------------------------------------------
override assert.shell.success = $(if $(filter       0,$(.SHELLSTATUS)),,$(throw Failed to start shell process:$n  SHELL       = [$(or $1,$(SHELL))]$n  .SHELLFLAGS = [$(or $2,$(.SHELLFLAGS))]$(if $3,$n  Command:      [$3])$n$n))
override assert.shell.started = $(if $(filter-out 127,$(.SHELLSTATUS)),,$(error Failed to start shell process:$n  SHELL       = [$(or $1,$(SHELL))]$n  .SHELLFLAGS = [$(or $2,$(.SHELLFLAGS))]$(if $3,$n  Command:      [$3])$n$n))
override assert.shell.started = $(and $1,$(call str.neq,$(basename $(SHELL)),$(basename $1),/i))
