#===============================================================================
# lib.generics.mak
#
# Advanced expression generators.
# Adds build targets for each expression definition of the form:
#
#		[expr] <-- $(call expr...<T>...,{type:T})
#
# where '<T>' is each type defined as:
#
#		list[char] <--  $(char.<T>)
#
# Usage:
#
# 	make -f .project/make/lib.generics.mak generics
#
#===============================================================================
ifeq "$(filter lib.mak,$(notdir $(MAKEFILE_LIST)))" ""
include $(or $(lib.path),$(dir $(lastword $(MAKEFILE_LIST)))/lib.mak)
endif
#===============================================================================


# Type Definitions ==================== type: list{char}
override char.{str}      := $(char.lowers) $(char.uppers) $(char.digits) $(char.whitespace) $(char.symbols)
override char.{line}     := $(char.lowers) $(char.uppers) $(char.digits) $$s $$t            $(char.symbols)
override char.{list}     := $(char.lowers) $(char.uppers) $(char.digits) $$s                $(char.symbols)
override char.{word}     := $(char.lowers) $(char.uppers) $(char.digits)                    $(char.symbols)
override char.{alphanum} := $(char.lowers) $(char.uppers) $(char.digits)
override char.{alpha}    := $(char.lowers) $(char.uppers)
override char.{int}      :=                               $(char.digits)                    + -
override char.{uint}     :=                               $(char.digits)                    +
override char.{digit}    :=                               $(char.digits)
override char.{bool}     := t r u e
override char.{var}      := $(char.lowers) $(char.uppers) $(char.digits) $(char.whitespace) $(filter-out : =,$(char.symbols))
override char.{path}     := $(char.lowers) $(char.uppers) $(char.digits) $$s                $(filter-out < > | & ",$(char.symbols))
override char.{char}     := $(char.{str})
override char.{expr}     := $(char.{str})
override char.{idx}      := $(char.{uint})
override char.{origin}   := $(char.{list})
override char.{flavor}   := $(char.{alpha})
override char.{type}     := $(char.{word})


#-----------------------------------------------------------
# [expr[str]([str:in])] <-- $(call expr.subst.expr2expr,[expr[str]([str:in])],[expr[str]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.expr2str,[expr[str]([str:in])],[expr[str]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.expr2var,[expr[str]([str:in])],[expr[str]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.str2expr,[expr[str]([str:in])],[str:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.str2str,[expr[str]([str:in])],[str:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.str2var,[expr[str]([str:in])],[str:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.var2expr,[expr[str]([str:in])],[var:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.var2str,[expr[str]([str:in])],[var:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.var2var,[expr[str]([str:in])],[var:from],[var:to])

# [expr[str]([str:in])] <-- $(call expr.subst.exprs2expr,[expr[str]([str:in])],[list[expr[str]]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2str,[expr[str]([str:in])],[list[expr[str]]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2var,[expr[str]([str:in])],[list[expr[str]]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2expr,[expr[str]([str:in])],[list[str]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2str,[expr[str]([str:in])],[list[str]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2var,[expr[str]([str:in])],[list[str]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2expr,[expr[str]([str:in])],[list[var]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2str,[expr[str]([str:in])],[list[var]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2var,[expr[str]([str:in])],[list[var]:from],[var:to])

# [expr[str]([str:in])] <-- $(call expr.subst.exprs2exprs,[expr[str]([str:in])],[list[expr[str]]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2list,[expr[str]([str:in])],[list[expr[str]]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.exprs2vars,[expr[str]([str:in])],[list[expr[str]]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2exprs,[expr[str]([str:in])],[list[str]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2list,[expr[str]([str:in])],[list[str]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.list2vars,[expr[str]([str:in])],[list[str]:from],[var:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2exprs,[expr[str]([str:in])],[list[var]:from],[expr[str]:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2list,[expr[str]([str:in])],[list[var]:from],[str:to])
# [expr[str]([str:in])] <-- $(call expr.subst.vars2vars,[expr[str]([str:in])],[list[var]:from],[var:to])
#-----------------------------------------------------------
#
# Generates an `eval`-uatable expression which performs one or more `subst`-itutions in series.
# 'expr[str]' is an expression which expands to a [str]. It may contain any combination of the following:
#             - Variable varerences: '$v', '$(var)', '${var}', '$(var:[word:find]=[str:repl])', etc.
#               Use `expr.var` to generate a variable varerence.
#             - Function Calls:      '$({builtin} [arg:1],...)', '$(call {func},[arg:1],...)'
#               Use `expr.call` to generate a function call.
#             - Literal Strings: strants embedded in an expression. Must abide by the following rules
#               to ensure correct parsing:
#               - Literals may not contain whitespace; use variable varerences '$s', '$t', '$n' instead.
#               - Literals may not contain unpaired '{', '}', '(', ')'; use '$j', '$k', '$l', '$r' instead.
#               - Literals may not contain ','; use '$c' instead.
#               - Literals may not contain '#'; use '$g' instead.
#               - Literals may not end with '\'; use '$b' instead.
#-----------------------------------------------------------
override expr.subst.expr2expr   = $(if $(subst $$e,,$2),$(call expr.subst,$2,$3,$1),$(call expr.or,$1,$3))
override expr.subst.expr2str    = $(call expr.subst.expr2expr,$1,$2,$(call expr.str,$3))
override expr.subst.expr2var    = $(call expr.subst.expr2expr,$1,$2,$(call expr.var,$3))
override expr.subst.str2expr    = $(call expr.subst.expr2expr,$1,$(call expr.str,$2),$3)
override expr.subst.str2str     = $(call expr.subst.expr2expr,$1,$(call expr.str,$2),$(call expr.str,$3))
override expr.subst.str2var     = $(call expr.subst.expr2expr,$1,$(call expr.str,$2),$(call expr.var,$3))
override expr.subst.var2expr    = $(call expr.subst.expr2expr,$1,$(call expr.var,$2),$3)
override expr.subst.var2str     = $(call expr.subst.expr2expr,$1,$(call expr.var,$2),$(call expr.str,$3))
override expr.subst.var2var     = $(call expr.subst.expr2expr,$1,$(call expr.var,$2),$(call expr.var,$3))

override expr.subst.exprs2expr  = $(if $(and $1,$(firstword $2)),$(call expr.subst.expr2expr,$(call $0,$1,$(wordlist 2,$(words $2),x $2),$3),$(call word.unpack,expr,$(lastword $2)),$3),$1)
override expr.subst.exprs2str   = $(call expr.subst.exprs2expr,$1,$2,$(call expr.str,$3))
override expr.subst.exprs2var   = $(call expr.subst.exprs2expr,$1,$2,$(call expr.var,$3))
override expr.subst.list2expr   = $(call expr.subst.exprs2expr,$1,$(call expr.list,$2),$3)
override expr.subst.list2str    = $(call expr.subst.exprs2expr,$1,$(call expr.list,$2),$(call expr.str,$3))
override expr.subst.list2var    = $(call expr.subst.exprs2expr,$1,$(call expr.list,$2),$(call expr.var,$3))
override expr.subst.vars2expr   = $(call expr.subst.exprs2expr,$1,$(call expr.vars,$2),$3)
override expr.subst.vars2str    = $(call expr.subst.exprs2expr,$1,$(call expr.vars,$2),$(call expr.str,$3))
override expr.subst.vars2var    = $(call expr.subst.exprs2expr,$1,$(call expr.vars,$2),$(call expr.var,$3))

override expr.subst.exprs2exprs = $(if $(and $1,$(firstword $2),$(firstword $3)),$(call expr.subst.expr2expr,$(call $0,$1,$(wordlist 2,$(words $2),x $2),$(wordlist 2,$(words $3),x $3)),$(call word.unpack,expr,$(lastword $2)),$(call word.unpack,expr,$(lastword $3))),$1)
override expr.subst.exprs2list  = $(call expr.subst.exprs2exprs,$1,$2,$(call expr.list,$3))
override expr.subst.exprs2vars  = $(call expr.subst.exprs2exprs,$1,$2,$(call expr.vars,$3))
override expr.subst.list2exprs  = $(call expr.subst.exprs2exprs,$1,$(call expr.list,$2),$3)
override expr.subst.list2list   = $(call expr.subst.exprs2exprs,$1,$(call expr.list,$2),$(call expr.list,$3))
override expr.subst.list2vars   = $(call expr.subst.exprs2exprs,$1,$(call expr.list,$2),$(call expr.vars,$3))
override expr.subst.vars2exprs  = $(call expr.subst.exprs2exprs,$1,$(call expr.vars,$2),$3)
override expr.subst.vars2list   = $(call expr.subst.exprs2exprs,$1,$(call expr.vars,$2),$(call expr.list,$3))
override expr.subst.vars2vars   = $(call expr.subst.exprs2exprs,$1,$(call expr.vars,$2),$(call expr.vars,$3))



#-----------------------------------------------------------
# [expr[str]] <-- $(call expr.strip.list,[expr[str]:in],[list[str]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.strip.vars,[expr[str]:in],[list[var]:strip],[list[var]:noescape])
# [expr[str]] <-- $(call expr.cull.list,[expr[str]:in],[list[str]:cull],[list[var]:noescape])
# [expr[str]] <-- $(call expr.cull.vars,[expr[str]:in],[list[var]:cull],[list[var]:noescape])
# [expr[str]] <-- $(call expr.strip.ws,[expr[str]:in],[list[var]:ws])
#-----------------------------------------------------------
# [expr[word]] <-- $(call __expr.strip.pre,[expr[str]:in],[list[var]:noescape])
# [expr[str]]  <-- $(call __expr.strip.post,[expr[word]:in],[list[var]:noescape])
# [expr[word]] <-- $(call __expr.strip.expr,[expr[word]:in],[expr[word]:strip])
# [expr[word]] <-- $(call __expr.strip.str,[expr[word]:in],[str:strip],[list[var]:noescape])
override __expr.strip.pre   = $(call expr.subst.vars2vars,$1,$(filter-out $(subst %,\%,$2),x s t n),$(addprefix x,$(filter-out $(subst %,\%,$2),x s t n)))
override __expr.strip.post  = $(call expr.subst.vars2vars,$1,$(addprefix x,$(filter-out $(subst %,\%,$2),n t s x)),$(filter-out $(subst %,\%,$2),n t s x))
override __expr.strip.expr  = $(if $(and $1,$2),$(if $(call expr.expand,$2),$$(subst$s$$s$c$2$c$$(strip$s$$(subst$s$2$c$$s$c$1))),$1),$1)
override __expr.strip.str = $(call __expr.strip.expr,$1,$(call word.pack,word,$(call str.subst.vars2vars,$2,$(filter-out $(subst %,\%,$3),x s t n),$(addprefix x,$(filter-out $(subst %,\%,$3),x s t n)))))

override expr.strip.list  = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$(call list.reduce.1,str,__expr.strip.str,$(call __expr.strip.pre,$1,$3),$2,$3),$3),$1)
override expr.strip.vars    = $(call expr.strip.list,$1,$(foreach var,$2,$(call word.pack,expr,$($(var)))),$3)
override expr.cull.list   = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$$(subst $$xe$c$c$(call list.reduce.1,str,__expr.strip.str,$$xe$(call __expr.strip.pre,$1,$3)$$xe,$2,$3)),$3),$1)
override expr.cull.vars     = $(call expr.cull.list,$1,$(foreach var,$2,$(call word.pack,expr,$($(var)))),$3)
override expr.strip.ws      = $(if $(and $1,$(firstword $2)),$(call __expr.strip.post,$$(strip $(call __expr.strip.pre,$1,$2)),$2),$1)




