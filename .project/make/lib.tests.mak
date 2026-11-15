#===============================================================================
# lib.tests.mak
#
# Automated tests for the functions defined in 'lib.common.mak'.
#
# Usage (from the repository root):
#
#	make -f .project/make/lib.tests.mak                         Run all tests
#	make -f .project/make/lib.tests.mak tests=int.%             Run tests whose function name, or
#	                                                              FUNC:CASE id, matches a %-pattern
#	make -f .project/make/lib.tests.mak verbose=1               Also print passing tests
#	make -f .project/make/lib.tests.mak coverage=1              List library functions with no tests
#	make -f .project/make/lib.tests.mak coverage=1 verbose=1    Also print functions with test coverage
#
#	Exits 0 if all selected tests pass, or 2 if any fail.
#
# Writing tests:
#
#	$(call test,FUNC,CASE,EXPR,EXPECTED)
#	    Passes if EXPR and EXPECTED expand to exactly the same string.
#
#	FUNC      Name of the library function under test. The test fails if it is
#	          not defined.
#	CASE      Short label. FUNC:CASE must be unique and a single word, with no
#	          quotes, '#' or '$'.
#	EXPR, EXPECTED
#	          Make expressions, expanded only if the test is selected.
#	          - Escape them with '$$', e.g. $$(call int.add,1,2).
#	            A literal '$' in a value is written '$$$$'.
#	          - Leading whitespace is ignored; write a significant leading
#	            space as $$s.
#	          - '#' may be used freely. A line may be continued with '\'
#	            directly after a comma.
#	          - $1, $2, ... are empty while they are expanded.
#
#	Tests with side effects should only use variables named 't.FUNC.*'.
#
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
#===============================================================================
ifneq "$(filter lib.common.mak,$(notdir $(MAKEFILE_LIST)))" ""
$(error Error: lib.common.mak must not be included prior to running lib.tests.mak.)
endif

__test.vars := $(subst %,\%,$(.VARIABLES))
__test.file := $(lastword $(MAKEFILE_LIST))
include $(dir $(__test.file))lib.common.mak
__test.vars := $(filter-out test.% $(__test.vars),$(.VARIABLES))
#===============================================================================



# tests="func1 func2:case ..."
#
ifeq "$(tests)" ""
override tests := %
endif
override tests := $(subst *,%,$(tests))

# verbose=1    Shows tests that PASS as well as those that FAIL, etc
#
ifeq "$(filter y Y 1 2 3 4 5 6 7 8 9,$(verbose))" ""
override verbose :=
endif

# silent=1     Suppresses all output, except that of the test itself.
#              Overrides "verbose"
#              Returns exit code 0 if all tests passed, exit code != 0 if tests failed.
ifeq "$(filter y Y 1 2 3 4 5 6 7 8 9,$(silent))" ""
override silent :=
endif

# coverage=1   Prints the coverage report.
#
ifeq "$(filter y Y 1 2 3 4 5 6 7 8 9,$(coverage))" ""
override coverage :=
endif


#===============================================================================
# Constants
#===============================================================================
override test.empty  :=
override test.space  := $(test.empty) $(test.empty)
override test.tab    := $(test.empty)	$(test.empty)
override test.comma  := ,
override test.hash   := \#
override test.lparen := (
override test.rparen := )
override define test.nl


endef


#-------------------------------------------------------------------------------
# Expression evaluation
#-------------------------------------------------------------------------------
# [empty] <-- $(call __test.eval,{var},[expr])
#	Assigns the expansion of [expr] to {var}. $1, $2, ... are empty during the
#	expansion, since __test.expand is called with no arguments.
#
# [text] <-- $(call __test.escape,[text])
#	Replaces '#' and linefeeds with references, so [text] survives $(eval).
#
#-------------------------------------------------------------------------------
override __test.eval   = $(eval __test.eval.wrapper = $(call __test.eval.escape,$2))$(eval $1 := $$(call __test.eval.wrapper))
override __test.eval.escape = $1
#override __test.eval.escape = $(subst $(test.nl),$$(test.nl),$(subst $(test.hash),$$(test.hash),$1))
#override __test.eval.expand = $(__test.eval.definition)


#-------------------------------------------------------------------------------
# Comparison
#-------------------------------------------------------------------------------
# [str]  <-- $(call __test.str.neq,[str:1],[str:2])   Nonempty if the strings differ.
#-------------------------------------------------------------------------------
override __test.str.neq = $(subst x$1,,x$2)$(subst x$2,,x$1)
override __test.str.equ = $(if $(__test.str.neq),,x)

