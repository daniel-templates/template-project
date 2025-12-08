#===============================================================================
# lib.tests.mak
#
# Tests function definitions in 'lib.common.mak'.
#
# Usage:
#
# 	make -f .project/make/lib.tests.mak ["tests=..."]
#
#===============================================================================
.PHONY: $(notdir $(lastword $(MAKEFILE_LIST)))
ifeq "$(filter lib.common.mak,$(notdir $(MAKEFILE_LIST)))" ""
include $(or $(lib.path),$(dir $(lastword $(MAKEFILE_LIST)))/lib.common.mak)
endif
#===============================================================================

ifndef tests
tests := %
endif

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
ifneq "$(filter $(tests),var.is.shortname var.is.defined var.is.undefined var.is.environment var.is.commandline var.is.makefile var.is.internal var.is.ws var.is.nonws var.is.empty var.is.def.empty var.is.nonempty)" ""

vars    := s x char.comma PATH $$ ns ( \ \# e xp % SHELL %stupid%
$(info $e)
$(info $e================================================)
$(info $e vars                = [$(strip $(vars))])
$(foreach func,\
var.is.shortname___\
var.is.defined_____\
var.is.undefined___\
var.is.environment_\
var.is.commandline_\
var.is.makefile____\
var.is.internal____\
var.is.ws__________\
var.is.nonws_______\
var.is.empty_______\
var.is.def.empty___\
var.is.nonempty____\
,\
$(info $e $(subst _,$s,$(func)) = [$(foreach var,$(vars),$(or $(call $(subst _,,$(func)),$(var)),$(call str.subst.list2str,$(var),$(char.vars),$s)))])\
)
$(info $e)

endif

#-------------------------------------------------------------------------------
# var.set       	[empty] <-- $(call var.set,[directives],[var],[type:T],[T:val])
# var.append    	[empty] <-- $(call var.append,[directives],[var],[type:T],[T:val])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),var.set var.append)" ""

var := original value
new := thi$$ i$$$na $$tring

$(info $e)
$(info $e  var.append)
$(info $e==================================)
$(info $e var       = [$(var)])
$(info $e new       = [$(new)])
$(info $e var.append --> [$(call var.append,,var,str,$(new))])
$(info $e var       = [$(var)])
$(info $e)
$(info $e  var.set)
$(info $e==================================)
$(info $e var       = [$(var)])
$(info $e new       = [$(new)])
$(info $e var.set --> [$(call var.set,,var,str,$(new))])
$(info $e var       = [$(var)])
$(info $e)

endif

#-------------------------------------------------------------------------------
# var.push        	[empty] <-- $(call var.push,[var],[type:T],[T:val])
# var.pop         	[empty] <-- $(call var.pop,[var])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),var.push var.pop)" ""

var := Original Value
val1  := $$(call func,$$1,$$2)
type1 :=
val2  := this$$ i$$ a $$tring
type2 := str

$(info $e)
$(info $e $$(flavor var)   = [$(flavor var)])\
$(info $e $$(var)          = [$(var)])\
$(info $e $$(value var)    = [$(value var)])\
$(info $e stack            = [$(var.var.stack)])
$(info $e)
$(foreach i,1 2,\
	$(info $e var.push)$(call var.push,var,$(type$i),$(val$i))\
	$(info $e===========================================)\
	$(info $e new             = [$(val$i)])\
	$(info $e type            = [$(type$i)])\
	$(info $e $$(flavor var)   = [$(flavor var)])\
	$(info $e $$(var)          = [$(var)])\
	$(info $e $$(value var)    = [$(value var)])\
	$(info $e stack            = [$(var.var.stack)])\
	$(info $e)\
)
$(info $e)
$(info $e $$(flavor var)   = [$(flavor var)])\
$(info $e $$(var)          = [$(var)])\
$(info $e $$(value var)    = [$(value var)])\
$(info $e stack            = [$(var.var.stack)])
$(info $e)
$(foreach i,2 1,\
	$(info $e var.pop)$(call var.pop,var)\
	$(info $e===========================================)\
	$(info $e $$(flavor var)   = [$(flavor var)])\
	$(info $e $$(var)          = [$(var)])\
	$(info $e $$(value var)    = [$(value var)])\
	$(info $e stack            = [$(var.var.stack)])\
	$(info $e)\
)

endif

#-------------------------------------------------------------------------------
# str.split         	[list[T]] <-- $(call str.split,[type:T],[str],[str:sep])
# list.merge        	[str]     <-- $(call list.merge,[type:T],[list[T]],[str:sep])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),str.split list.merge)" ""

str1 := thi$$ i$$  a  $$tring
$(info $e)
$(info $e)
$(foreach strv, str1 empty,\
$(foreach sepv, char.space char.dollar empty,\
$(foreach type, {str} [str],\
$(info $e)\
$(info $e  type=$(type), sep='$($(sepv))')\
$(info $e==================================)\
$(info $estr       =[$($(strv))])\
$(info $estr.split =[$(call str.split,$(type),$($(strv)),$($(sepv)))])\
$(info $elist.merge=[$(call list.merge,$(type),$(call str.split,$(type),$($(strv)),$($(sepv))),$($(sepv)))])\
$(info $e)\
)))
$(info $e)

endif
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# list.prune        	[list[T]] <-- $(call list.prune,[type:T],[list[T]])
# list.repack       	[list[T]] <-- $(call list.repack,[type:T],[list[T]])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),list.prune list.repack)" ""

list := $(call word.pack,[str],)
list += $(call word.pack,[str],)$(call word.pack,[str],string 1)$(call word.pack,[str],)
list += $(call word.pack,[str],string 2)
list += $(call word.pack,[str],)
$(info $e)
$(info $elist   = [$(list)])
$(info $e)
$(info $etrim   = [$(call list.prune,[str],$(list))])
$(info $e)
$(info $erepack = [$(call list.repack,[str],$(list))])
$(info $e)

endif
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# list.filter           	[list[T]] <-- $(call list.filter,[type:T],[list[T]],[T:val])
# list.filter-out       	[list[T]] <-- $(call list.filter-out,[type:T],[list[T]],[T:val])
# list.filter-out.start 	[list]    <-- $(call list.filter-out.start,[list:in],[list:filter-out])
# list.filter-out.end   	[list]    <-- $(call list.filter-out.end,[list:in],[list:filter-out])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),list.filter list.filter-out list.filter-out.start list.filter-out.end)" ""

list  := 1 1 2 3 4 3 2 1 1
filt  := 2 1
start := $(call list.filter-out.start,$(list),$(filt))
end   := $(call list.filter-out.end,$(list),$(filt))
$(info $e)
$(info $e list  = [$(list)])
$(info $e filt  = [$(filt)])
$(info $e start = [$(start)])
$(info $e end   = [$(end)])
$(info $e)

endif


#-----------------------------------------------------------
# str.map           	[str] <-- $(call str.map.{N},[type:T],
# str.map.1         	              [func[T]([T:1],...,[T:N],[str:const1],...)],
# str.map.2         	              [str:sep],
# str.map.3         	              [str:1],...,[str:N],
# str.map.4         	              [str:const1],...)
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),str.map)" ""