#-------------------------------------------------------------------------------
# word.pack.<T>         	[word<T>] <-- $(call word.pack.<T>,[T:val])
# expr.word.pack.<T>    	[expr<word<T>>([T:val])] <-- $(call expr.word.pack.<T>,[type:T],[expr:$1])
#-------------------------------------------------------------------------------
override expr.word.pack.<T> = $(strip $(foreach T,$1, \
	$(null Define local variables) \
	$(call var.set,override,$0.locals,{str},$0.locals $0.1 $0.expand $0.normal) \
	\
	$(call var.set,override,$0.1,{str},$(or $2,$$1)) \
	$(call var.set,override,$0.expand,{str},$(filter $$x,$(char.$T)) $(sort $(filter-out $$x $$e,$(filter $$%,$(char.$T)))) $(filter $$e,$(char.$T))) \
	$(call var.set,override,$0.normal,{str},$(sort $(filter-out $$%,$(char.$T)))) \
	\
	$(null Produce expression) \
	$(subst $$x,$$$$,$(call expr.subst.list2list,$($0.1),$($0.expand),$(call word.pack,{word},$($0.expand)))) \
	\
	$(null Cleanup local variables) \
	$(foreach var,$($0.locals),$(call var.set,override,$(var),{str},$e)) \
))