#-------------------------------------------------------------------------------
# Display
#-------------------------------------------------------------------------------
# [str]  <-- $(call __test.print.str,[str])           Bracketed, with tabs/linefeeds visible.
#-------------------------------------------------------------------------------
override __test.print.str = [$(subst $(test.nl),\n,$(subst $(test.tab),\t,$1))]


#-------------------------------------------------------------------------------
# Results
#-------------------------------------------------------------------------------
# [empty] <-- $(call __test.log.invalid,{id},[line],[line])
# [empty] <-- $(call __test.log.pass,{id},[line],[line])
# [empty] <-- $(call __test.log.fail,{id},[line],[line])
# [empty] <-- $(call __test.log.skip,{id},[line],[line])
#	Appends {id} to $(__test.ids.{list}) and prints the result.
#
#-------------------------------------------------------------------------------

# __test.funcs : list of functions which have test coverage
# __test.ids   : list of unique test ids (id=func:case)
override __test.funcs :=
override __test.ids :=
override __test.ids.invalid :=
override __test.ids.passed :=
override __test.ids.failed :=
override __test.ids.skipped :=

override __test.log.invalid = $(strip \
	$(eval override __test.ids.invalid += $1)\
	$(if $(silent),,\
		$(info INVALID  $1)\
		$(if $2,$(info $(test.empty)        $2))\
		$(if $3,$(info $(test.empty)        $3))\
	)\
)

override __test.log.pass = $(strip \
	$(eval override __test.ids.passed += $1)\
	$(if $(silent),,\
		$(if $(verbose),\
			$(info PASS  $1)\
			$(if $2,$(info $(test.empty)        $2))\
			$(if $3,$(info $(test.empty)        $3))\
		)\
	)\
)

override __test.log.fail = $(strip \
	$(eval override __test.ids.failed += $1)\
	$(if $(silent),,\
		$(info FAIL  $1)\
		$(if $2,$(info $(test.empty)        $2))\
		$(if $3,$(info $(test.empty)        $3))\
	)\
)

override __test.log.skip = $(strip \
	$(eval override __test.ids.skipped += $1)\
	$(if $(silent),,\
		$(info SKIPPED  $1)\
		$(if $2,$(info $(test.empty)        $2))\
		$(if $3,$(info $(test.empty)        $3))\
	)\
)

# [str]   <-- $(call __test.check_id,{func},{case})
#	Returns a reason if FUNC:CASE is not a valid, unique test id.
# __test.check_id = $(strip \
# 	$(if $(or $(if $1,,x),$(if $2,,x),$(filter-out 1,$(words $1:$2)),$(findstring ",$1$2),$(findstring ',$1$2),$(findstring $(test.hash),$1$2),$(findstring $$,$1$2)),\
# 		invalid test id,\
# 		$(if $(filter $1:$2,$(__test.ids)),duplicate test id)))