str := this is$n a multiline  $n string! $n
func = LINE:<$(strip $1)>
res := $(call str.map,line,func,$n,$(str))
$(info )
$(info str = [$(str)])
$(info res = [$(res)])
$(info )

endif


#-------------------------------------------------------------------------------
# str.strip.var         	[str] <-- $(call str.strip.var,[str:in],[var:strip])
# str.strip.var.start   	[str] <-- $(call str.strip.var.start,[str:in],[str:strip])
# str.strip.var.end     	[str] <-- $(call str.strip.var.end,[str:in],[str:strip])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),str.strip.var str.strip.var.start str.strip.var.end)" ""

in    := $s$s<$$tr  ing>$s$s
strip := s
start := $(call str.strip.var.start,$(in),$(strip))
end   := $(call str.strip.var.end,$(in),$(strip))

$(info $e)
$(info $e in    = [$(in)])
$(info $e strip = [$(strip)])
$(info $e start = [$(start)])
$(info $e end   = [$(end)])
$(info $e)

endif


#-------------------------------------------------------------------------------
# str.treesubst.list2list     	[str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),str.treesubst.list2list)" ""

in   := <string>
find := i < >
repl := <i> << >>
str.subst     := $(call str.subst.list2list,$(in),$(find),$(repl))
str.treesubst := $(call str.treesubst.list2list,$(in),$(find),$(repl))
$(info $e)
$(info $e in        = [$(in)])
$(info $e find      = [$(find)])
$(info $e repl      = [$(repl)])
$(info $e subst     = [$(str.subst)])
$(info $e treesubst = [$(str.treesubst)])
$(info $e)

endif



#-------------------------------------------------------------------------------
# list.path.abspath     	[list[path]] <-- $(call list.path.abspath,[list[path]])
# list.path.realpath    	[list[path]] <-- $(call list.path.realpath,[list[path]])
# list.path.dir         	[list[path]] <-- $(call list.path.dir,[list[path]])
# list.path.notdir      	[list[path]] <-- $(call list.path.notdir,[list[path]])
# list.path.parent      	[list[path]] <-- $(call list.path.parent,[list[path]])
# list.path.name        	[list[path]] <-- $(call list.path.name,[list[path]])
# list.path.name.base   	[list[path]] <-- $(call list.path.name.base,[list[path]])
# list.path.basename    	[list[path]] <-- $(call list.path.basename,[list[path]])
# list.path.suffix      	[list[path]] <-- $(call list.path.suffix,[list[path]])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),list.path.dir list.path.notdir list.path.parent list.path.name list.path.name.base list.path.basename list.path.suffix)" ""