# Type-Specific Overrides ------------------------------------------------------
override expr.word.pack.{int}    = $(call expr.subst,+,,$(call expr.word.pack.<T>,$1,$2))
override expr.word.pack.{uint}   = $(call $(if $2,expr.call,expr.var),word.pack.{int},$2)
override expr.word.pack.{idx}    = $(call $(if $2,expr.call,expr.var),word.pack.{int},$2)
override expr.word.pack.{char}   = $(call $(if $2,expr.call,expr.var),word.pack.{str},$2)
override expr.word.pack.{expr}   = $(call $(if $2,expr.call,expr.var),word.pack.{str},$2)
override expr.word.pack.{origin} = $(call $(if $2,expr.call,expr.var),word.pack.{list},$2)
override expr.word.pack.{flavor} = $(call $(if $2,expr.call,expr.var),word.pack.{alpha},$2)
override expr.word.pack.{type}   = $(call $(if $2,expr.call,expr.var),word.pack.{word},$2)
override expr.word.pack.{path}   = $(strip \
	$(call expr.subst.list2list,$(call expr.strip,$(call expr.subst.list2list,$(call expr.word.pack.<T>,$1,$2),\
		$$b      \\    \[   \]   \$$s    $$s  \   $$t   $$n    / 	,\
		  \  $$b$$b  $$b[ $$b] $$b$$s $$b$$s  /  $$xt  $$xn  $$s 	 \
	)), \
		$$s  $$xn  $$xt 	,\
		  /   $$n   $$t 	\
	) \
)