# [bool] <-- $(call __test.func.is.undefined,[func])
# [bool] <-- $(call __test.id.is.invalid,[str:id])
# [bool] <-- $(call __test.id.is.duplicate,[str:id])
override __test.func.is.undefined = $(if $(filter undefined,$(flavor $1)),x,)
override __test.id.is.invalid     = $(if $(or $(filter-out 1,$(words $1)),$(filter-out 2,$(words $(subst :,$(test.space),$1))),$(findstring ",$1),$(findstring ',$1),$(findstring $(test.hash),$1),$(findstring $$,$1)),x,)
override __test.id.is.duplicate   = $(if $(filter-out 0 1,$(words $(filter $1,$(__test.ids)))),x,)

#-------------------------------------------------------------------------------
# $(call test,{func:FUNC},{word:CASE},[expr:EVALUATE],[expr:EXPECTED])
#-------------------------------------------------------------------------------

override test = $(strip \
	$(null Define local variables)\
	$(eval override __test.func := $(or $(subst $(test.space),$$s,$(strip $1)),$(test.hash)empty$(test.hash)))\
	$(eval override __test.case := $(or $(subst $(test.space),$$s,$(strip $2)),$(test.hash)empty$(test.hash)))\
	$(eval override __test.id   := $$(__test.func):$$(__test.case))\
	\
	$(null Add func to function coverage list, id to test id list)\
	$(eval override __test.funcs += $(__test.func))\
	$(eval override __test.ids   += $(__test.id))\
	\
	$(null If user wants to run this test...)\
	$(if $(filter $(tests),$(__test.func) $(__test.id)),\
	\
		$(null Check test validity)\
		$(if $(call __test.func.is.undefined,$(__test.func)),\
			$(call __test.log.invalid,$(__test.id),function not defined: $(__test.func)),\
		\
		$(if $(call __test.id.is.invalid,$(__test.id)),\
			$(call __test.log.invalid,$(__test.id),invalid test id),\
		\
		$(if $(call __test.id.is.duplicate,$(__test.id)),\
			$(call __test.log.invalid,$(__test.id),duplicate test id),\
		\
			$(null Evaluate both expressions and compare them)\
			$(call __test.eval,__test.returned,$3)\
			$(call __test.eval,__test.expected,$4)\
			\
			$(if $(call __test.str.equ,$(__test.returned),$(__test.expected)),\
				$(call __test.log.pass,$(__test.id)),\
				$(call __test.log.fail,$(__test.id),Expected: $(call __test.print.str,$(__test.expected)),Returned: $(call __test.print.str,$(__test.returned)))\
			)\
		)))\
	)\
)


# $(eval $$(__test.expr))$(info __test.no-error)
# $(call __test.error.result,$(__test.id),$(__test.msg),$(shell "$(MAKE)" --no-print-directory -s -f "$(__test.file)" "id=$(__test.id)" 2>&1)))))

# $(call __test.error.result,{id},[MESSAGE],[output])   Reads $(.SHELLSTATUS) of the child.
override __test.error.result = $(strip \
	$(if $(and $(filter-out 0,$(.SHELLSTATUS)),$(if $(findstring __test.no-error,$3),,x),$(if $2,$(findstring $2,$3),x)),\
		$(call __test.log.pass,$1),\
		$(call __test.log.fail,$1,expected: an error$(if $2, containing $(call __test.print.str,$2)),actual:   exit status $(.SHELLSTATUS)$(test.comma) output $(call __test.print.str,$3))\
	)\
)


#-------------------------------------------------------------------------------
# Coverage (coverage=1)
#-------------------------------------------------------------------------------
# A library definition is a function if it is recursively expanded and either:
#	- expands an argument directly ($1 ... $9, or $(1 ... $(9, which also covers
#	  $(1:a=b) and $(10)), ignoring escaped '$$'; or
#	- contains a plain reference $(F) or $(F:...) to another function F.
# $(call F,...) alone does not count, since it supplies its own arguments.
#
# [list{var}] <-- $(call __test.var.filter.functions,[list{var}])
#--------------------------------------------------------------------------------
__test.var.filter.functions    = $(call __test.var.filter.functions.2,$(foreach __V,$1,$(if $(filter recursive,$(flavor $(__V))),$(__V))))
__test.var.filter.functions.2  = $(call __test.var.filter.functions.3,$1,$(strip $(call __test.direct,$1)))
__test.var.filter.functions.3  = $(call __test.closure,$2,$(filter-out $2,$1))


# [list]      <-- $(call __test.closure,[list:funcs],[list:cands]) Add transitive functions
# [list]      <-- $(call __test.direct,[list{var}])                Direct functions
# [str]       <-- $(call __test.value,{var})                       Value, with '$$' removed
__test.closure      = $(call __test.closure.step,$1,$2,$(strip $(call __test.refs,$1,$2)))
__test.closure.step = $(if $3,$(call __test.closure,$1 $3,$(filter-out $3,$2)),$1)

__test.direct       = $(foreach __V,$1,$(call __test.direct.one,$(__V),$(call __test.value,$(__V))))
__test.direct.one   = $(if $(strip $(foreach __D,1 2 3 4 5 6 7 8 9,$(findstring $$$(__D),$2)$(findstring $$$(test.lparen)$(__D),$2))),$1)

__test.refs         = $(foreach __V,$2,$(call __test.refs.one,$1,$(__V),$(call __test.value,$(__V))))
__test.refs.one     = $(if $(strip $(foreach __R,$1,$(findstring $$$(test.lparen)$(__R)$(test.rparen),$3)$(findstring $$$(test.lparen)$(__R):,$3))),$2)

__test.value        = $(subst $$$$,,$(value $1))



#-------------------------------------------------------------------------------
# $(call test.report.summary)
#	Prints the totals; stops Make with an error if any test failed.
#
# $(call test.report.coverage)
#	Lists function definitions which have no test coverage.
#	Names beginning with '_' are internal and are not reported.
#-------------------------------------------------------------------------------
test.report.summary = \
	$(info $(test.empty))\
	$(info $(notdir $(__test.file)): $(words $(__test.ids.passed)) passed$(test.comma) $(words $(__test.ids.failed)) failed, $(words $(__test.ids.skipped)) skipped, $(words $(__test.ids.invalid)) invalid ($(words $(__test.ids.passed) $(__test.ids.failed) $(__test.ids.skipped) $(__test.ids.invalid)) total))

test.report.coverage = $(call __test.report.coverage,$(sort $(filter-out _%,$(call __test.var.filter.functions,$(__test.vars)))))
__test.report.coverage = \
	$( Local variables )\
	$(eval override $0.funcs.all      := $1)\
	$(eval override $0.funcs.tested   := $(filter     $(__test.funcs),$($0.funcs.all)))\
	$(eval override $0.funcs.untested := $(filter-out $(__test.funcs),$($0.funcs.all)))\
	\
	$( Print results )\
	$(info $(test.empty))\
	$(info coverage: $(words $($0.funcs.all)) library functions$(test.comma) $(words $($0.funcs.tested)) (+)tested$(test.comma) $(words $($0.funcs.untested)) (-)untested)\
	$(foreach __F,$(if $(verbose),$($0.funcs.all),$($0.funcs.untested)),\
		$(info $(test.empty)  $(if $(filter $(__F),$($0.funcs.tested)),(+),(-)) $(__F))\
	)


test.exit_on_error = $(if $(strip $(__test.ids.failed) $(__test.ids.invalid)),$(error Exiting with error.$(if $(strip $(__test.ids.failed)),$(test.nl)$(words $(__test.ids.failed)) test(s) failed.)$(if $(strip $(__test.ids.invalid)),$(test.nl)$(words $(__test.ids.invalid)) test(s) invalid)))






#===============================================================================
# CHARACTERS
#===============================================================================
$(call test,chars.split,str,$$(call chars.split,{str},abc$$1),a b c)
$(call test,chars.split,space,$$(call chars.split,{str},a b),a $$$$s b)
$(call test,chars.split,empty,$$(call chars.split,{str},),)




#===============================================================================
# BOOLEANS
#===============================================================================
$(call test,bool.is.truthy,yes,$$(call bool.is.truthy,yes),1)
$(call test,bool.is.truthy,padded,$$(call bool.is.truthy,$$s Y $$s),1)
$(call test,bool.is.truthy,no,$$(call bool.is.truthy,no),)
$(call test,bool.is.truthy,empty,$$(call bool.is.truthy,),)
$(call test,bool.is.falsey,zero,$$(call bool.is.falsey,0),1)
$(call test,bool.is.falsey,yes,$$(call bool.is.falsey,yes),)




#===============================================================================
# STRINGS
#===============================================================================
$(call test,str.lower,mixed,$$(call str.lower,Hello World),hello world)
$(call test,str.upper,mixed,$$(call str.upper,Hello World),HELLO WORLD)
$(call test,str.len,str,$$(call str.len,{str},a b),3)
$(call test,str.len,list,$$(call str.len,,a b c),3)
$(call test,str.sub,middle,$$(call str.sub,{str},abcdef,2,4),bcd)
$(call test,str.sub,to-end,$$(call str.sub,{str},abcdef,3),cdef)
$(call test,str.equ,same,$$(call str.equ,abc,abc),1)
$(call test,str.equ,different,$$(call str.equ,abc,abd),)
$(call test,str.equ,case-insensitive,$$(call str.equ,ABC,abc,1),1)
$(call test,str.concat.pair,both,$$(call str.concat.pair,$$c,a,b),a$$cb)
$(call test,str.concat.pair,skip-empty,$$(call str.concat.pair,$$c,a,),a)

$(call test,str.subst.list2list,doc-example,\
	$$(call str.subst.list2list,<string>,i < >,<i> << >>),\
	<<str<<i>>ng>>)
$(call test,str.treesubst.list2list,doc-example,\
	$$(call str.treesubst.list2list,<string>,i < >,<i> << >>),\
	<<str<i>ng>>)



#===============================================================================
# VARIABLES
#===============================================================================
$(call test,var.is.defined,yes,$$(call var.is.defined,char.space),char.space)
$(call test,var.is.defined,no,$$(call var.is.defined,t.var.is.defined.none),)
$(call test,var.is.empty,empty,$$(call var.is.empty,char.empty),char.empty)
$(call test,var.is.empty,nonempty,$$(call var.is.empty,char.comma),)

$(call test,var.set,simple-value,\
	$$(call var.set,,t.var.set.simple,str,a$$$$b)$$(t.var.set.simple),\
	a$$$$b)
$(call test,var.set,simple-flavor,\
	$$(call var.set,,t.var.set.flavor,str,x)$$(flavor t.var.set.flavor),\
	simple)
$(call test,var.set,recursive-flavor,\
	$$(call var.set,,t.var.set.rec,,$$$$(t.var.set.src))$$(flavor t.var.set.rec),\
	recursive)

$(call test,var.push,new-value,\
	$$(eval t.var.push.x := old)$$(call var.push,t.var.push.x,str,new)$$(t.var.push.x),\
	new)

$(call test,var.pop,restores,\
	$$(eval t.var.pop.x := old)$$(call var.push,t.var.pop.x,str,new)$$(call var.pop,t.var.pop.x)$$(t.var.pop.x),\
	old)



#===============================================================================
# LISTS
#===============================================================================
$(call test,word.pack,single-word,$$(words $$(call word.pack,{str},a b c)),1)
$(call test,word.pack,empty-braced,$$(call word.pack,{str},),)
$(call test,word.pack,empty-bracketed,$$(call word.pack,[str],),$$$$e)
$(call test,word.unpack,round-trip,\
	$$(call word.unpack,{str},$$(call word.pack,{str},a b$$$$c)),\
	a b$$$$c)
$(call test,list.reverse,basic,$$(call list.reverse,a b c),c b a)
$(call test,list.reverse,single,$$(call list.reverse,a),a)
$(call test,filter-out.start,basic,$$(call filter-out.start,1 2,1 1 2 3 1),3 1)
$(call test,filter-out.end,basic,$$(call filter-out.end,1,3 1 1),3)

$(call test,list.get,index,$$(call list.get,,a b c,2),b)
$(call test,list.get,out-of-range,$$(call list.get,,a b c,4),)
$(call test,list.insert,middle,$$(call list.insert,,a c,b,2),a b c)
$(call test,list.insert,end,$$(call list.insert,,a b,c,3),a b c)



#===============================================================================
# PATHS
#===============================================================================
$(call test,path.dir,file,$$(call path.dir,/path/to/file.ext),/path/to/)
$(call test,path.dir,dir,$$(call path.dir,/path/to/dir.ext/),/path/to/dir.ext/)
$(call test,path.dir,empty,$$(call path.dir,),./)
$(call test,path.dir,spaces,$$(call path.dir,/a b/c d.txt),/a b/)
$(call test,path.suffix,file,$$(call path.suffix,/path/to/file.ext),.ext)
$(call test,path.suffix,dir,$$(call path.suffix,/path/to/dir.ext/),)

$(call test,path.exists,this-file,$$(call path.exists,$$(__test.file)),$$(__test.file))
$(call test,path.exists,missing,$$(call path.exists,t.path.exists.none),)



#===============================================================================
# INTEGERS
#===============================================================================
$(call test,int.trim,zeros,$$(call int.trim,-007),-7)
$(call test,int.trim,negative-zero,$$(call int.trim,-00),0)
$(call test,int.trim,empty,$$(call int.trim,),0)
$(call test,int.add,carry,$$(call int.add,95,7),102)
$(call test,int.add,negative,$$(call int.add,-01,9),8)
$(call test,int.add,empty,$$(call int.add,,),0)
$(call test,int.sub,negative-result,$$(call int.sub,3,10),-7)
$(call test,int.lss,true,$$(call int.lss,-1,2),-1)
$(call test,int.lss,false,$$(call int.lss,5,2),)
$(call test,int.lss,equal,$$(call int.lss,2,2),)



#===============================================================================
# EXPRESSIONS
#===============================================================================
$(call test,expr.expand,reference,$$(call expr.expand,$$$$(char.comma)),$$c)
$(call test,expr.expand,alias,$$(call expr.expand,a$$$$sb),a$$sb)



#===============================================================================
# SHELL
#===============================================================================
$(call test,shell.run,stdout,$$(call shell.run,echo hello),hello)
$(call test,shell.run,exitcode,$$(call shell.run,exit 3,t.shell.run.code)$$(t.shell.run.code),3)



#===============================================================================
# FILES
#===============================================================================
$(call test,file.tee,no-path,$$(call file.tee,,,abc),abc)



#===============================================================================
# PRINTING
#===============================================================================
$(call test,str.indent.add,two-lines,$$(call str.indent.add,a$$nb,--),--a$$n--b)
$(call test,str.lines.wrap,two-lines,$$(call str.lines.wrap,a$$nb,<,>),<a>$$n<b>)




#===============================================================================
$(if $(silent),,\
	$(if $(coverage),$(call test.report.coverage))\
	$(call test.report.summary)\
)

$(call test.exit_on_error)

.DEFAULT_GOAL := test
.PHONY: $(notdir $(__test.file))
.PHONY: test
test: ; @:
