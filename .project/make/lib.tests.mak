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
override test.num    := \#
override test.lparen := (
override test.rparen := )
override define test.lf


endef


#-------------------------------------------------------------------------------
# Expression Evaluation
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


#-------------------------------------------------------------------------------
# Comparison
#-------------------------------------------------------------------------------
# [str]  <-- $(call __test.str.neq,[str:1],[str:2])   Nonempty if the strings differ.
#-------------------------------------------------------------------------------
override __test.str.neq = $(subst x$1,,x$2)$(subst x$2,,x$1)
override __test.str.equ = $(if $(__test.str.neq),,x)



#-------------------------------------------------------------------------------
# Test Case Validation
#-------------------------------------------------------------------------------
# [bool] <-- $(call __test.func.is.undefined,[func])
# [bool] <-- $(call __test.id.is.invalid,[str:id])
# [bool] <-- $(call __test.id.is.duplicate,[str:id],[list:ids])
#-------------------------------------------------------------------------------
override __test.func.is.undefined = $(if $(filter undefined,$(flavor $1)),x,)
override __test.id.is.invalid     = $(if $(or $(filter-out 1,$(words $1)),$(filter-out 2,$(words $(subst :,$(test.space),$1))),$(findstring ",$1),$(findstring ',$1),$(findstring $(test.num),$1),$(findstring $$,$1)),x,)
override __test.id.is.duplicate   = $(if $(filter-out 0 1,$(words $(filter $1,$2))),x,)


#-------------------------------------------------------------------------------
# Logging
#-------------------------------------------------------------------------------
# [empty] <-- $(call __test.log.invalid,{id},[line],[line])
# [empty] <-- $(call __test.log.pass,{id},[line],[line])
# [empty] <-- $(call __test.log.fail,{id},[line],[line])
# [empty] <-- $(call __test.log.skip,{id},[line],[line])
#	Appends {id} to $(__test.ids.{list}) and prints the result.
#
# [str]   <-- $(call __test.format.value,[str])
#	Formats a value for printing.
#	Value is [bracketed], tabs ane linefeeds replaced with \t and \n
#-------------------------------------------------------------------------------

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


override __test.format.value = [$(subst $(test.lf),\n,$(subst $(test.tab),\t,$1))]



#-------------------------------------------------------------------------------
# Testing (tests=...)
#-------------------------------------------------------------------------------
#
# $(call test,{func:FUNC},{word:CASE},[expr:EVALUATE],[expr:EXPECTED])
#
#	Validates, runs, and logs a test case which asserts that both expressions
#	must evaluate to the same string.
#	- FUNC is the name of a function.
#	  The function must be user-defined and public (name not starting with "_").
#	- The test case ID is logged as "FUNC:CASE".
#	  There can be many CASEs for each FUNC, but every ID must be unique.
#	- EVALUATE and EXPECTED are expressions (eval-compatible Makefile syntax).
#	  If they expand to the same value, a success will be logged.
#	- EVALUATE is typically a $(call) to FUNC with some set of arguments.
#	- EXPECTED is typically a constant value.
#
#-------------------------------------------------------------------------------

# list of functions which have test coverage
override __test.funcs :=

# list of unique test ids (id=func:case)
override __test.ids :=

override test = $(strip \
	$( Define local variables )\
	$(eval override __test.func := $(or $(subst $(test.space),$$s,$(strip $1)),$(test.num)empty$(test.num)))\
	$(eval override __test.case := $(or $(subst $(test.space),$$s,$(strip $2)),$(test.num)empty$(test.num)))\
	$(eval override __test.id   := $$(__test.func):$$(__test.case))\
	\
	$( Add func to function coverage list, id to test id list )\
	$(eval override __test.funcs += $(__test.func))\
	$(eval override __test.ids   += $(__test.id))\
	\
	$( If user wants to run this test... )\
	$(if $(filter $(tests),$(__test.func) $(__test.id)),\
	\
		$( Check test validity )\
		$(if $(call __test.func.is.undefined,$(__test.func)),\
			$(call __test.log.invalid,$(__test.id),function not defined: $(__test.func)),\
		\
		$(if $(call __test.id.is.invalid,$(__test.id)),\
			$(call __test.log.invalid,$(__test.id),invalid test id),\
		\
		$(if $(call __test.id.is.duplicate,$(__test.id),$(__test.ids)),\
			$(call __test.log.invalid,$(__test.id),duplicate test id),\
		\
			$( Evaluate both expressions and compare them )\
			$(call __test.eval,__test.returned,$3)\
			$(call __test.eval,__test.expected,$4)\
			\
			$(if $(call __test.str.equ,$(__test.returned),$(__test.expected)),\
				$(call __test.log.pass,$(__test.id)),\
				$(call __test.log.fail,$(__test.id),Expected: $(call __test.format.value,$(__test.expected)),Returned: $(call __test.format.value,$(__test.returned)))\
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
		$(call __test.log.fail,$1,expected: an error$(if $2, containing $(call __test.format.value,$2)),actual:   exit status $(.SHELLSTATUS)$(test.comma) output $(call __test.format.value,$3))\
	)\
)


#-------------------------------------------------------------------------------
# Coverage (coverage=1)
#-------------------------------------------------------------------------------
# A variable is a function iff the following are true:
# - it is recursively expanded (flavor = recursive)
# - it expands another variable F like:
#     $F, $(F), $(F:...), $(F arg1,arg2,...),
#   where F is either:
#     - a function argument (0 thru 9)
#     - a built-in function (sort, filter, etc)
#     - a variable which itself is a recursively-expanded function
#
# A user-defined function is a function which also:
# - is defined in a file (origin = file or override)
#
# A public function is a function which also:
# - does not start with "_"
#
# The coverage report should gather a list of all user-defined public functions,
# then check if there are test cases defined for them.
#--------------------------------------------------------------------------------


# [list{var}] <-- $(call __test.var.is.func.list-refs,[var])
#	if var is recursive flavor:
#		read value
#		remove "$$"
#		add space before each "$", ":", ")"
#		filter "$%" and "$(%"
#		filter-out lone "$"
#		patsubst "$(%" --> "%"    Returns F for $(F), $(F:...), $(F arg1,arg2,...), but not $F
#		foreach in resulting list: any remaining '$%' are single-char references
#			if var starts with '$',
#				strip leading '$'
#				split characters
#				keep only first character
#			else
#				return var unchanged
#
override __test.var.is.func.list-refs = $(sort \
	$(if $(filter recursive,$(flavor $1)),\
		$(foreach __var,\
			$(patsubst $$$(test.lparen)%,%,\
				$(filter-out $$,$(filter $$%,\
					$(subst $$,$(test.space)$$,$(subst :,$(test.space):,$(subst $(test.rparen),$(test.space)$(test.rparen),\
						$(subst $$$$,,\
							$(value $1)\
						)\
					)))\
				))\
			),\
			$(if $(__var:$$%=),\
				$(__var),\
				$(firstword $(call chars.split,var,$(__var:$$%=%)))\
			)\
		)\
	)\
)

# [bool:var] <-- $(call __test.var.is.func,[var])
# [bool:var] <-- $(call __test.var.is.func,[var],[list{var}:visited])  (internal usage)
#	if origin is file and var not in visited,
#		if var in confirmed-refs, (digits 0-9, and any make builtins)
#			return var
#		else
#			list-refs
#			filter-out var visited
#			foreach ref:
#				if var.is.func(ref, var visited),
#					return var
#
override __test.var.is.func.confirmed-refs := 0 1 2 3 4 5 6 7 8 9 subst patsubst strip findstring filter filter-out sort word wordlist words firstword lastword dir notdir suffix basename addsuffix addprefix join wildcard realpath abspath if or and intcmp let foreach file call value eval origin flavor error warning info shell guile

override __test.var.is.func = $(sort \
	$( info [$0]:($1))\
	$(if $(filter-out $2,$1),\
		$(if $(filter $(__test.var.is.func.confirmed-refs),$1),\
			$1,\
			$(foreach __var,$(filter-out $1 $2,$(call __test.var.is.func.list-refs,$1)),\
				$(if $(call $0,$(__var),$1 $2),\
					$1\
				)\
			)\
		)\
	)\
)

# [list{func}] <-- $(call __test.coverage.filter.funcs,[list{var}])
override __test.coverage.filter.funcs = $(sort $(filter-out _%,$(foreach __var,$1,$(if $(filter file override,$(origin $(__var))),$(call __test.var.is.func,$(__var))))))



#-------------------------------------------------------------------------------
# Test Reports
#-------------------------------------------------------------------------------

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

test.report.coverage = \
	$( Local variables )\
	$(eval override $0.funcs.all      := $(call __test.coverage.filter.funcs,$(__test.vars)))\
	$(eval override $0.funcs.tested   := $(filter     $(__test.funcs),$($0.funcs.all)))\
	$(eval override $0.funcs.untested := $(filter-out $(__test.funcs),$($0.funcs.all)))\
	\
	$( Print results )\
	$(info $(test.empty))\
	$(info coverage: $(words $($0.funcs.all)) library functions$(test.comma) $(words $($0.funcs.tested)) tested(+)$(test.comma) $(words $($0.funcs.untested)) untested(-))\
	$(foreach __F,$(if $(verbose),$($0.funcs.all),$($0.funcs.untested)),\
		$(info $(test.empty)  $(if $(filter $(__F),$($0.funcs.tested)),(+),(-)) $(__F))\
	)


test.exit_on_error = $(if $(strip $(__test.ids.failed) $(__test.ids.invalid)),$(error Exiting with error.$(if $(strip $(__test.ids.failed)),$(test.lf)$(words $(__test.ids.failed)) test(s) failed.)$(if $(strip $(__test.ids.invalid)),$(test.lf)$(words $(__test.ids.invalid)) test(s) invalid)))






#===============================================================================
# CHARACTERS
#===============================================================================
# [list{char}] <-- $(call chars.split,[type:T],[T:val])
$(call test,chars.split,str,$$(call chars.split,{str},abc$$1),a b c)
$(call test,chars.split,space,$$(call chars.split,{str},a b),a $$$$s b)
$(call test,chars.split,empty,$$(call chars.split,{str},),)




#===============================================================================
# BOOLEANS
#===============================================================================
# [bool] <-- $(call bool.is.truthy,[str])
$(call test,bool.is.truthy,yes,$$(call bool.is.truthy,yes),1)
$(call test,bool.is.truthy,padded,$$(call bool.is.truthy,$$s Y $$s),1)
$(call test,bool.is.truthy,no,$$(call bool.is.truthy,no),)
$(call test,bool.is.truthy,empty,$$(call bool.is.truthy,),)

# [bool] <-- $(call bool.is.falsey,[str])
$(call test,bool.is.falsey,zero,$$(call bool.is.falsey,0),1)
$(call test,bool.is.falsey,yes,$$(call bool.is.falsey,yes),)




#===============================================================================
# STRINGS
#===============================================================================
# [str] <-- $(call str.lower,[str])
$(call test,str.lower,mixed,$$(call str.lower,Hello World),hello world)

# [str] <-- $(call str.upper,[str])
$(call test,str.upper,mixed,$$(call str.upper,Hello World),HELLO WORLD)

# {uint} <-- $(call str.len,[type:T],[T:str])
$(call test,str.len,str,$$(call str.len,{str},a b),3)
$(call test,str.len,list,$$(call str.len,,a b c),3)

# [T] <-- $(call str.sub,[type:T],[T:str],[idx:start],[uint:end])
$(call test,str.sub,middle,$$(call str.sub,{str},abcdef,2,4),bcd)
$(call test,str.sub,to-end,$$(call str.sub,{str},abcdef,3),cdef)

# {uint} <-- $(call str.cnt,[type:T],[T:find],[T:in])

# [bool] <-- $(call str.equ,[str:1],[str:2],[bool:case_insensitive])
$(call test,str.equ,same,$$(call str.equ,abc,abc),1)
$(call test,str.equ,different,$$(call str.equ,abc,abd),)
$(call test,str.equ,case-insensitive,$$(call str.equ,ABC,abc,1),1)

# [bool] <-- $(call str.neq,[str:1],[str:2],[bool:case_insensitive])

# [str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
$(call test,str.concat.pair,both,$$(call str.concat.pair,$$c,a,b),a$$cb)
$(call test,str.concat.pair,skip-empty,$$(call str.concat.pair,$$c,a,),a)

# [str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])

# [word[T]] <-- $(call word.concat.pair,[type:T],[T:sep],[word[T]:1],[word[T]:2])

# [str] <-- $(call str.map,[type:T],[func[T]([T:1],[str:const1],...)],[str:sep],[str:1],[str:const1],...,[str:const3])

# [str] <-- $(call str.map.1,[type:T],[func[T]([T:1],[str:const1],...)],[str:sep],[str:1],[str:const1],...,[str:const4])

# [str] <-- $(call str.map.2,[type:T],[func[T]([T:1],[T:2],[str:const1],...)],[str:sep],[str:1],[str:2],[str:const1],...,[str:const4])

# [str] <-- $(call str.map.3,[type:T],[func[T]([T:1],[T:2],[T:3],[str:const1],...)],[str:sep],[str:1],[str:2],[str:3],[str:const1],...,[str:const4])

# [str] <-- $(call str.map.4,[type:T],[func[T]([T:1],[T:2],[T:3],[T:4],[str:const1],...)],[str:sep],[str:1],[str:2],[str:3],[str:4],[str:const1],...,[str:const4])

# [str] <-- $(call str.subst.str2str,[str:in],[str:find],[str:repl])

# [str] <-- $(call str.subst.str2var,[str:in],[str:find],[var:repl])

# [str] <-- $(call str.subst.var2str,[str:in],[var:find],[str:repl])

# [str] <-- $(call str.subst.var2var,[str:in],[var:find],[var:repl])

# [str] <-- $(call str.prefix.str,[str:in],[str:find],[str:prefix])

# [str] <-- $(call str.prefix.var,[str:in],[var:find],[str:prefix])

# [str] <-- $(call str.suffix.str,[str:in],[str:find],[str:suffix])

# [str] <-- $(call str.suffix.var,[str:in],[var:find],[str:suffix])

# [str] <-- $(call str.wrap.str,[str:in],[str:find],[str:prefix],[str:suffix])

# [str] <-- $(call str.wrap.var,[str:in],[var:find],[str:prefix],[str:suffix])

# [str] <-- $(call str.strip.str,[str:in],[str:strip])

# [str] <-- $(call str.strip.str.start,[str:in],[str:strip])

# [str] <-- $(call str.strip.str.end,[str:in],[str:strip])

# [str] <-- $(call str.strip.var,[str:in],[var:strip])

# [str] <-- $(call str.strip.var.start,[str:in],[var:strip])

# [str] <-- $(call str.strip.var.end,[str:in],[var:strip])

# [str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])

# [str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])

# [str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])

# [str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])

# [str] <-- $(call str.strip.list,[str:in],[list:strip])

# [str] <-- $(call str.strip.list.start,[str:in],[list:strip])

# [str] <-- $(call str.strip.list.end,[str:in],[list:strip])

# [str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])

# [str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])

# [str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])

# [str] <-- $(call str.subst.list2list,[str:in],[list:find],[list:repl])
$(call test,str.subst.list2list,doc-example,\
	$$(call str.subst.list2list,<string>,i < >,<i> << >>),\
	<<str<<i>>ng>>)

# [str] <-- $(call str.subst.list2vars,[str:in],[list:find],[list{var}:repl])

# [str] <-- $(call str.subst.vars2list,[str:in],[list{var}:find],[list:repl])

# [str] <-- $(call str.subst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])

# [str] <-- $(call str.prefix.list,[str:in],[list:find],[str:prefix])

# [str] <-- $(call str.prefix.vars,[str:in],[list{var}:find],[str:prefix])

# [str] <-- $(call str.suffix.list,[str:in],[list:find],[str:suffix])

# [str] <-- $(call str.suffix.vars,[str:in],[list{var}:find],[str:suffix])

# [str] <-- $(call str.wrap.list,[str:in],[list:find],[str:prefix],[str:suffix])

# [str] <-- $(call str.wrap.vars,[str:in],[list{var}:find],[str:prefix],[str:suffix])

# [str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
$(call test,str.treesubst.list2list,doc-example,\
	$$(call str.treesubst.list2list,<string>,i < >,<i> << >>),\
	<<str<i>ng>>)

# [str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])

# [str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])

# [str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])




#===============================================================================
# VARIABLES
#===============================================================================
# [bool:var] <-- $(call var.is.shortname,[var])

# [bool:var] <-- $(call var.is.defined,[var])
$(call test,var.is.defined,yes,$$(call var.is.defined,char.space),char.space)
$(call test,var.is.defined,no,$$(call var.is.defined,t.var.is.defined.none),)

# [bool:var] <-- $(call var.is.undefined,[var])

# [bool:var] <-- $(call var.is.environment,[var])

# [bool:var] <-- $(call var.is.commandline,[var])

# [bool:var] <-- $(call var.is.makefile,[var])

# [bool:var] <-- $(call var.is.internal,[var])

# [bool:var] <-- $(call var.is.ws,[var])

# [bool:var] <-- $(call var.is.nonws,[var])

# [bool:var] <-- $(call var.is.empty,[var])
$(call test,var.is.empty,empty,$$(call var.is.empty,char.empty),char.empty)
$(call test,var.is.empty,nonempty,$$(call var.is.empty,char.comma),)

# [bool:var] <-- $(call var.is.def.empty,[var])

# [bool:var] <-- $(call var.is.nonempty,[var])

# [empty] <-- $(call var.set,[list:directives],[var],[type:T],[T:val])
$(call test,var.set,simple-value,\
	$$(call var.set,,t.var.set.simple,str,a$$$$b)$$(t.var.set.simple),\
	a$$$$b)
$(call test,var.set,simple-flavor,\
	$$(call var.set,,t.var.set.flavor,str,x)$$(flavor t.var.set.flavor),\
	simple)
$(call test,var.set,recursive-flavor,\
	$$(call var.set,,t.var.set.rec,,$$$$(t.var.set.src))$$(flavor t.var.set.rec),\
	recursive)

# [empty] <-- $(call var.append,[list:directives],[var],[type:T],[T:val])

# [empty] <-- $(call var.set_with_alternatives,{var},{word:assignment_operator},[str:initial_value],[list{var}:alternatives],[expr:value_if_still_empty])

# [empty] <-- $(call var.push,[var],[type:T],[T:val])
$(call test,var.push,new-value,\
	$$(eval t.var.push.x := old)$$(call var.push,t.var.push.x,str,new)$$(t.var.push.x),\
	new)

# [empty] <-- $(call var.pop,[var])
$(call test,var.pop,restores,\
	$$(eval t.var.pop.x := old)$$(call var.push,t.var.pop.x,str,new)$$(call var.pop,t.var.pop.x)$$(t.var.pop.x),\
	old)




#===============================================================================
# LISTS
#===============================================================================
# [list[T]] <-- $(call list.create,[type:T],[str:lines])

# [list[T]] <-- $(call list.reverse,[list[T]])
$(call test,list.reverse,basic,$$(call list.reverse,a b c),c b a)
$(call test,list.reverse,single,$$(call list.reverse,a),a)

# [word[T]] <-- $(call word.pack,[type:T],[T:val])
$(call test,word.pack,single-word,$$(words $$(call word.pack,{str},a b c)),1)
$(call test,word.pack,empty-braced,$$(call word.pack,{str},),)
$(call test,word.pack,empty-bracketed,$$(call word.pack,[str],),$$$$e)

# [T] <-- $(call word.unpack,[type:T],[word[T]:packed_val])
$(call test,word.unpack,round-trip,\
	$$(call word.unpack,{str},$$(call word.pack,{str},a b$$$$c)),\
	a b$$$$c)

# [list[T]] <-- $(call list.prune,[type:T],[list[T]])

# [list[T]] <-- $(call list.repack,[type:T],[list[T]])

# [list[T]] <-- $(call str.split,[type:T],[T:str],[T:sep])

# [str] <-- $(call list.merge,[type:T],[list[T]],[T:sep])

# [list] <-- $(call filter.start,[list:keep_patterns],[list])

# [list] <-- $(call filter.end,[list:keep_patterns],[list])

# [list] <-- $(call filter-out.start,[list:remove_patterns],[list])
$(call test,filter-out.start,basic,$$(call filter-out.start,1 2,1 1 2 3 1),3 1)

# [list] <-- $(call filter-out.end,[list:remove_patterns],[list])
$(call test,filter-out.end,basic,$$(call filter-out.end,1,3 1 1),3)

# [list[T]] <-- $(call list.extend.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])

# [list[T]] <-- $(call list.extend.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])

# [list[T]] <-- $(call list.resize.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])

# [list[T]] <-- $(call list.resize.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])

# [list[T]] <-- $(call list.map,[type:T],[func[T]([T:1],[str:const1],...)],[list[T]:1],[str:const1],...,[str:const4])

# [list[T]] <-- $(call list.map.1,[type:T],[func[T]([T:1],[str:const1],...)],[list[T]:1],[str:const1],...,[str:const4])

# [list[T]] <-- $(call list.map.2,[type:T],[func[T]([T:1],[T:2],[str:const1],...)],[list[T]:1],[list[T]:2],[str:const1],...,[str:const4])

# [list[T]] <-- $(call list.map.3,[type:T],[func[T]([T:1],[T:2],[T:3],[str:const1],...)],[list[T]:1],[list[T]:2],[list[T]:3],[str:const1],...,[str:const4])

# [list[T]] <-- $(call list.map.4,[type:T],[func[T]([T:1],[T:2],[T:3],[T:4],[str:const1],...)],[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4],[str:const1],...,[str:const4])

# [str] <-- $(call list.reduce,[type:T],[func[str]([str:acc],[T:1],[str:const1],...)],[str:acc],[list[T]:1],[str:const1],...,[str:const4])

# [str] <-- $(call list.reduce.1,[type:T],[func[str]([str:acc],[T:1],[str:const1],...)],[str:acc],[list[T]:1],[str:const1],...,[str:const4])

# [str] <-- $(call list.reduce.2,[type:T],[func[str]([str:acc],[T:1],[T:2],[str:const1],...)],[str:acc],[list[T]:1],[list[T]:2],[str:const1],...,[str:const4])

# [str] <-- $(call list.reduce.3,[type:T],[func[str]([str:acc],[T:1],[T:2],[T:3],[str:const1],...)],[str:acc],[list[T]:1],[list[T]:2],[list[T]:3],[str:const1],...,[str:const4])

# [str] <-- $(call list.reduce.4,[type:T],[func[str]([str:acc],[T:1],[T:2],[T:3],[T:4],[str:const1],...)],[str:acc],[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4],[str:const1],...,[str:const4])

# [idx] <-- $(call list.idx,[list[T]],[int:idx])

# [idx] <-- $(call list.idx.prev,[list[T]],[int:idx])

# [idx] <-- $(call list.idx.next,[list[T]],[int:idx])

# [idx] <-- $(call list.idx.first,[list[T]])

# [idx] <-- $(call list.idx.last,[list[T]])

# [list[T]] <-- $(call list.insert.N,[type:T],[list[T]],[T:val],[idx])

# [list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
$(call test,list.insert,middle,$$(call list.insert,,a c,b,2),a b c)
$(call test,list.insert,end,$$(call list.insert,,a b,c,3),a b c)

# [list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])

# [list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])

# [list[T]] <-- $(call list.remove.N,[list[T]],[idx])

# [list[T]] <-- $(call list.remove,[list[T]],[idx])

# [list[T]] <-- $(call list.remove.first,[list[T]])

# [list[T]] <-- $(call list.remove.last,[list[T]])

# [T] <-- $(call list.get.N,[type:T],[list[T]],[idx])

# [T] <-- $(call list.get,[type:T],[list[T]],[idx])
$(call test,list.get,index,$$(call list.get,,a b c,2),b)
$(call test,list.get,out-of-range,$$(call list.get,,a b c,4),)

# [T] <-- $(call list.get.first,[type:T],[list[T]])

# [T] <-- $(call list.get.last,[type:T],[list[T]])

# [list[T]] <-- $(call list.set.N,[type:T],[list[T]],[T:val],[idx])

# [list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])

# [list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])

# [list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])

# [list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2])

# [list[list[T]]] <-- $(call list.join.2,[list[T]:1],[list[T]:2])

# [list[list[T]]] <-- $(call list.join.3,[list[T]:1],[list[T]:2],[list[T]:3])

# [list[list[T]]] <-- $(call list.join.4,[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4])




#===============================================================================
# PATHS
#===============================================================================
# [multipath] <-- $(call multipath.create,[str:lines])

# [path] <-- $(call path.abspath,[path])

# [path] <-- $(call path.realpath,[path])

# [path] <-- $(call path.dir,[path])
$(call test,path.dir,file,$$(call path.dir,/path/to/file.ext),/path/to/)
$(call test,path.dir,dir,$$(call path.dir,/path/to/dir.ext/),/path/to/dir.ext/)
$(call test,path.dir,empty,$$(call path.dir,),./)
$(call test,path.dir,spaces,$$(call path.dir,/a b/c d.txt),/a b/)

# [path] <-- $(call path.notdir,[path])

# [path] <-- $(call path.parent,[path])

# [path] <-- $(call path.name,[path])

# [path] <-- $(call path.name.base,[path])

# [path] <-- $(call path.basename,[path])

# [path] <-- $(call path.suffix,[path])
$(call test,path.suffix,file,$$(call path.suffix,/path/to/file.ext),.ext)
$(call test,path.suffix,dir,$$(call path.suffix,/path/to/dir.ext/),)

# [list[path]] <-- $(call list.path.abspath,[list[path]])

# [list[path]] <-- $(call list.path.realpath,[list[path]])

# [list[path]] <-- $(call list.path.dir,[list[path]])

# [list[path]] <-- $(call list.path.notdir,[list[path]])

# [list[path]] <-- $(call list.path.parent,[list[path]])

# [list[path]] <-- $(call list.path.name,[list[path]])

# [list[path]] <-- $(call list.path.name.base,[list[path]])

# [list[path]] <-- $(call list.path.name.suffix,[list[path]])

# [list[path]] <-- $(call list.path.basename,[list[path]])

# [list[path]] <-- $(call list.path.suffix,[list[path]])

# [path] <-- $(call path.addprefix,[path],[path:prefix])

# [path] <-- $(call path.addsuffix,[path],[path:suffix])

# [list[path]] <-- $(call list.path.addprefix,[list[path]],[path:prefix])

# [list[path]] <-- $(call list.path.addsuffix,[list[path]],[path:suffix])

# [path] <-- $(call path.subst,[path:in],[path:find],[path:repl])

# [path] <-- $(call path.patsubst,[path:in],[path:find],[path:repl])

# [path] <-- $(call path.patsubst.dir,[path:in],[path:dir],[path:repl])

# [path] <-- $(call path.patsubst.notdir,[path:in],[path:notdir],[path:repl])

# [path] <-- $(call path.patsubst.parent,[path:in],[path:parent],[path:repl])

# [path] <-- $(call path.patsubst.name,[path:in],[path:name],[path:repl])

# [path] <-- $(call path.patsubst.name.base,[path:in],[path:name.base],[path:repl])

# [path] <-- $(call path.patsubst.basename,[path:in],[path:basename],[path:repl])

# [path] <-- $(call path.patsubst.suffix,[path:in],[path:suffix],[path:repl])

# [list[path]] <-- $(call list.path.subst,[list[path]:in],[path:find],[path:repl])

# [list[path]] <-- $(call list.path.patsubst,[list[path]:in],[path:find],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.dir,[list[path]:in],[path:dir],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.notdir,[list[path]:in],[path:notdir],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.parent,[list[path]:in],[path:parent],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.name,[list[path]:in],[path:name],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.name.base,[list[path]:in],[path:name.base],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.name.suffix,[list[path]:in],[path:name.suffix],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.basename,[list[path]:in],[path:basename],[path:repl])

# [list[path]] <-- $(call list.path.patsubst.suffix,[list[path]:in],[path:suffix],[path:repl])

# [list[path]] <-- $(call path.wildcard,[path:pattern])

# [list[path]] <-- $(call list.path.wildcard,[list[path]:patterns])

# [path] <-- $(call path.exists,[path])
$(call test,path.exists,this-file,$$(call path.exists,$$(__test.file)),$$(__test.file))
$(call test,path.exists,missing,$$(call path.exists,t.path.exists.none),)

# [path] <-- $(call file.exists,[path])

# [path] <-- $(call dir.exists,[path])

# [list[path]] <-- $(call list.path.exists,[list[path]])

# [list[path]] <-- $(call list.file.exists,[list[path]])

# [list[path]] <-- $(call list.dir.exists,[list[path]])




#===============================================================================
# INTEGERS
#===============================================================================
# {int} <-- $(call int.trim,[int])
$(call test,int.trim,zeros,$$(call int.trim,-007),-7)
$(call test,int.trim,negative-zero,$$(call int.trim,-00),0)
$(call test,int.trim,empty,$$(call int.trim,),0)

# {list{digit|-}} <-- $(call digits.add,[list{digit|-}:A],[list{digit|-}:B])

# {list{digit|-}} <-- $(call digits.sub,[list{digit|-}:A],[list{digit|-}:B])

# {int} <-- $(call int.abs,[int])

# {int} <-- $(call int.neg,[int])

# {int} <-- $(call int.add,[int:A],[int:B])
$(call test,int.add,carry,$$(call int.add,95,7),102)
$(call test,int.add,negative,$$(call int.add,-01,9),8)
$(call test,int.add,empty,$$(call int.add,,),0)

# {int} <-- $(call int.sub,[int:A],[int:B])
$(call test,int.sub,negative-result,$$(call int.sub,3,10),-7)

# {int} <-- $(call int.max,[int:A],[int:B])

# {int} <-- $(call int.min,[int:A],[int:B])

# [bool:A] <-- $(call int.equ.0,[int:A])

# [bool:A] <-- $(call int.neq.0,[int:A])

# [bool:A] <-- $(call int.gtr.0,[int:A])

# [bool:A] <-- $(call int.geq.0,[int:A])

# [bool:A] <-- $(call int.leq.0,[int:A])

# [bool:A] <-- $(call int.lss.0,[int:A])

# [bool:A] <-- $(call int.equ,[int:A],[int:B])

# [bool:A] <-- $(call int.neq,[int:A],[int:B])

# [bool:A] <-- $(call int.gtr,[int:A],[int:B])

# [bool:A] <-- $(call int.geq,[int:A],[int:B])

# [bool:A] <-- $(call int.leq,[int:A],[int:B])

# [bool:A] <-- $(call int.lss,[int:A],[int:B])
$(call test,int.lss,true,$$(call int.lss,-1,2),-1)
$(call test,int.lss,false,$$(call int.lss,5,2),)
$(call test,int.lss,equal,$$(call int.lss,2,2),)




#===============================================================================
# EXPRESSIONS
#===============================================================================
# [str] <-- $(call expr.expand,[expr[str]])
$(call test,expr.expand,reference,$$(call expr.expand,$$$$(char.comma)),$$c)
$(call test,expr.expand,alias,$$(call expr.expand,a$$$$sb),a$$sb)

# [expr[str]] <-- $(call expr.str,[str])

# [list[expr[str]]] <-- $(call expr.list,[list[str]])

# [expr[str]] <-- $(call expr.var,[expr[var]:name],[expr[word]:find],[expr[str]:repl])

# [list[expr[str]]] <-- $(call expr.vars,[list[var]])

# [expr[str]] <-- $(call expr.builtin,{expr[builtin]:name},[expr:1],[expr:2],...,[expr:8])

# [expr[str]] <-- $(call expr.call,{expr[func]:name},[expr:1],[expr:2],...,[expr:7])

# [expr[str]] <-- $(call expr.if,[expr:cond],[expr:ifnonempty],[expr:ifempty])

# [expr[str]] <-- $(call expr.or,[expr:1],[expr:2],...,[expr:8])

# [expr[str]] <-- $(call expr.and,[expr:1],[expr:2],...,[expr:8])

# [expr[str]] <-- $(call expr.foreach,[expr[var]],[expr[list]:in],[expr[str](var)])

# [expr[str]] <-- $(call expr.subst,[expr:from],[expr:to],[expr[str]:in])

# [expr[str]] <-- $(call expr.strip,[expr[str]:in])

# [expr[empty]] <-- $(call expr.assign,[list[expr]:directives],[expr[var]:name],[expr:assign_operator],[expr:value])

# [expr[empty]] <-- $(call expr.target,[expr[multipath]:targets],[expr[multipath]:prereqs],[expr[multipath]:orderonly],[expr[multipath]:prereqs_of],[expr[multipath]:orderonly_of],[list[expr]:assignments],[list[expr]:commands])




#===============================================================================
# SHELL
#===============================================================================
# [empty] <-- $(call shell.push,[path:shell],[str:flags])

# [empty] <-- $(call shell.pop)

# [str:stdout] <-- $(call shell.run,[str:command],[var:exitcode],[path:shell],[str:flags])
$(call test,shell.run,stdout,$$(call shell.run,echo hello),hello)
$(call test,shell.run,exitcode,$$(call shell.run,exit 3,t.shell.run.code)$$(t.shell.run.code),3)

# [bool:success] <-- $(call shell.test,[str:command],[var:stdout],[path:shell],[str:flags])




#===============================================================================
# FILES
#===============================================================================
# [str] <-- $(call file.tee,[>>|>],[wpath],[str])
$(call test,file.tee,no-path,$$(call file.tee,,,abc),abc)




#===============================================================================
# PRINTING
#===============================================================================
# [str] <-- $(call str.indent.add,[str:multiline],[str:indent])
$(call test,str.indent.add,two-lines,$$(call str.indent.add,a$$nb,--),--a$$n--b)

# [str] <-- $(call str.indent.set,[str:multiline],[str:indent])

# {block} <-- $(call str.to.block,[type:T],[T:str],[T:pad],[left|right])

# [str] <-- $(call block.to.str,[block])

# [block] <-- $(call block.hresize,[block],[block:width],[char:pad],[extend|resize],[end|start])

# [block] <-- $(call block.vresize,[block],[block:height],[char:pad],[extend|resize],[end|start])

# [block] <-- $(call block.hreshape,[block],[block:width],[char:pad])

# [block] <-- $(call block.hstack,[block:1],[block:2],[char:pad])

# [block] <-- $(call block.vstack,[block:1],[block:2],[char:pad])

# [empty] <-- $(call print.var,{var},[str:indent],[word:col],[str:prefix],[str:suffix])

# [empty] <-- $(call print.vars,[list{var}],[str:indent],[word:col])

# [word] <-- $(call print.vars.col,[list{var}])

# [empty] <-- $(call print.break,[list{var}])

# [empty] <-- $(call print.debug,[str:message])

# [empty] <-- $(call print.trace,[str:title])

# [str] <-- $(call str.lines.wrap,[str],[str:prefix],[str:suffix])
$(call test,str.lines.wrap,two-lines,$$(call str.lines.wrap,a$$nb,<,>),<a>$$n<b>)

# [str] <-- $(call str.info.var,[var],[word:col],[empty],[str:prefix],[str:suffix])

# [str] <-- $(call msg.block,[str:header],[str:body])

# [str] <-- $(call msg.trace,[str:trace])
# [word[line]] <-- $(msg.trace)

# [str] <-- $(call msg.error,[str:title],[str:trace],[str:subject],[str:details],[list[var]:print])

# [str] <-- $(call msg.error.value,[str:trace],[str:label],[str:value],[str:details],[list[var]:print])

# [str] <-- $(call msg.error.argument,[str:trace],[idx:argnum],[str:value],[str:details],[list[var]:print])

# [str] <-- $(call msg.error.variable,[str:trace],[var],[str:details],[list[var]:print])

# [str] <-- $(call msg.error.file,[str:trace],[path],[str:details],[list[var]:print])

# [str] <-- $(call msg.error.shell,[str:trace],[str:command],[str:details],[list[var]:print])

# [empty] <-- $(call assert.value.empty,[str:value],[str:label])

# [empty] <-- $(call assert.value.nonempty,[str:value])

# [empty] <-- $(call assert.var.has.words,[str:value])

# [empty] <-- $(call assert.var.is.line,[str:value])

# [empty] <-- $(call assert.var.is.word,[str:value])

# [empty] <-- $(call assert.shell.success,[path:shell],[str:flags],[str:command])

# [empty] <-- $(call assert.shell.started,[path:shell],[str:flags],[str:command])




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