#-------------------------------------------------------------------------------
# word.unpack.<T>       	[T:val] <-- $(call word.unpack.<T>,[word<T>])
# expr.word.unpack.<T>  	[expr<T:val>([word<T>])] <-- $(call expr.word.unpack.<T>,{type:T},[expr<word<T>>([word[T]]):$1])
#-------------------------------------------------------------------------------
override expr.word.unpack.<T> = $(strip $(foreach T,$1, \
	$(null Define local variables) \
	$(call var.set,override,$0.locals,{str},$0.locals $0.1 $0.expand $0.normal) \
	\
	$(call var.set,override,$0.1,{str},$(or $2,$$1)) \
	$(call var.set,override,$0.expand,{str},$(filter $$x,$(char.$T)) $(sort $(filter-out $$x $$e,$(filter $$%,$(char.$T)))) $(filter $$e,$(char.$T))) \
	$(call var.set,override,$0.normal,{str},$(sort $(filter-out $$%,$(char.$T)))) \
	\
	$(null Produce expression) \
	$(subst $$x,$$$$,$(call expr.subst.list2list,$($0.1),$(call list.reverse,$(call word.pack,{word},$($0.expand))),$(call list.reverse,$($0.expand)))) \
	\
	$(null Cleanup local variables) \
	$(foreach var,$($0.locals),$(call var.set,override,$(var),{str},$e)) \
))

# Type-Specific Overrides ------------------------------------------------------
override expr.word.unpack.{char}   = $(call $(if $2,expr.call,expr.var),word.unpack.{str},$2)
override expr.word.unpack.{expr}   = $(call $(if $2,expr.call,expr.var),word.unpack.{str},$2)
override expr.word.unpack.{idx}    = $(call $(if $2,expr.call,expr.var),word.unpack.{int},$2)
override expr.word.unpack.{origin} = $(call $(if $2,expr.call,expr.var),word.unpack.{list},$2)
override expr.word.unpack.{flavor} = $(call $(if $2,expr.call,expr.var),word.unpack.{alpha},$2)
override expr.word.unpack.{type}   = $(call $(if $2,expr.call,expr.var),word.unpack.{word},$2)