paths :=
paths := $(call list.append,path,$(paths),/abspath\to/dir name.suffix/)
paths := $(call list.append,path,$(paths),relpath\to/dir name.suffix/)
paths := $(call list.append,path,$(paths),/abspath\to/file name.suffix)
paths := $(call list.append,path,$(paths),relpath\to/file name.suffix)
paths := $(call list.append,path,$(paths),////)
paths := $(call list.append,path,$(paths),../)
paths := $(call list.append,path,$(paths),..)
paths := $(call list.append,path,$(paths),./)
paths := $(call list.append,path,$(paths),.)
paths := $(call list.append,path,$(paths),$e)
$(info $e)
$(info $elist = [$(paths)])
$(info $e)
$(foreach path,$(paths),\
	$(info $e)\
	$(info $e===================================)\
	$(info $epath      = [$(call word.unpack,[path],$(path))])\
	$(info $eabspath   = [$(call word.unpack,[path],$(call list.path.abspath,$(path)))])\
	$(info $erealpath  = [$(call word.unpack,[path],$(call list.path.realpath,$(path)))])\
	$(info $emark      = [$(call word.unpack,[path],$(call __list.path.mark,$(path)))])\
	$(info $e)\
	$(foreach func, dir-------- notdir----- parent----- name------- name.base-- name.suffix basename--- suffix-----,\
	$(info $e$(subst -,$s,$(func)) = [$(call word.unpack,[path],$(call list.path.$(subst -,,$(func)),$(path)))])\
	)\
	$(info $e)\
	$(foreach func, dir-------- notdir----- parent----- name------- name.base-- name.suffix basename--- suffix-----,\
	$(info $epatsubst.$(subst -,$s,$(func)) = [$(call word.unpack,[path],$(call list.path.patsubst.$(subst -,,$(func)),$(path),%,<$(call str.upper,$(subst -,,$(func)))>))])\
	)\
	$(info $e)\
)
$(info $e)

endif



#-------------------------------------------------------------------------------
# list.path.wildcard	[list[path]] <-- $(call list.path.wildcard,[list[path.pattern]:find])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),list.path.wildcard)" ""

paths :=
paths := $(call list.append,[path.pattern],$(paths),/*)
paths := $(call list.append,[path.pattern],$(paths),/*/)
paths := $(call list.append,[path.pattern],$(paths),../*)
paths := $(call list.append,[path.pattern],$(paths),./*)
paths := $(call list.append,[path.pattern],$(paths),*)
paths := $(call list.append,[path.pattern],$(paths),*/)
paths := $(call list.append,[path.pattern],$(paths),src/*)
paths := $(call list.append,[path.pattern],$(paths),src/*/*)
paths := $(call list.append,[path.pattern],$(paths),.project/)
paths := $(call list.append,[path.pattern],$(paths),.project/*)
paths := $(call list.append,[path.pattern],$(paths),notapath)
paths := $(call list.append,[path.pattern],$(paths),)
$(info $e)
$(foreach path,$(paths),\
$(info $e)\
$(info $epath=[$(call word.unpack,[path.pattern],$(path))])\
$(info $e============================================)\
$(info $ewildcard = [$(call list.path.wildcard,$(path))])\
$(info $e)\
)
$(info $e)

endif


#-------------------------------------------------------------------------------
# path.exists           	[path]       <-- $(call path.exists,[path])
# file.exists           	[path]       <-- $(call dir.exists,[path])
# dir.exists            	[path]       <-- $(call file.exists,[path])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),path.exists file.exists dir.exists)" ""

paths :=
paths := $(call list.append,[path],$(paths),.project)
paths := $(call list.append,[path],$(paths),.project/)
paths := $(call list.append,[path],$(paths),makefile)
paths := $(call list.append,[path],$(paths),makefile/)
paths := $(call list.append,[path],$(paths),notapath)
paths := $(call list.append,[path],$(paths),/)
paths := $(call list.append,[path],$(paths),.)
paths := $(call list.append,[path],$(paths),..)
paths := $(call list.append,[path],$(paths),)
$(info $e)
$(foreach path,$(paths),\
$(info $e)\
$(info $epath=[$(call word.unpack,[path],$(path))])\
$(info $e============================================)\
$(info $epath.exists = [$(call path.exists,$(call word.unpack,[path],$(path)))])\
$(info $efile.exists = [$(call file.exists,$(call word.unpack,[path],$(path)))])\
$(info $edir.exists  = [$(call dir.exists,$(call word.unpack,[path],$(path)))])\
$(info $e)\
)
$(info $e)

endif



#-------------------------------------------------------------------------------
# paths.format       	[paths] <-- $(call paths.format,$n\
#                   	                  /path/to a/file.1	$n\
#                   	                  path/to a/dir/	$n\
#                   	            )
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),paths.format)" ""

$(info $e)
$(info $e $(call paths.make,$n\
	path/to/a file.1	$n\
	path/to/a file.2	$n\
))
$(info $e)

endif


#-------------------------------------------------------------------------------
# [expr]    <-- $(call expr.var,[expr[var]:name],[expr[word.pattern]:find],[expr[str.pattern]:repl])
# [expr]    <-- $(call expr.builtin,[expr[builtin]:name],[list[expr]:args])
# [expr]    <-- $(call expr.call,[expr[func]:name],[list[expr]:args])
# [expr]    <-- $(call expr.assign,[list[expr]:directives],[expr[var]:name],[expr:assign_operator],[expr:value])
# [expr]    <-- $(call expr.target,[expr[paths]:targets],\
#                   [expr[paths]:prereqs],[expr[paths]:orderonly],\
#                   [expr[paths]:prereqs_of],[expr[paths]:orderonly_of],\
#                   [list[expr]:assignments],\
#                   [list[expr]:commands]
#               )
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),expr.var expr.builtin expr.call expr.assign expr.target)" ""

str := //a\very, $$trange//(path)//

word.pack.type   := path
word.pack.val    := $(str)

expr.var.name     := 1
expr.var.find     := $(call word.pack,word.pattern,$$%)
expr.var.repl     := $(call word.pack,str.pattern,$$<%>)

expr.builtin.name := subst
expr.builtin.args += $(call word.pack,expr,$(call word.pack,str,$c$s))
expr.builtin.args += $(call word.pack,expr,$(call word.pack,str,$e))
expr.builtin.args += $(call word.pack,expr,$$1)

expr.call.name    := subst
expr.call.args    += $(call word.pack,expr,$(call word.pack,str,$c$s))
expr.call.args    += $(call word.pack,expr,$(call word.pack,str,$e))
expr.call.args    += $(call word.pack,expr,$$1)

expr.assign.name  := var
expr.assign.directives += $(call word.pack,expr,$(call word.pack,str,define))
expr.assign.directives += $(call word.pack,expr,$(call word.pack,str,override))
expr.assign.operator :=
expr.assign.value := this is$na multiline$nvalue

expr.target.targets      += $(call word.pack,path.pattern,file 1.tgt)
expr.target.targets      += $(call word.pack,path.pattern,file 2.tgt)
expr.target.prereqs      += $(call word.pack,path.pattern,prereq 1.tgt)
expr.target.prereqs      += $(call word.pack,path.pattern,prereq 2.tgt)
expr.target.orderonly    += $(call word.pack,path.pattern,orderonly.tgt)
expr.target.prereqs_of   += $(call word.pack,path.pattern,parent.tgt)
expr.target.orderonly_of += $(call word.pack,path.pattern,.PHONY)
expr.target.assignments  += $(call word.pack,expr,var1 = value1)
expr.target.assignments  += $(call word.pack,expr,var2 = value2)
expr.target.commands     += $(call word.pack,expr,$(call expr.builtin,info,$(call word.pack,expr,$(call word.pack,str,Target = )[$(call expr.var,@)])))
expr.target.commands     += $(call word.pack,expr,python.exe "$(call expr.var,^)")

$(info $e)
$(info $e  word.pack)
$(info $e==============================================)
expr := $(call word.pack,$(word.pack.type),$(word.pack.val))
$(info $e type = [$(word.pack.type)])
$(info $e val  = [$(word.pack.val)])
$(info $e expr = [$(expr)])
$(info $e)
$(info $e    --> [$(eval func = $(expr))$(call func)])
$(info $e)
$(info $e  expr.var)
$(info $e==============================================)
expr := $(call expr.var,$(expr.var.name),$(expr.var.find),$(expr.var.repl))
$(info $e name = [$(expr.var.name)])
$(info $e find = [$(expr.var.find)])
$(info $e repl = [$(expr.var.repl)])
$(info $e expr = [$(expr)])
$(info $e)
$(info $e str  = [$(str)])
$(info $e    --> [$(eval func = $(expr))$(call func,$(str))])
$(info $e)
$(info $e  expr.builtin)
$(info $e==============================================)
expr := $(call expr.builtin,$(expr.builtin.name),$(expr.builtin.args))
$(info $e name = [$(expr.builtin.name)])
$(info $e args = [$(expr.builtin.args)])
$(info $e expr = [$(expr)])
$(info $e)
$(info $e str  = [$(str)])
$(info $e    --> [$(eval func = $(expr))$(call func,$(str))])
$(info $e)
$(info $e  expr.call)
$(info $e==============================================)
expr := $(call expr.call,$(expr.call.name),$(expr.call.args))
$(eval func = $(expr))
$(info $e name = [$(expr.call.name)])
$(info $e args = [$(expr.call.args)])
$(info $e expr = [$(expr)])
$(info $e)
$(info $e str  = [$(str)])
$(info $e    --> [$(eval func = $(expr))$(call func,$(str))])
$(info $e)
$(info $e  expr.assign)
$(info $e==============================================)
expr := $(call expr.assign,$(expr.assign.directives),$(expr.assign.name),$(expr.assign.operator),$(expr.assign.value))
$(info $e name       = [$(expr.assign.name)])
$(info $e directives = [$(expr.assign.directives)])
$(info $e expr       = [$(expr)])
$(info $e          --> [$(eval $(expr))$($(expr.assign.name))])
$(info $e)
$(info $e  expr.target)
$(info $e==============================================)
expr := $(call expr.target,$(expr.target.targets),$(expr.target.prereqs),$(expr.target.orderonly),$(expr.target.prereqs_of),$(expr.target.orderonly_of),$(expr.target.assignments),$(expr.target.commands))
$(info $e targets      = [$(expr.target.targets)])
$(info $e prereqs      = [$(expr.target.prereqs)])
$(info $e orderonly    = [$(expr.target.orderonly)])
$(info $e prereqs_of   = [$(expr.target.prereqs_of)])
$(info $e orderonly_of = [$(expr.target.orderonly_of)])
$(info $e assignments  = [$(expr.target.assignments)])
$(info $e commands     = [$(expr.target.commands)])
$(info $e expr         = [$(expr)])
$(info $e)

endif



#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),name)" ""

str    := //thi$$$$//i$$$$  a//$$$$tring//
from   := $$
to     := ,

$(info $e)
$(info $e str  = [$(str)])
$(info $e from = [$(from)])
$(info $e to   = [$(to)])
$(info $e)
$(info $e const2const = [$(eval expr := $$(call expr.subst.const2const$c$$$$1$c$$(from)$c$$(to)))$(expr)])
$(info $e   str       = [$(str)])
$(info $e   eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e const2ref   = [$(eval expr := $$(call expr.subst.const2ref$c$$$$1$c$$(from)$cto))$(expr)])
$(info $e   str       = [$(str)])
$(info $e   eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e ref2const   = [$(eval expr := $$(call expr.subst.ref2const$c$$$$1$cfrom$c$$(to)))$(expr)])
$(info $e   str       = [$(str)])
$(info $e   eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e ref2ref     = [$(eval expr := $$(call expr.subst.ref2ref$c$$$$1$cfrom$cto))$(expr)])
$(info $e   str       = [$(str)])
$(info $e   eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e)

str    := //thi$$$$//i$$$$  a//$$$$tring//
from.1 := $$
from.2 := /
to     := ,

$(info $e)
$(info $e str  = [$(str)])
$(info $e from = [$(from.1) $(from.2)])
$(info $e to   = [$(to)])
$(info $e)
$(info $e consts2const = [$(eval expr := $$(call expr.subst.consts2const$c$$$$1$c$$(from.1)$s$$(from.2)$c$$(to)))$(expr)])
$(info $e    str       = [$(str)])
$(info $e    eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e consts2var   = [$(eval expr := $$(call expr.subst.consts2ref$c$$$$1$c$$(from.1)$s$$(from.2)$cto))$(expr)])
$(info $e    str       = [$(str)])
$(info $e    eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e refs2const   = [$(eval expr := $$(call expr.subst.refs2const$c$$$$1$cfrom.1$sfrom.2$c$$(to)))$(expr)])
$(info $e    str       = [$(str)])
$(info $e    eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e refs2var     = [$(eval expr := $$(call expr.subst.refs2ref$c$$$$1$cfrom.1$sfrom.2$cto))$(expr)])
$(info $e    str       = [$(str)])
$(info $e    eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e)

str    := //thi$$$$//i$$$$  a//$$$$tring//
from.1 := $$
from.2 := /
to.1   := ,
to.2   := \$e

$(info $e)
$(info $e str  = [$(str)])
$(info $e from = [$(from.1) $(from.2)])
$(info $e to   = [$(to.1) $(to.2)])
$(info $e)
$(info $e consts2consts = [$(eval expr := $$(call expr.subst.consts2consts$c$$$$1$c$$(from.1)$s$$(from.2)$c$$(to.1)$s$$(to.2)))$(expr)])
$(info $e     str       = [$(str)])
$(info $e     eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e consts2refs   = [$(eval expr := $$(call expr.subst.consts2refs$c$$$$1$c$$(from.1)$s$$(from.2)$cto.1$sto.2))$(expr)])
$(info $e     str       = [$(str)])
$(info $e     eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e refs2consts   = [$(eval expr := $$(call expr.subst.refs2consts$c$$$$1$cfrom.1$sfrom.2$c$$(to.1)$s$$(to.2)))$(expr)])
$(info $e     str       = [$(str)])
$(info $e     eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e refs2refs     = [$(eval expr := $$(call expr.subst.refs2refs$c$$$$1$cfrom.1$sfrom.2$cto.1$sto.2))$(expr)])
$(info $e     str       = [$(str)])
$(info $e     eval      = [$(eval func = $(expr))$(call func,$(str))])
$(info $e)


endif




#-------------------------------------------------------------------------------
# expr.strip.consts     	 [expr[str]] <-- $(call expr.strip.consts,[expr[str]:in],[list[str]:strip],[list[var]:noescape])
# expr.strip.vars       	 [expr[str]] <-- $(call expr.strip.vars,[expr[str]:in],[list[var]:strip],[list[var]:noescape])
# expr.cull.consts      	 [expr[str]] <-- $(call expr.cull.consts,[expr[str]:in],[list[str]:strip],[list[var]:noescape])
# expr.cull.vars        	 [expr[str]] <-- $(call expr.cull.vars,[expr[str]:in],[list[var]:strip],[list[var]:noescape])
# expr.strip.ws         	 [expr[str]] <-- $(call expr.strip.ws,[expr[str]:in],[list[var]:ws])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),expr.strip.consts expr.strip.vars expr.cull.consts expr.cull.vars expr.strip.ws)" ""

str    := //thi$$$$//i$$$$  a//$$$$tring//
vars   := f e x s
consts := $(foreach var,$(vars),$(call word.pack,str,$($(var))))
noescape := n t
$(info $e)
$(info $e  expr.strip.consts)
$(info $e================================================)
$(eval func = $(call expr.strip.consts,$$1,$(consts),$(noescape)))
$(info $e str          = [$(str)])
$(info $e consts       = [$(consts)])
$(info $e noescape     = [$(noescape)])
$(info $e strip.consts = [$(value func)])
$(info $e            --> [$(call func,$(str))])
$(info $e)
$(info $e)
$(info $e  expr.strip.vars)
$(info $e================================================)
$(eval func = $(call expr.strip.vars,$$1,$(vars),$(noescape)))
$(info $e str          = [$(str)])
$(info $e vars         = [$(vars)])
$(info $e noescape     = [$(noescape)])
$(info $e strip.vars   = [$(value func)])
$(info $e            --> [$(call func,$(str))])
$(info $e)
$(info $e  expr.cull.consts)
$(info $e================================================)
$(eval func = $(call expr.cull.consts,$$1,$(consts),$(noescape)))
$(info $e str          = [$(str)])
$(info $e consts       = [$(consts)])
$(info $e noescape     = [$(noescape)])
$(info $e cull.consts  = [$(value func)])
$(info $e            --> [$(call func,$(str))])
$(info $e)
$(info $e  expr.cull.vars)
$(info $e================================================)
$(eval func = $(call expr.cull.vars,$$1,$(vars),$(noescape)))
$(info $e str          = [$(str)])
$(info $e vars         = [$(vars)])
$(info $e noescape     = [$(noescape)])
$(info $e cull.vars    = [$(value func)])
$(info $e            --> [$(call func,$(str))])
$(info $e)
str    := $t$t<--tabs,$s$s$s$s<--spaces
ws     := t
$(info $e)
$(info $e  expr.strip.ws)
$(info $e================================================)
$(eval func = $(call expr.strip.ws,$$1,$(ws)))
$(info $e str          = [$(str)])
$(info $e ws           = [$(ws)])
$(info $e strip.ws     = [$(value func)])
$(info $e            --> [$(call func,$(str))])
$(info $e)

endif



#-------------------------------------------------------------------------------
# shell.push    	[empty] <-- $(call shell.push,[path:shell],[str:flags])
# shell.pop     	[empty] <-- $(call shell.pop)
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),shell.push shell.pop)" ""


$(info $e)
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)

$(info $e  shell.push)
$(info $e======================================================)
$(info $e var.SHELL.stack = [$(var.SHELL.stack)])
$(call shell.push,$(if $(findstring Windows_NT,$(OS)),asdf.exe,python),-q -c)
$(info $(shell print("If you can read this, Make is using Python as the Shell")))
$(info $e var.SHELL.stack = [$(var.SHELL.stack)])
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e var.SHELL.stack = [$(var.SHELL.stack)])
$(info $e)
$(info $e  shell.pop)
$(info $e======================================================)
$(info $e var.SHELL.stack = [$(var.SHELL.stack)])
$(call shell.pop)
$(info $e var.SHELL.stack = [$(var.SHELL.stack)])
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)

endif


#-------------------------------------------------------------------------------
# shell.run     	[str:stdout]   <-- $(call shell.run,[str:command],[var:exitcode],[path:shell],[str:shellflags])
# shell.test    	[bool:success] <-- $(call shell.test,[str:command],[var:stdout],[path:shell],[str:shellflags])
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),shell.run shell.test)" ""

path  := $(if $(findstring Windows_NT,$(OS)),python.exe,python)
flags := -q -c
command_success := import sys; print("Exiting python with code 0"); sys.exit(0)
command_failure := import sys; print("Exiting python with code 1"); sys.exit(1)

$(info $e)
$(info $e  shell.run)
$(info $e====================================)
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)
$(info $e Running with shell: $(path) $(flags) $$(command_success))
$(info $e   stdout   = [$(call shell.run,$(command_success),exitcode,$(path),$(flags))])
$(info $e   exitcode = [$(exitcode)])
$(info $e)
$(info $e Running with shell: $(path) $(flags) $$(command_failure))
$(info $e   stdout   = [$(call shell.run,$(command_failure),exitcode,$(path),$(flags))])
$(info $e   exitcode = [$(exitcode)])
$(info $e)
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)
$(info $e)
$(info $e  shell.test)
$(info $e====================================)
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)
$(info $e Running with shell: $(path) $(flags) $$(command_success))
$(info $e   status   = [$(if $(call shell.test,$(command_success),stdout,$(path),$(flags)),SUCCESS,FAILURE)])
$(info $e   stdout   = [$(stdout)])
$(info $e)
$(info $e Running with shell: $(path) $(flags) $$(command_failure))
$(info $e   status   = [$(if $(call shell.test,$(command_failure),stdout,$(path),$(flags)),SUCCESS,FAILURE)])
$(info $e   stdout   = [$(stdout)])
$(info $e)
$(info $e SHELL       = [$(SHELL)])
$(info $e.SHELLFLAGS  = [$(.SHELLFLAGS)])
$(info $e.SHELLSTATUS = [$(.SHELLSTATUS)])
$(info $e)

endif




#-------------------------------------------------------------------------------
# str.error
#-------------------------------------------------------------------------------
ifneq "$(filter $(tests),str.error assert)" ""

$(info $e)
$(info $e  str.error)
$(info $e====================================)
$(info $e$(call str.error,$(str.trace),Error Line 1$nError Line 2$nError Line 3))
$(info $e)
$(info $e)
$(info $e  assert)
$(info $e====================================)
$(info $e$(call assert,variable,,SHELL,An error has occurred))
$(info $e)

endif


#-------------------------------------------------------------------------------
# str.to.block
# block.to.str
#-------------------------------------------------------------------------------

ifneq "$(filter $(tests),str.to.block block.to.str)" ""

str1 := $nline1$nline  2$n
str2 := $n
str3 :=
pad := .

$(foreach V,str1 str2 str3,\
	$(info $e)\
	$(info str = [$(subst $n,$v$n$s$s$s$s$s$s$u,$($V))])\
	$(info $e)\
	$(info <-- = [$(subst $n,$v$n$s$s$s$s$s$s$u,$(call str.to.block,str,$($V),$(pad),left))])\
	$(info <-- = [$(subst $n,$v$n$s$s$s$s$s$s$u,$(call block.to.str,$(call str.to.block,str,$($V),$(pad),left)))])\
	$(info $e)\
	$(info --> = [$(subst $n,$v$n$s$s$s$s$s$s$u,$(call str.to.block,str,$($V),$(pad),right))])\
	$(info --> = [$(subst $n,$v$n$s$s$s$s$s$s$u,$(call block.to.str,$(call str.to.block,str,$($V),$(pad),right)))])\
	$(info $e)\
)
$(info $e)

endif


#-------------------------------------------------------------------------------
# block.hresize
# block.vresize
#-------------------------------------------------------------------------------

ifneq "$(filter $(tests),block.hresize block.vresize)" ""

str1 := 1..$n2.$n3
str2 := A$nB.
str3 := $n
str4 :=
pad  := .
blk1 := $(call str.to.block,str,$(str1),$(pad))
blk2 := $(call str.to.block,str,$(str2),$(pad))
blk3 := $(call str.to.block,str,$(str3),$(pad))
blk4 := $(call str.to.block,str,$(str4),$(pad))

$(info $e)
$(info $eBlocks)
$(info $e)
$(info blk1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk1)))])
$(info $e)
$(info blk2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk2)))])
$(info $e)
$(info blk3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk3)))])
$(info $e)
$(info blk4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk4)))])
$(info $e)
$(info $eHRESIZE)
$(info $e)
$(info w2,1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk2),$(blk1),$(pad),resize)))])
$(info $e)
$(info w1,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk1),$(blk2),$(pad),resize)))])
$(info $e)
$(info w1,3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk1),$(blk3),$(pad),resize)))])
$(info $e)
$(info w1,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk1),$(blk4),$(pad),resize)))])
$(info $e)
$(info w1,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk1),       ,$(pad),resize)))])
$(info $e)
$(info w3,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk3),$(blk2),$(pad),resize)))])
$(info $e)
$(info w3,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk3),$(blk4),$(pad),resize)))])
$(info $e)
$(info w4,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk4),$(blk2),$(pad),resize)))])
$(info $e)
$(info w4,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk4),$(blk4),$(pad),resize)))])
$(info $e)
$(info w4,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,$(blk4),       ,$(pad),resize)))])
$(info $e)
$(info w ,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hresize,       ,       ,$(pad),resize)))])
$(info $e)
$(info $eVRESIZE)
$(info $e)
$(info h2,1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk2),$(blk1),$(pad),resize)))])
$(info $e)
$(info h1,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk1),$(blk2),$(pad),resize)))])
$(info $e)
$(info h1,3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk1),$(blk3),$(pad),resize)))])
$(info $e)
$(info h1,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk1),$(blk4),$(pad),resize)))])
$(info $e)
$(info h1,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk1),       ,$(pad),resize)))])
$(info $e)
$(info h3,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk3),$(blk2),$(pad),resize)))])
$(info $e)
$(info h3,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk3),$(blk4),$(pad),resize)))])
$(info $e)
$(info h4,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk4),$(blk2),$(pad),resize)))])
$(info $e)
$(info h4,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk4),$(blk4),$(pad),resize)))])
$(info $e)
$(info h4,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,$(blk4),       ,$(pad),resize)))])
$(info $e)
$(info h ,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vresize,       ,       ,$(pad),resize)))])
$(info $e)

endif




#-------------------------------------------------------------------------------
# block.hreshape
#-------------------------------------------------------------------------------

ifneq "$(filter $(tests),block.hreshape)" ""

str1 := 1..$n2.$n3
str2 := A$nB.
str3 := $n
str4 :=
pad  := .
blk1 := $(call str.to.block,str,$(str1),$(pad))
blk2 := $(call str.to.block,str,$(str2),$(pad))
blk3 := $(call str.to.block,str,$(str3),$(pad))
blk4 := $(call str.to.block,str,$(str4),$(pad))

$(info $e)
$(info $eBlocks)
$(info $e)
$(info blk1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk1)))])
$(info $e)
$(info blk2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk2)))])
$(info $e)
$(info blk3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk3)))])
$(info $e)
$(info blk4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk4)))])
$(info $e)
$(info $eHRESHAPE)
$(info $e)
$(info w2,1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk2),$(blk1),$(pad))))])
$(info $e)
$(info w1,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk1),$(blk2),$(pad))))])
$(info $e)
$(info w1,3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk1),$(blk3),$(pad))))])
$(info $e)
$(info w1,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk1),$(blk4),$(pad))))])
$(info $e)
$(info w1,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk1),       ,$(pad))))])
$(info $e)
$(info w3,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk3),$(blk2),$(pad))))])
$(info $e)
$(info w3,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk3),$(blk4),$(pad))))])
$(info $e)
$(info w4,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk4),$(blk2),$(pad))))])
$(info $e)
$(info w4,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk4),$(blk4),$(pad))))])
$(info $e)
$(info w4,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,$(blk4),       ,$(pad))))])
$(info $e)
$(info w ,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hreshape,       ,       ,$(pad))))])
$(info $e)

endif






#-------------------------------------------------------------------------------
# block.hstack
# block.vstack
#-------------------------------------------------------------------------------

ifneq "$(filter $(tests),block.hstack block.vstack)" ""

str1 := 1..$n2.$n3
str2 := A$nB.
str3 := $n
str4 :=
pad  := .
blk1 := $(call str.to.block,str,$(str1),$(pad))
blk2 := $(call str.to.block,str,$(str2),$(pad))
blk3 := $(call str.to.block,str,$(str3),$(pad))
blk4 := $(call str.to.block,str,$(str4),$(pad))

$(info $e)
$(info $eBlocks)
$(info $e)
$(info blk1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk1)))])
$(info $e)
$(info blk2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk2)))])
$(info $e)
$(info blk3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk3)))])
$(info $e)
$(info blk4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(blk4)))])
$(info $e)
$(info $eHSTACK)
$(info $e)
$(info h2,1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk2),$(blk1),$(pad))))])
$(info $e)
$(info h1,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk1),$(blk2),$(pad))))])
$(info $e)
$(info h1,3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk1),$(blk3),$(pad))))])
$(info $e)
$(info h1,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk1),$(blk4),$(pad))))])
$(info $e)
$(info h1,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk1),       ,$(pad))))])
$(info $e)
$(info h3,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk3),$(blk2),$(pad))))])
$(info $e)
$(info h3,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk3),$(blk4),$(pad))))])
$(info $e)
$(info h4,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk4),$(blk2),$(pad))))])
$(info $e)
$(info h4,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk4),$(blk4),$(pad))))])
$(info $e)
$(info h4,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,$(blk4),       ,$(pad))))])
$(info $e)
$(info h ,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.hstack,       ,       ,$(pad))))])
$(info $e)
$(info $eVSTACK)
$(info $e)
$(info v2,1 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk2),$(blk1),$(pad))))])
$(info $e)
$(info v1,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk1),$(blk2),$(pad))))])
$(info $e)
$(info v1,3 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk1),$(blk3),$(pad))))])
$(info $e)
$(info v1,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk1),$(blk4),$(pad))))])
$(info $e)
$(info v1,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk1),       ,$(pad))))])
$(info $e)
$(info v3,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk3),$(blk2),$(pad))))])
$(info $e)
$(info v3,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk3),$(blk4),$(pad))))])
$(info $e)
$(info v4,2 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk4),$(blk2),$(pad))))])
$(info $e)
$(info v4,4 = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk4),$(blk4),$(pad))))])
$(info $e)
$(info v4,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,$(blk4),       ,$(pad))))])
$(info $e)
$(info v ,  = [$(subst $n,$v$n$s$s$s$s$s$s$s$u,$(call block.to.str,$(call block.vstack,       ,       ,$(pad))))])
$(info $e)

endif





#-------------------------------------------------------------------------------
# int.trim
# int.abs
# int.neg
# int.equ.0
# int.neq.0
# int.gtr.0
# int.geq.0
# int.leq.0
# int.lss.0
# int.add
# int.sub
# int.equ
# int.neq
# int.gtr
# int.geq
# int.leq
# int.lss
#-------------------------------------------------------------------------------

ifneq "$(filter $(tests),int.trim int.abs int.neg int.equ.0 int.neq.0 int.gtr.0 int.geq.0 int.leq.0 int.lss.0 int.add int.sub int.equ int.neq int.gtr int.geq int.leq int.lss)" ""


ints := $$e 00 -00 01 -01 09 010 -099
$(foreach i1,$(ints),\
	$(info $e)\
	$(foreach func,int.trim int.abs int.neg,\
		$(info $(func)($(i1:$$e=))$t = [$(call $(func),$(i1:$$e=))])\
	)\
	$(foreach func,int.equ.0 int.neq.0 int.gtr.0 int.geq.0 int.leq.0 int.lss.0,\
		$(info $(func)($(i1:$$e=))$t = [$(if $(call $(func),$(i1:$$e=)),true,false)])\
	)\
	$(foreach i2,$(ints),\
		$(foreach func,int.add int.sub,\
			$(info $(func)($(i1:$$e=),$(i2:$$e=))$t = [$(call $(func),$(i1:$$e=),$(i2:$$e=))])\
		)\
	)\
	$(foreach i2,$(ints),\
		$(foreach func,int.equ int.neq int.gtr int.geq int.leq int.lss,\
			$(info $(func)($(i1:$$e=),$(i2:$$e=))$t = [$(if $(call $(func),$(i1:$$e=),$(i2:$$e=)),true,false)])\
		)\
	)\
)

endif