#-------------------------------------------------------------------------------
# chars.split.<T>       	[list<char>] <-- $(call chars.split.<T>,[T:val])
# expr.chars.split.<T>  	[expr<list<char>>([T:val])] <-- $(call expr.chars.split.<T>,{type:T},[expr<T>([T:val]):$1])
#-------------------------------------------------------------------------------
override expr.chars.split.<T> = $(strip $(foreach T,$1, \
	$(null Define local variables) \
	$(call var.set,override,$0.locals,{str},$0.locals $0.1 $0.expand $0.normal) \
	\
	$(call var.set,override,$0.1,{str},$(or $2,$$1)) \
	$(call var.set,override,$0.expand,{str},$(filter $$x,$(char.$T)) $(sort $(filter-out $$x $$e,$(filter $$%,$(char.$T)))) $(filter $$e,$(char.$T))) \
	$(call var.set,override,$0.normal,{str},$(sort $(filter-out $$%,$(char.$T)))) \
	\
	$(null Produce expression) \
	$(call expr.strip,$(subst $$x,$$$$,$(call expr.subst.list2list,$(call expr.call,word.pack.$T,$($0.1)),$(call word.pack,{word},$($0.expand) $($0.normal)),$(addsuffix $$s,$(call word.pack,{word},$($0.expand) $($0.normal)))))) \
	\
	$(null Cleanup local variables) \
	$(foreach var,$($0.locals),$(call var.set,override,$(var),{str},$e)) \
))

# Type-Specific Overrides ------------------------------------------------------
override expr.chars.split.{digit}  = $(or $2,$$1)
override expr.chars.split.{char}   = $(or $2,$$1)
override expr.chars.split.{expr}   = $(call $(if $2,expr.call,expr.var),chars.split.{str},$2)
override expr.chars.split.{idx}    = $(call $(if $2,expr.call,expr.var),chars.split.{int},$2)
override expr.chars.split.{origin} = $(call $(if $2,expr.call,expr.var),chars.split.{list},$2)
override expr.chars.split.{flavor} = $(call $(if $2,expr.call,expr.var),chars.split.{alpha},$2)
override expr.chars.split.{type}   = $(call $(if $2,expr.call,expr.var),chars.split.{word},$2)






#===============================================================================
# TARGETS
#===============================================================================



override generics.header  := $g$s<lib.generics.mak>
override generics.footer  := $g$s<\lib.generics.mak>
override generics.types   := $(strip $(foreach T,$(patsubst char.%,%,$(sort $(filter char.{%} char.[%],$(.VARIABLES)))),$(if $(T:[%]=),$T $(if $(char.$(T:{%}=[%])),$(T:{%}=[%])),$(if $(char.$(T:[%]={%})),,$T))))
override generics.targets := $(strip $(foreach V,$(patsubst expr.%,%,$(filter expr.%,$(.VARIABLES))),$(if $(findstring <T>,$V),$V)))

.PHONY: generics generics.header generics.footer $(generics.targets) $(subst <T>,%,$(generics.targets))
generics: generics.file := .project/make/lib.generics.local.mak
generics: | generics.header $(generics.targets) generics.footer
generics.header:
	$(info $(call file.tee,>,$(generics.file),$($@)))
generics.footer:
	$(info $(call file.tee,>>,$(generics.file),$($@)))
override define expr.generics.target
$1: | $$(foreach T,$$(generics.types),$$(subst <T>,$$T,$1))
	$$(info $$(call file.tee,>>,$$(generics.file),$$e))
$(subst <T>,%,$1):
	$$(info $$(call file.tee,>>,$$(generics.file),$$(call expr.assign,override,$$@,=,$$(call $$(or $$(filter expr.$$@,$$(.VARIABLES)),expr.$$(subst $$*,<T>,$$@)),$$*))))
endef
$(foreach target,$(generics.targets),$(eval $(call expr.generics.target,$(target))))

