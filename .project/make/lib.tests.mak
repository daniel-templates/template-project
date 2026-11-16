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
$(call test,chars.split,{str}-all,$$(call chars.split,{str},$$(eval __tmp:=$$(subst $$s,,$$(char.{str})))$$(__tmp)$$(eval __tmp:=)),$$(char.{str}))
$(call test,chars.split,[str]-all,$$(call chars.split,[str],$$(eval __tmp:=$$(subst $$s,,$$(char.{str})))$$(__tmp)$$(eval __tmp:=)),$$(char.{str}))
$(call test,chars.split, str-all ,$$(call chars.split, str ,$$(eval __tmp:=$$(subst $$s,,$$(char.{str})))$$(__tmp)$$(eval __tmp:=)),$$(char.{str}))
$(call test,chars.split, str ,$$(call chars.split, str ,abc),a b c)
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
$(call test,str.lower,mixed,$$(call str.lower,$$(test.tab)Hello World),$$(test.tab)hello world)
$(call test,str.lower,already,$$(call str.lower,abc),abc)
$(call test,str.lower,specials,$$(call str.lower,A1$$c%$$$$B),a1$$c%$$$$b)
$(call test,str.lower,leading-space,$$(call str.lower,$$sAB),$$sab)
$(call test,str.lower,empty,$$(call str.lower,$$(test.empty)),$$(test.empty))

# [str] <-- $(call str.upper,[str])
$(call test,str.upper,mixed,$$(call str.upper,$$(test.tab)Hello World),$$(test.tab)HELLO WORLD)
$(call test,str.upper,already,$$(call str.upper,ABC),ABC)
$(call test,str.upper,specials,$$(call str.upper,a1$$c%$$$$b),A1$$c%$$$$B)
$(call test,str.upper,leading-space,$$(call str.upper,$$sab),$$sAB)
$(call test,str.upper,empty,$$(call str.upper,$$(test.empty)),$$(test.empty))

# {uint} <-- $(call str.len,[type:T],[T:str])
$(call test,str.len,str,$$(call str.len,{str},a b),3)
$(call test,str.len,plain,$$(call str.len,{str},abc),3)
$(call test,str.len,tab-comma,$$(call str.len,{str},a$$(test.tab)b$$cc),5)
$(call test,str.len,dollar,$$(call str.len,{str},a$$$$b),3)
$(call test,str.len,empty,$$(call str.len,[str],),0)
$(call test,str.len,no-type,$$(call str.len,,a b c),3)
$(call test,str.len,no-type-empty,$$(call str.len,,),0)

# [T] <-- $(call str.sub,[type:T],[T:str],[idx:start],[uint:end])
$(call test,str.sub,middle,$$(call str.sub,{str},abcdef,2,4),bcd)
$(call test,str.sub,first,$$(call str.sub,{str},abcdef,1,1),a)
$(call test,str.sub,whole,$$(call str.sub,{str},abcdef,1,6),abcdef)
$(call test,str.sub,to-end,$$(call str.sub,{str},abcdef,3),cdef)
$(call test,str.sub,end-past,$$(call str.sub,{str},abc,2,9),bc)
$(call test,str.sub,start-past,$$(call str.sub,{str},abc,5,9),)
$(call test,str.sub,reversed,$$(call str.sub,{str},abc,3,1),)
$(call test,str.sub,no-start,$$(call str.sub,{str},abc,,2),)
$(call test,str.sub,empty,$$(call str.sub,[str],,1,2),)
$(call test,str.sub,spaces,$$(call str.sub,{str},a b c,2,4),$$sb$$s)
$(call test,str.sub,no-type,$$(call str.sub,,a b c d,2,3),b c)

# {uint} <-- $(call str.cnt,[type:T],[T:find],[T:in])
$(call test,str.cnt,no-type,$$(call str.cnt,,ab,xabyab),2)
$(call test,str.cnt,none,$$(call str.cnt,{str},z,abc),0)
$(call test,str.cnt,adjacent,$$(call str.cnt,{str},aa,aaaa),2)
$(call test,str.cnt,space,$$(call str.cnt,{str},a b,a b a b),2)
$(call test,str.cnt,dollar,$$(call str.cnt,{str},$$$$,a$$$$b$$$$),2)
$(call test,str.cnt,empty-in,$$(call str.cnt,{str},a,),0)
$(call test,str.cnt,empty-find-braced,$$(call str.cnt,{str},,),0)
$(call test,str.cnt,empty-find-bracketed,$$(call str.cnt,[str],,),1)
$(call test,str.cnt,empty-find-nonempty-in,$$(call str.cnt,[str],,abc),0)

# [bool] <-- $(call str.equ,[str:1],[str:2],[bool:case_insensitive])
$(call test,str.equ,same,$$(call str.equ,abc,abc),1)
$(call test,str.equ,different,$$(call str.equ,abc,abd),)
$(call test,str.equ,prefix,$$(call str.equ,abc,ab),)
$(call test,str.equ,both-empty,$$(call str.equ,,),1)
$(call test,str.equ,one-empty,$$(call str.equ,a,),)
$(call test,str.equ,space-vs-empty,$$(call str.equ,$$s,),)
$(call test,str.equ,case-sensitive,$$(call str.equ,ABC,abc),)
$(call test,str.equ,case-insensitive,$$(call str.equ,ABC,abc,1),1)
$(call test,str.equ,case-insensitive-different,$$(call str.equ,ABC,abd,1),)
$(call test,str.equ,flag-word,$$(call str.equ,ABC,abc,yes),1)

# [bool] <-- $(call str.neq,[str:1],[str:2],[bool:case_insensitive])
$(call test,str.neq,same,$$(call str.neq,abc,abc),)
$(call test,str.neq,different,$$(call str.neq,abc,abd),1)
$(call test,str.neq,both-empty,$$(call str.neq,,),)
$(call test,str.neq,one-empty,$$(call str.neq,a,),1)
$(call test,str.neq,case-sensitive,$$(call str.neq,ABC,abc),1)
$(call test,str.neq,case-insensitive,$$(call str.neq,ABC,abc,1),)
$(call test,str.neq,case-insensitive-different,$$(call str.neq,ABC,abd,1),1)

# [str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
$(call test,str.concat.pair,both,$$(call str.concat.pair,$$c,a,b),a$$cb)
$(call test,str.concat.pair,skip-empty,$$(call str.concat.pair,$$c,a,),a)
$(call test,str.concat.pair,skip-first,$$(call str.concat.pair,$$c,,b),b)
$(call test,str.concat.pair,both-empty,$$(call str.concat.pair,$$c,,),)
$(call test,str.concat.pair,empty-sep,$$(call str.concat.pair,,a,b),ab)
$(call test,str.concat.pair,sep-space,$$(call str.concat.pair,$$s,a,b),a b)
$(call test,str.concat.pair,sep-multichar,$$(call str.concat.pair,<->,a,b),a<->b)
$(call test,str.concat.pair,values-with-spaces,$$(call str.concat.pair,$$c,a b,c d),a b$$cc d)

# [str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])
$(call test,str.concat,two,$$(call str.concat,-,a,b),a-b)
$(call test,str.concat,all-eight,$$(call str.concat,-,1,2,3,4,5,6,7,8),1-2-3-4-5-6-7-8)
$(call test,str.concat,gaps,$$(call str.concat,-,1,,3,,5,,7,8),1-3-5-7-8)
$(call test,str.concat,leading-empty,$$(call str.concat,-,,b,c),b-c)
$(call test,str.concat,only-first,$$(call str.concat,-,a),a)
$(call test,str.concat,only-last,$$(call str.concat,-,,,,,,,,z),z)
$(call test,str.concat,all-empty,$$(call str.concat,-,,,,,,,,),)
$(call test,str.concat,empty-sep,$$(call str.concat,,a,b,c),abc)
$(call test,str.concat,sep-comma,$$(call str.concat,$$c,a,b),a$$cb)

# [word[T]] <-- $(call word.concat.pair,[type:T],[T:sep],[word[T]:1],[word[T]:2])
$(call test,word.concat.pair,basic,$$(call word.concat.pair,[str],-,a,b),a-b)
$(call test,word.concat.pair,packed,$$(call word.concat.pair,[str],$$s,a$$$$sb,c),a$$$$sb$$$$sc)
$(call test,word.concat.pair,skip-empty,$$(call word.concat.pair,[str],-,a,),a)
$(call test,word.concat.pair,both-empty,$$(call word.concat.pair,[str],-,,),$$$$e)
$(call test,word.concat.pair,no-type,$$(call word.concat.pair,,-,a b,c),a b-c)

# [str] <-- $(call str.map,[type:T],[func[T]([T:1],[str:const1],...)],[str:sep],[str:1],[str:const1],...,[str:const3])
t.str.map.wrap = $2$1$3
$(call test,str.map,upper,$$(call str.map,[str],str.upper,$$c,a$$cb$$cc),A$$cB$$cC)
$(call test,str.map,keep-empty,$$(call str.map,[str],str.upper,$$c,a$$c$$cb),A$$c$$cB)
$(call test,str.map,drop-empty,$$(call str.map,{str},str.upper,$$c,a$$c$$cb),A$$cB)
$(call test,str.map,spaces,$$(call str.map,[str],str.upper,$$c,a b$$c c d),A B$$c C D)
$(call test,str.map,sep-space,$$(call str.map,[str],str.upper,$$s,a b c),A B C)
$(call test,str.map,consts,$$(call str.map,[str],t.str.map.wrap,$$c,a$$cb,<,>),<a>$$c<b>)
$(call test,str.map,empty-in,$$(call str.map,[str],str.upper,$$c,),)

# [str] <-- $(call str.map.1,[type:T],[func[T]([T:1],[str:const1],...)],[str:sep],[str:1],[str:const1],...,[str:const4])
t.str.map.1.f = $1$2$3$4$5
$(call test,str.map.1,upper,$$(call str.map.1,[str],str.upper,$$c,a$$cb),A$$cB)
$(call test,str.map.1,consts,$$(call str.map.1,[str],t.str.map.1.f,$$c,a$$cb,1,2,3,4),a1234$$cb1234)

# [str] <-- $(call str.map.2,[type:T],[func[T]([T:1],[T:2],[str:const1],...)],[str:sep],[str:1],[str:2],[str:const1],...,[str:const4])
t.str.map.2.f = $1=$2
t.str.map.2.g = $1$2$3$4$5$6
$(call test,str.map.2,pairs,$$(call str.map.2,[str],t.str.map.2.f,$$c,a$$cb,1$$c2),a=1$$cb=2)
$(call test,str.map.2,uneven,$$(call str.map.2,[str],t.str.map.2.f,$$c,a$$cb$$cc,1),a=1$$cb=$$cc=)
$(call test,str.map.2,uneven-rev,$$(call str.map.2,[str],t.str.map.2.f,$$c,a,1$$c2),a=1$$c=2)
$(call test,str.map.2,consts,$$(call str.map.2,[str],t.str.map.2.g,$$c,a$$cb,1$$c2,-,=,+,*),a1-=+*$$cb2-=+*)

# [str] <-- $(call str.map.3,[type:T],[func[T]([T:1],[T:2],[T:3],[str:const1],...)],[str:sep],[str:1],[str:2],[str:3],[str:const1],...,[str:const4])
t.str.map.3.f = $1$2$3$4$5$6$7
$(call test,str.map.3,triples,$$(call str.map.3,[str],t.str.map.3.f,$$c,a$$cb,1$$c2,x$$cy),a1x$$cb2y)
$(call test,str.map.3,consts,$$(call str.map.3,[str],t.str.map.3.f,$$c,a$$cb,1$$c2,x$$cy,-,=,+,*),a1x-=+*$$cb2y-=+*)

# [str] <-- $(call str.map.4,[type:T],[func[T]([T:1],[T:2],[T:3],[T:4],[str:const1],...)],[str:sep],[str:1],[str:2],[str:3],[str:4],[str:const1],...,[str:const4])
t.str.map.4.f = $1$2$3$4$5$6$7$8
$(call test,str.map.4,quads,$$(call str.map.4,[str],t.str.map.4.f,$$c,a$$cb,1$$c2,x$$cy,p$$cq),a1xp$$cb2yq)
$(call test,str.map.4,consts,$$(call str.map.4,[str],t.str.map.4.f,$$c,a$$cb,1$$c2,x$$cy,p$$cq,-,=,+,*),a1xp-=+*$$cb2yq-=+*)

# [str] <-- $(call str.subst.str2str,[str:in],[str:find],[str:repl])
$(call test,str.subst.str2str,basic,$$(call str.subst.str2str,banana,an,AN),bANANa)
$(call test,str.subst.str2str,no-match,$$(call str.subst.str2str,banana,xy,Z),banana)
$(call test,str.subst.str2str,whole,$$(call str.subst.str2str,abc,abc,X),X)
$(call test,str.subst.str2str,adjacent,$$(call str.subst.str2str,aaaa,aa,b),bb)
$(call test,str.subst.str2str,empty-in,$$(call str.subst.str2str,,a,b),)
$(call test,str.subst.str2str,empty-find,$$(call str.subst.str2str,abc,,X),abc)
$(call test,str.subst.str2str,empty-repl,$$(call str.subst.str2str,banana,an,),ba)
$(call test,str.subst.str2str,space-find,$$(call str.subst.str2str,a b c,$$s,_),a_b_c)
$(call test,str.subst.str2str,dollar,$$(call str.subst.str2str,a$$cb$$(test.tab)c$$$$d,$$$$,%),a$$cb$$(test.tab)c%d)
$(call test,str.subst.str2str,hash,$$(call str.subst.str2str,a$$(test.num)b,$$(test.num),-),a-b)
$(call test,str.subst.str2str,newline,$$(call str.subst.str2str,a$$(test.lf)b,$$(test.lf),-),a-b)
$(call test,str.subst.str2str,parens,$$(call str.subst.str2str,$$(test.lparen)a$$(test.rparen),$$(test.lparen),<),<a$$(test.rparen))

# [str] <-- $(call str.subst.str2var,[str:in],[str:find],[var:repl])
t.str.subst.str2var.repl  := x y
t.str.subst.str2var.empty :=
$(call test,str.subst.str2var,basic,$$(call str.subst.str2var,a-b,-,t.str.subst.str2var.repl),ax yb)
$(call test,str.subst.str2var,empty-find,$$(call str.subst.str2var,abc,,t.str.subst.str2var.repl),abc)
$(call test,str.subst.str2var,empty-var,$$(call str.subst.str2var,a-b,-,t.str.subst.str2var.empty),ab)
$(call test,str.subst.str2var,no-var,$$(call str.subst.str2var,a-b,-,),a-b)

# [str] <-- $(call str.subst.var2str,[str:in],[var:find],[str:repl])
t.str.subst.var2str.find  := a b
t.str.subst.var2str.empty :=
$(call test,str.subst.var2str,basic,$$(call str.subst.var2str,xa by,t.str.subst.var2str.find,_),x_y)
$(call test,str.subst.var2str,no-match,$$(call str.subst.var2str,xyz,t.str.subst.var2str.find,_),xyz)
$(call test,str.subst.var2str,empty-var,$$(call str.subst.var2str,abc,t.str.subst.var2str.empty,X),abc)
$(call test,str.subst.var2str,no-var,$$(call str.subst.var2str,abc,,X),abc)
$(call test,str.subst.var2str,empty-in,$$(call str.subst.var2str,,t.str.subst.var2str.find,X),)
$(call test,str.subst.var2str,empty-in-no-var,$$(call str.subst.var2str,,,X),)
# NOTE: An empty [find] variable matches an empty [in] and returns [repl]; str2str returns [in] here.
$(call test,str.subst.var2str,empty-in-empty-var,$$(call str.subst.var2str,,t.str.subst.var2str.empty,X),X)

# [str] <-- $(call str.subst.var2var,[str:in],[var:find],[var:repl])
t.str.subst.var2var.find  := a b
t.str.subst.var2var.repl  := c,d
t.str.subst.var2var.empty :=
$(call test,str.subst.var2var,basic,$$(call str.subst.var2var,xa by,t.str.subst.var2var.find,t.str.subst.var2var.repl),xc$$cdy)
$(call test,str.subst.var2var,empty-var,$$(call str.subst.var2var,xa by,t.str.subst.var2var.empty,t.str.subst.var2var.repl),xa by)
$(call test,str.subst.var2var,no-repl-var,$$(call str.subst.var2var,xa by,t.str.subst.var2var.find,),xa by)
$(call test,str.subst.var2var,empty-in-empty-var,$$(call str.subst.var2var,,t.str.subst.var2var.empty,t.str.subst.var2var.repl),c$$cd)

# [str] <-- $(call str.prefix.str,[str:in],[str:find],[str:prefix])
$(call test,str.prefix.str,basic,$$(call str.prefix.str,a-b-c,-,+),a+-b+-c)
$(call test,str.prefix.str,no-match,$$(call str.prefix.str,abc,-,+),abc)
$(call test,str.prefix.str,empty-find,$$(call str.prefix.str,a-b,,+),a-b)
$(call test,str.prefix.str,empty-prefix,$$(call str.prefix.str,a-b,-,),a-b)
$(call test,str.prefix.str,empty-in,$$(call str.prefix.str,,-,+),)

# [str] <-- $(call str.prefix.var,[str:in],[var:find],[str:prefix])
t.str.prefix.var.find  := a b
t.str.prefix.var.empty :=
$(call test,str.prefix.var,basic,$$(call str.prefix.var,xa by,t.str.prefix.var.find,<),x<a by)
$(call test,str.prefix.var,empty-var,$$(call str.prefix.var,xy,t.str.prefix.var.empty,<),xy)
$(call test,str.prefix.var,empty-in-empty-var,$$(call str.prefix.var,,t.str.prefix.var.empty,<),<)

# [str] <-- $(call str.suffix.str,[str:in],[str:find],[str:suffix])
$(call test,str.suffix.str,basic,$$(call str.suffix.str,a-b-c,-,+),a-+b-+c)
$(call test,str.suffix.str,no-match,$$(call str.suffix.str,abc,-,+),abc)
$(call test,str.suffix.str,empty-find,$$(call str.suffix.str,a-b,,+),a-b)
$(call test,str.suffix.str,empty-suffix,$$(call str.suffix.str,a-b,-,),a-b)
$(call test,str.suffix.str,empty-in,$$(call str.suffix.str,,-,+),)

# [str] <-- $(call str.suffix.var,[str:in],[var:find],[str:suffix])
t.str.suffix.var.find  := a b
t.str.suffix.var.empty :=
$(call test,str.suffix.var,basic,$$(call str.suffix.var,xa by,t.str.suffix.var.find,>),xa b>y)
$(call test,str.suffix.var,empty-var,$$(call str.suffix.var,xy,t.str.suffix.var.empty,>),xy)
$(call test,str.suffix.var,empty-in-empty-var,$$(call str.suffix.var,,t.str.suffix.var.empty,>),>)

# [str] <-- $(call str.wrap.str,[str:in],[str:find],[str:prefix],[str:suffix])
$(call test,str.wrap.str,basic,$$(call str.wrap.str,a-b-c,-,<,>),a<->b<->c)
$(call test,str.wrap.str,no-match,$$(call str.wrap.str,abc,-,<,>),abc)
$(call test,str.wrap.str,empty-find,$$(call str.wrap.str,a-b,,<,>),a-b)
$(call test,str.wrap.str,only-prefix,$$(call str.wrap.str,a-b,-,<,),a<-b)
$(call test,str.wrap.str,only-suffix,$$(call str.wrap.str,a-b,-,,>),a->b)
$(call test,str.wrap.str,empty-in,$$(call str.wrap.str,,-,<,>),)

# [str] <-- $(call str.wrap.var,[str:in],[var:find],[str:prefix],[str:suffix])
t.str.wrap.var.find  := a b
t.str.wrap.var.empty :=
$(call test,str.wrap.var,basic,$$(call str.wrap.var,xa by,t.str.wrap.var.find,<,>),x<a b>y)
$(call test,str.wrap.var,empty-var,$$(call str.wrap.var,xy,t.str.wrap.var.empty,<,>),xy)
# NOTE: The empty-match fallback returns only [prefix]; [suffix] is dropped.
$(call test,str.wrap.var,empty-in-empty-var,$$(call str.wrap.var,,t.str.wrap.var.empty,<,>),<)

# [str] <-- $(call str.strip.str,[str:in],[str:strip])
$(call test,str.strip.str,both,$$(call str.strip.str,xxaxx,x),a)
$(call test,str.strip.str,start-only,$$(call str.strip.str,xxa,x),a)
$(call test,str.strip.str,end-only,$$(call str.strip.str,axx,x),a)
$(call test,str.strip.str,middle-kept,$$(call str.strip.str,xaxax,x),axa)
$(call test,str.strip.str,all,$$(call str.strip.str,aaa,a),)
$(call test,str.strip.str,none,$$(call str.strip.str,abc,x),abc)
$(call test,str.strip.str,multichar,$$(call str.strip.str,ababXab,ab),X)
$(call test,str.strip.str,empty-strip,$$(call str.strip.str,abc,),abc)
$(call test,str.strip.str,empty-in,$$(call str.strip.str,,x),)
$(call test,str.strip.str,strip-with-space,$$(call str.strip.str,x yx yAx y,x y),A)
$(call test,str.strip.str,strip-spaces,$$(call str.strip.str,$$s$$sa b$$s,$$s),a b)
$(call test,str.strip.str,dollar,$$(call str.strip.str,$$$$$$$$a$$$$,$$$$),a)
$(call test,str.strip.str,comma,$$(call str.strip.str,$$ca$$c,$$c),a)

# [str] <-- $(call str.strip.str.start,[str:in],[str:strip])
$(call test,str.strip.str.start,basic,$$(call str.strip.str.start,xxaxx,x),axx)
$(call test,str.strip.str.start,all,$$(call str.strip.str.start,xx,x),)
$(call test,str.strip.str.start,none,$$(call str.strip.str.start,abc,x),abc)
$(call test,str.strip.str.start,multichar,$$(call str.strip.str.start,ababXab,ab),Xab)
$(call test,str.strip.str.start,empty-strip,$$(call str.strip.str.start,abc,),abc)
$(call test,str.strip.str.start,strip-with-space,$$(call str.strip.str.start,x yAx y,x y),Ax y)

# [str] <-- $(call str.strip.str.end,[str:in],[str:strip])
$(call test,str.strip.str.end,basic,$$(call str.strip.str.end,xxaxx,x),xxa)
$(call test,str.strip.str.end,all,$$(call str.strip.str.end,xx,x),)
$(call test,str.strip.str.end,none,$$(call str.strip.str.end,abc,x),abc)
$(call test,str.strip.str.end,multichar,$$(call str.strip.str.end,ababXab,ab),ababX)
$(call test,str.strip.str.end,empty-strip,$$(call str.strip.str.end,abc,),abc)
$(call test,str.strip.str.end,strip-with-space,$$(call str.strip.str.end,x yAx y,x y),x yA)

# [str] <-- $(call str.strip.var,[str:in],[var:strip])
t.str.strip.var.strip := a b
t.str.strip.var.empty :=
$(call test,str.strip.var,basic,$$(call str.strip.var,a ba bXa b,t.str.strip.var.strip),X)
$(call test,str.strip.var,empty-var,$$(call str.strip.var,abc,t.str.strip.var.empty),abc)

# [str] <-- $(call str.strip.var.start,[str:in],[var:strip])
$(call test,str.strip.var.start,basic,$$(call str.strip.var.start,a ba bXa b,t.str.strip.var.strip),Xa b)
$(call test,str.strip.var.start,empty-var,$$(call str.strip.var.start,abc,t.str.strip.var.empty),abc)

# [str] <-- $(call str.strip.var.end,[str:in],[var:strip])
$(call test,str.strip.var.end,basic,$$(call str.strip.var.end,a ba bXa b,t.str.strip.var.strip),a ba bX)
$(call test,str.strip.var.end,empty-var,$$(call str.strip.var.end,abc,t.str.strip.var.empty),abc)

# [str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])
$(call test,str.subst.list2str,basic,$$(call str.subst.list2str,banana,b n,X),XaXaXa)
$(call test,str.subst.list2str,single,$$(call str.subst.list2str,abc,b,X),aXc)
$(call test,str.subst.list2str,empty-list,$$(call str.subst.list2str,abc,,X),abc)
$(call test,str.subst.list2str,empty-in,$$(call str.subst.list2str,,a b,X),)
$(call test,str.subst.list2str,empty-repl,$$(call str.subst.list2str,abc,a c,),b)

# [str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])
t.str.subst.list2var.repl := x y
$(call test,str.subst.list2var,basic,$$(call str.subst.list2var,a-b,- b,t.str.subst.list2var.repl),ax yx y)
$(call test,str.subst.list2var,empty-list,$$(call str.subst.list2var,abc,,t.str.subst.list2var.repl),abc)

# [str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])
t.str.subst.vars2str.f1    := a b
t.str.subst.vars2str.f2    := ,
t.str.subst.vars2str.empty :=
$(call test,str.subst.vars2str,basic,$$(call str.subst.vars2str,xa b$$cy,t.str.subst.vars2str.f1 t.str.subst.vars2str.f2,_),x__y)
$(call test,str.subst.vars2str,empty-var-in-list,$$(call str.subst.vars2str,xa by,t.str.subst.vars2str.empty t.str.subst.vars2str.f1,_),x_y)
$(call test,str.subst.vars2str,empty-list,$$(call str.subst.vars2str,abc,,_),abc)

# [str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])
t.str.subst.vars2var.f1   := a b
t.str.subst.vars2var.f2   := ,
t.str.subst.vars2var.repl := <>
$(call test,str.subst.vars2var,basic,$$(call str.subst.vars2var,xa b$$cy,t.str.subst.vars2var.f1 t.str.subst.vars2var.f2,t.str.subst.vars2var.repl),x<><>y)
$(call test,str.subst.vars2var,empty-list,$$(call str.subst.vars2var,abc,,t.str.subst.vars2var.repl),abc)

# [str] <-- $(call str.strip.list,[str:in],[list:strip])
$(call test,str.strip.list,sequential,$$(call str.strip.list,abXab,a b),Xa)
$(call test,str.strip.list,sequential-blocked,$$(call str.strip.list,baXab,a b),aXa)
$(call test,str.strip.list,single,$$(call str.strip.list,xax,x),a)
$(call test,str.strip.list,empty-list,$$(call str.strip.list,abc,),abc)
$(call test,str.strip.list,empty-in,$$(call str.strip.list,,a),)

# [str] <-- $(call str.strip.list.start,[str:in],[list:strip])
$(call test,str.strip.list.start,basic,$$(call str.strip.list.start,abXab,a b),Xab)
$(call test,str.strip.list.start,mixed-order,$$(call str.strip.list.start,babaX,a b),X)
$(call test,str.strip.list.start,none,$$(call str.strip.list.start,Xab,a b),Xab)
$(call test,str.strip.list.start,empty-list,$$(call str.strip.list.start,abc,),abc)
$(call test,str.strip.list.start,empty-in,$$(call str.strip.list.start,,a),)
$(call test,str.strip.list.start,overlap,$$(call str.strip.list.start,aabX,ab a),X)
$(call test,str.strip.list.start,overlap-rev,$$(call str.strip.list.start,aabX,a ab),bX)

# [str] <-- $(call str.strip.list.end,[str:in],[list:strip])
$(call test,str.strip.list.end,basic,$$(call str.strip.list.end,abXab,a b),abX)
$(call test,str.strip.list.end,mixed-order,$$(call str.strip.list.end,Xabba,a b),X)
$(call test,str.strip.list.end,none,$$(call str.strip.list.end,abX,a b),abX)
$(call test,str.strip.list.end,empty-list,$$(call str.strip.list.end,abc,),abc)
$(call test,str.strip.list.end,empty-in,$$(call str.strip.list.end,,a),)

# [str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])
t.str.strip.vars.s1 := a b
t.str.strip.vars.s2 := c
$(call test,str.strip.vars,sequential,$$(call str.strip.vars,a bca bXa bc,t.str.strip.vars.s1 t.str.strip.vars.s2),a bXa b)
$(call test,str.strip.vars,empty-list,$$(call str.strip.vars,abc,),abc)

# [str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])
$(call test,str.strip.vars.start,basic,$$(call str.strip.vars.start,a bca bXa bc,t.str.strip.vars.s1 t.str.strip.vars.s2),Xa bc)
$(call test,str.strip.vars.start,empty-list,$$(call str.strip.vars.start,abc,),abc)

# [str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])
$(call test,str.strip.vars.end,basic,$$(call str.strip.vars.end,a bca bXa bc,t.str.strip.vars.s1 t.str.strip.vars.s2),a bca bX)
$(call test,str.strip.vars.end,empty-list,$$(call str.strip.vars.end,abc,),abc)

# [str] <-- $(call str.subst.list2list,[str:in],[list:find],[list:repl])
$(call test,str.subst.list2list,doc-example,\
	$$(call str.subst.list2list,<string>,i < >,<i> << >>),\
	<<str<<i>>ng>>)
$(call test,str.subst.list2list,basic,$$(call str.subst.list2list,abc,a c,1 3),1b3)
$(call test,str.subst.list2list,clobber,$$(call str.subst.list2list,ab,a b,b a),aa)
$(call test,str.subst.list2list,short-repl,$$(call str.subst.list2list,abc,a b c,1),1)
$(call test,str.subst.list2list,long-repl,$$(call str.subst.list2list,abc,a,1 2),1bc)
$(call test,str.subst.list2list,empty-lists,$$(call str.subst.list2list,abc,,),abc)
$(call test,str.subst.list2list,empty-in,$$(call str.subst.list2list,,a,1),)

# [str] <-- $(call str.subst.list2vars,[str:in],[list:find],[list{var}:repl])
t.str.subst.list2vars.r1 := x y
t.str.subst.list2vars.r2 := ,
$(call test,str.subst.list2vars,basic,$$(call str.subst.list2vars,abc,a c,t.str.subst.list2vars.r1 t.str.subst.list2vars.r2),x yb$$c)
$(call test,str.subst.list2vars,empty-lists,$$(call str.subst.list2vars,abc,,),abc)

# [str] <-- $(call str.subst.vars2list,[str:in],[list{var}:find],[list:repl])
t.str.subst.vars2list.f1 := a b
t.str.subst.vars2list.f2 := b
$(call test,str.subst.vars2list,basic,$$(call str.subst.vars2list,xa bycbz,t.str.subst.vars2list.f1 t.str.subst.vars2list.f2,1 2),x1yc2z)
$(call test,str.subst.vars2list,clobber,$$(call str.subst.vars2list,xa by,t.str.subst.vars2list.f1 t.str.subst.vars2list.f2,b 2),x2y)
$(call test,str.subst.vars2list,empty-lists,$$(call str.subst.vars2list,abc,,),abc)

# [str] <-- $(call str.subst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
t.str.subst.vars2vars.f1 := a b
t.str.subst.vars2vars.f2 := c
t.str.subst.vars2vars.r1 := <>
t.str.subst.vars2vars.r2 := -
$(call test,str.subst.vars2vars,basic,$$(call str.subst.vars2vars,xa bycz,t.str.subst.vars2vars.f1 t.str.subst.vars2vars.f2,t.str.subst.vars2vars.r1 t.str.subst.vars2vars.r2),x<>y-z)
$(call test,str.subst.vars2vars,empty-lists,$$(call str.subst.vars2vars,abc,,),abc)

# [str] <-- $(call str.prefix.list,[str:in],[list:find],[str:prefix])
$(call test,str.prefix.list,basic,$$(call str.prefix.list,abc,a c,+),+ab+c)
$(call test,str.prefix.list,empty-list,$$(call str.prefix.list,abc,,+),abc)

# [str] <-- $(call str.prefix.vars,[str:in],[list{var}:find],[str:prefix])
t.str.prefix.vars.f1 := a b
t.str.prefix.vars.f2 := c
$(call test,str.prefix.vars,basic,$$(call str.prefix.vars,xa bycz,t.str.prefix.vars.f1 t.str.prefix.vars.f2,+),x+a by+cz)
$(call test,str.prefix.vars,empty-list,$$(call str.prefix.vars,abc,,+),abc)

# [str] <-- $(call str.suffix.list,[str:in],[list:find],[str:suffix])
$(call test,str.suffix.list,basic,$$(call str.suffix.list,abc,a c,+),a+bc+)
$(call test,str.suffix.list,empty-list,$$(call str.suffix.list,abc,,+),abc)

# [str] <-- $(call str.suffix.vars,[str:in],[list{var}:find],[str:suffix])
t.str.suffix.vars.f1 := a b
t.str.suffix.vars.f2 := c
$(call test,str.suffix.vars,basic,$$(call str.suffix.vars,xa bycz,t.str.suffix.vars.f1 t.str.suffix.vars.f2,+),xa b+yc+z)
$(call test,str.suffix.vars,empty-list,$$(call str.suffix.vars,abc,,+),abc)

# [str] <-- $(call str.wrap.list,[str:in],[list:find],[str:prefix],[str:suffix])
$(call test,str.wrap.list,basic,$$(call str.wrap.list,abc,a c,<,>),<a>b<c>)
$(call test,str.wrap.list,empty-list,$$(call str.wrap.list,abc,,<,>),abc)

# [str] <-- $(call str.wrap.vars,[str:in],[list{var}:find],[str:prefix],[str:suffix])
t.str.wrap.vars.f1 := a b
t.str.wrap.vars.f2 := c
$(call test,str.wrap.vars,basic,$$(call str.wrap.vars,xa bycz,t.str.wrap.vars.f1 t.str.wrap.vars.f2,<,>),x<a b>y<c>z)
$(call test,str.wrap.vars,empty-list,$$(call str.wrap.vars,abc,,<,>),abc)

# [str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
$(call test,str.treesubst.list2list,doc-example,\
	$$(call str.treesubst.list2list,<string>,i < >,<i> << >>),\
	<<str<i>ng>>)
$(call test,str.treesubst.list2list,swap,$$(call str.treesubst.list2list,ab,a b,b a),ba)
$(call test,str.treesubst.list2list,no-clobber,$$(call str.treesubst.list2list,a,a b,b c),b)
$(call test,str.treesubst.list2list,overlap,$$(call str.treesubst.list2list,aab,ab a,X Y),YX)
$(call test,str.treesubst.list2list,overlap-rev,$$(call str.treesubst.list2list,aab,a ab,X Y),XXb)
$(call test,str.treesubst.list2list,short-repl,$$(call str.treesubst.list2list,abc,a b c,1),1)
$(call test,str.treesubst.list2list,empty-lists,$$(call str.treesubst.list2list,abc,,),abc)
$(call test,str.treesubst.list2list,empty-in,$$(call str.treesubst.list2list,,a,1),)

# [str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])
t.str.treesubst.list2vars.r1 := x y
t.str.treesubst.list2vars.r2 := <
$(call test,str.treesubst.list2vars,basic,$$(call str.treesubst.list2vars,abc,a c,t.str.treesubst.list2vars.r1 t.str.treesubst.list2vars.r2),x yb<)
$(call test,str.treesubst.list2vars,empty-lists,$$(call str.treesubst.list2vars,abc,,),abc)

# [str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])
t.str.treesubst.vars2list.f1    := a b
t.str.treesubst.vars2list.f2    := b
t.str.treesubst.vars2list.empty :=
$(call test,str.treesubst.vars2list,no-clobber,$$(call str.treesubst.vars2list,xa by,t.str.treesubst.vars2list.f1 t.str.treesubst.vars2list.f2,b 2),xby)
$(call test,str.treesubst.vars2list,empty-var-ignored,$$(call str.treesubst.vars2list,abc,t.str.treesubst.vars2list.empty t.str.treesubst.vars2list.f2,1 2),a2c)
$(call test,str.treesubst.vars2list,empty-lists,$$(call str.treesubst.vars2list,abc,,),abc)

# [str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
t.str.treesubst.vars2vars.f1 := a b
t.str.treesubst.vars2vars.f2 := c
t.str.treesubst.vars2vars.r1 := <>
t.str.treesubst.vars2vars.r2 := -
$(call test,str.treesubst.vars2vars,basic,$$(call str.treesubst.vars2vars,xa bycz,t.str.treesubst.vars2vars.f1 t.str.treesubst.vars2vars.f2,t.str.treesubst.vars2vars.r1 t.str.treesubst.vars2vars.r2),x<>y-z)
$(call test,str.treesubst.vars2vars,empty-lists,$$(call str.treesubst.vars2vars,abc,,),abc)




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
# [int] <-- $(call str.to.int,[str])
$(call test,str.to.int,(+A), $$(call str.to.int,$$s  020),   20)
$(call test,str.to.int,(-A), $$(call str.to.int,$$s -020),  -20)
$(call test,str.to.int,(+0), $$(call str.to.int,$$s  000),    0)
$(call test,str.to.int,(-0), $$(call str.to.int,$$s -000),    0)
$(call test,str.to.int,(WS), $$(call str.to.int,$$s  $$s),     )
$(call test,str.to.int,(EE), $$(call str.to.int,        ),     )
$(call test,str.to.int,(-),  $$(call str.to.int,$$s    -),     )
$(call test,str.to.int,(--), $$(call str.to.int,$$s   --),     )
$(call test,str.to.int,(-1-),$$(call str.to.int,$$s  -1-),     )
$(call test,str.to.int,(1-1),$$(call str.to.int,$$s  1-0),     )
$(call test,str.to.int,(1x1),$$(call str.to.int,$$s  1x1),     )
$(call test,str.to.int,(1W1),$$(call str.to.int,$$s  1 1),     )

# [uint] <-- $(call str.to.uint,[str])
$(call test,str.to.uint,(+A), $$(call str.to.uint,$$s  020),   20)
$(call test,str.to.uint,(-A), $$(call str.to.uint,$$s -020),     )
$(call test,str.to.uint,(+0), $$(call str.to.uint,$$s  000),    0)
$(call test,str.to.uint,(-0), $$(call str.to.uint,$$s -000),    0)
$(call test,str.to.uint,(WS), $$(call str.to.uint,$$s  $$s),     )
$(call test,str.to.uint,(EE), $$(call str.to.uint,        ),     )
$(call test,str.to.uint,(-),  $$(call str.to.uint,$$s    -),     )
$(call test,str.to.uint,(--), $$(call str.to.uint,$$s   --),     )
$(call test,str.to.uint,(-1-),$$(call str.to.uint,$$s  -1-),     )
$(call test,str.to.uint,(1-1),$$(call str.to.uint,$$s  1-0),     )
$(call test,str.to.uint,(1x1),$$(call str.to.uint,$$s  1x1),     )
$(call test,str.to.uint,(1W1),$$(call str.to.uint,$$s  1 1),     )

# [idx] <-- $(call str.to.idx,[str])
$(call test,str.to.idx,(+A), $$(call str.to.idx,$$s  020),   20)
$(call test,str.to.idx,(-A), $$(call str.to.idx,$$s -020),     )
$(call test,str.to.idx,(+0), $$(call str.to.idx,$$s  000),     )
$(call test,str.to.idx,(-0), $$(call str.to.idx,$$s -000),     )
$(call test,str.to.idx,(WS), $$(call str.to.idx,$$s  $$s),     )
$(call test,str.to.idx,(EE), $$(call str.to.idx,        ),     )
$(call test,str.to.idx,(-),  $$(call str.to.idx,$$s    -),     )
$(call test,str.to.idx,(--), $$(call str.to.idx,$$s   --),     )
$(call test,str.to.idx,(-1-),$$(call str.to.idx,$$s  -1-),     )
$(call test,str.to.idx,(1-1),$$(call str.to.idx,$$s  1-0),     )
$(call test,str.to.idx,(1x1),$$(call str.to.idx,$$s  1x1),     )
$(call test,str.to.idx,(1W1),$$(call str.to.idx,$$s  1 1),     )

# {list{digit}}   <-- $(call __digits.add,[list{digit}:A],[list{digit}:B])
# {list{digit|-}} <-- $(call __digits.sub,[list{digit}:A],[list{digit}:B])
$(call test,__digits.add,A>B,$$(call __digits.add, 0 0 3,   9 9),   1 0 2)
$(call test,__digits.add,B>A,$$(call __digits.add,   9 9, 0 0 3),   1 0 2)
$(call test,__digits.add,A=0,$$(call __digits.add,   0 0,     3),       3)

# {int} <-- $(call int.abs,[int:A])
$(call test,int.abs,(+A),$$(call int.abs,$$s  020),   20)
$(call test,int.abs,(-A),$$(call int.abs,$$s -020),   20)
$(call test,int.abs,(+0),$$(call int.abs,$$s  000),    0)
$(call test,int.abs,(-0),$$(call int.abs,$$s -000),    0)
$(call test,int.abs,(WS),$$(call int.abs,$$s  $$s),     )
$(call test,int.abs,(EE),$$(call int.abs,        ),     )

# {int} <-- $(call int.neg,[int:A])
$(call test,int.neg,(+A),$$(call int.neg,$$s  020),  -20)
$(call test,int.neg,(-A),$$(call int.neg,$$s -020),   20)
$(call test,int.neg,(+0),$$(call int.neg,$$s  000),    0)
$(call test,int.neg,(-0),$$(call int.neg,$$s -000),    0)
$(call test,int.neg,(WS),$$(call int.neg,$$s  $$s),     )
$(call test,int.neg,(EE),$$(call int.neg,        ),     )

# {int} <-- $(call int.add,[int:A],[int:B])
$(call test,int.add,(+A)+(+B),$$(call int.add,$$s   20,$$s   99),  119)
$(call test,int.add,(+A)+(-B),$$(call int.add,$$s  020,$$s  -99),  -79)
$(call test,int.add,(-A)+(+B),$$(call int.add,$$s  -20,$$s  099),   79)
$(call test,int.add,(-A)+(-B),$$(call int.add,$$s -020,$$s -099), -119)
$(call test,int.add,(+A)+(+A),$$(call int.add,$$s   20,$$s   20),   40)
$(call test,int.add,(+A)+(-A),$$(call int.add,$$s   20,$$s -020),    0)
$(call test,int.add,(-A)+(+A),$$(call int.add,$$s -020,$$s   20),    0)
$(call test,int.add,(-A)+(-A),$$(call int.add,$$s -020,$$s -020),  -40)
$(call test,int.add,(+A)+(+0),$$(call int.add,$$s   20,$$s    0),   20)
$(call test,int.add,(-0)+(-A),$$(call int.add,$$s -000,$$s  -20),  -20)
$(call test,int.add,(+A)+(WS),$$(call int.add,$$s  020,$$s  $$s),     )
$(call test,int.add,(WS)+(+B),$$(call int.add,$$s  $$s,$$s  099),     )
$(call test,int.add,(WS)+(WS),$$(call int.add,$$s  $$s,$$s  $$s),     )
$(call test,int.add,(+A)+(EE),$$(call int.add,$$s  020,        ),     )
$(call test,int.add,(EE)+(+B),$$(call int.add,        ,$$s  099),     )
$(call test,int.add,(EE)+(EE),$$(call int.add,        ,        ),     )

# {int} <-- $(call int.sub,[int:A],[int:B])
$(call test,int.sub,(+A)-(+B),$$(call int.sub,$$s   20,$$s   99),  -79)
$(call test,int.sub,(+A)-(-B),$$(call int.sub,$$s  020,$$s  -99),  119)
$(call test,int.sub,(-A)-(+B),$$(call int.sub,$$s  -20,$$s  099), -119)
$(call test,int.sub,(-A)-(-B),$$(call int.sub,$$s -020,$$s -099),   79)
$(call test,int.add,(+A)-(+A),$$(call int.sub,$$s   20,$$s   20),    0)
$(call test,int.add,(+A)-(-A),$$(call int.sub,$$s   20,$$s -020),   40)
$(call test,int.add,(-A)-(+A),$$(call int.sub,$$s -020,$$s   20),  -40)
$(call test,int.add,(-A)-(-A),$$(call int.sub,$$s -020,$$s -020),    0)
$(call test,int.sub,(+A)-(+0),$$(call int.sub,$$s   20,$$s    0),   20)
$(call test,int.sub,(-0)-(-A),$$(call int.sub,$$s -000,$$s  -20),   20)
$(call test,int.add,(+A)-(WS),$$(call int.sub,$$s  020,$$s  $$s),     )
$(call test,int.add,(WS)-(+B),$$(call int.sub,$$s  $$s,$$s  099),     )
$(call test,int.add,(WS)-(WS),$$(call int.sub,$$s  $$s,$$s  $$s),     )
$(call test,int.sub,(+A)-(EE),$$(call int.sub,$$s  020,        ),     )
$(call test,int.sub,(EE)-(+B),$$(call int.sub,        ,$$s  099),     )
$(call test,int.sub,(EE)-(EE),$$(call int.sub,        ,        ),     )

# {int} <-- $(call int.max,[int:A],[int:B])
$(call test,int.max,(+A)(+B),$$(call int.max,$$s   20,$$s   99),   99)
$(call test,int.max,(+A)(-B),$$(call int.max,$$s  020,$$s  -99),   20)
$(call test,int.max,(-A)(+B),$$(call int.max,$$s  -20,$$s  099),   99)
$(call test,int.max,(-A)(-B),$$(call int.max,$$s -020,$$s -099),  -20)
$(call test,int.max,(+A)(+A),$$(call int.max,$$s   20,$$s   20),   20)
$(call test,int.max,(+A)(-A),$$(call int.max,$$s   20,$$s -020),   20)
$(call test,int.max,(-A)(+A),$$(call int.max,$$s -020,$$s   20),   20)
$(call test,int.max,(-A)(-A),$$(call int.max,$$s -020,$$s -020),  -20)
$(call test,int.max,(+A)(+0),$$(call int.max,$$s   20,$$s    0),   20)
$(call test,int.max,(-0)(-A),$$(call int.max,$$s -000,$$s  -20),    0)
$(call test,int.max,(+A)(WS),$$(call int.max,$$s  020,$$s  $$s),     )
$(call test,int.max,(WS)(+B),$$(call int.max,$$s  $$s,$$s  099),     )
$(call test,int.max,(WS)(WS),$$(call int.max,$$s  $$s,$$s  $$s),     )
$(call test,int.max,(+A)(EE),$$(call int.max,$$s  020,        ),     )
$(call test,int.max,(EE)(+B),$$(call int.max,        ,$$s  099),     )
$(call test,int.max,(EE)(EE),$$(call int.max,        ,        ),     )

# {int} <-- $(call int.min,[int:A],[int:B])
$(call test,int.min,(+A)(+B),$$(call int.min,$$s   20,$$s   99),   20)
$(call test,int.min,(+A)(-B),$$(call int.min,$$s  020,$$s  -99),  -99)
$(call test,int.min,(-A)(+B),$$(call int.min,$$s  -20,$$s  099),  -20)
$(call test,int.min,(-A)(-B),$$(call int.min,$$s -020,$$s -099),  -99)
$(call test,int.min,(+A)(+A),$$(call int.min,$$s   20,$$s   20),   20)
$(call test,int.min,(+A)(-A),$$(call int.min,$$s   20,$$s -020),  -20)
$(call test,int.min,(-A)(+A),$$(call int.min,$$s -020,$$s   20),  -20)
$(call test,int.min,(-A)(-A),$$(call int.min,$$s -020,$$s -020),  -20)
$(call test,int.min,(+A)(+0),$$(call int.min,$$s   20,$$s    0),    0)
$(call test,int.min,(-0)(-A),$$(call int.min,$$s -000,$$s  -20),  -20)
$(call test,int.min,(+A)(WS),$$(call int.min,$$s  020,$$s  $$s),     )
$(call test,int.min,(WS)(+B),$$(call int.min,$$s  $$s,$$s  099),     )
$(call test,int.min,(WS)(WS),$$(call int.min,$$s  $$s,$$s  $$s),     )
$(call test,int.min,(+A)(EE),$$(call int.min,$$s  020,        ),     )
$(call test,int.min,(EE)(+B),$$(call int.min,        ,$$s  099),     )
$(call test,int.min,(EE)(EE),$$(call int.min,        ,        ),     )

# [bool:A] <-- $(call int.equ.0,[int:A])
$(call test,int.equ.0,(+A)==0,$$(call int.equ.0,$$s  020),        )
$(call test,int.equ.0,(-A)==0,$$(call int.equ.0,$$s -020),        )
$(call test,int.equ.0,(+0)==0,$$(call int.equ.0,$$s  000),$$s  000)
$(call test,int.equ.0,(-0)==0,$$(call int.equ.0,$$s -000),$$s -000)
$(call test,int.equ.0,(WS)==0,$$(call int.equ.0,$$s  $$s),        )
$(call test,int.equ.0,(EE)==0,$$(call int.equ.0,        ),        )

# [bool:A] <-- $(call int.neq.0,[int:A])
$(call test,int.neq.0,(+A)!=0,$$(call int.neq.0,$$s  020),$$s  020)
$(call test,int.neq.0,(-A)!=0,$$(call int.neq.0,$$s -020),$$s -020)
$(call test,int.neq.0,(+0)!=0,$$(call int.neq.0,$$s  000),        )
$(call test,int.neq.0,(-0)!=0,$$(call int.neq.0,$$s -000),        )
$(call test,int.neq.0,(WS)!=0,$$(call int.neq.0,$$s  $$s),        )
$(call test,int.neq.0,(EE)!=0,$$(call int.neq.0,        ),        )

# [bool:A] <-- $(call int.gtr.0,[int:A])
$(call test,int.gtr.0,(+A)>0,$$(call int.gtr.0,$$s  020),$$s  020)
$(call test,int.gtr.0,(-A)>0,$$(call int.gtr.0,$$s -020),        )
$(call test,int.gtr.0,(+0)>0,$$(call int.gtr.0,$$s  000),        )
$(call test,int.gtr.0,(-0)>0,$$(call int.gtr.0,$$s -000),        )
$(call test,int.gtr.0,(WS)>0,$$(call int.gtr.0,$$s  $$s),        )
$(call test,int.gtr.0,(EE)>0,$$(call int.gtr.0,        ),        )

# [bool:A] <-- $(call int.geq.0,[int:A])
$(call test,int.geq.0,(+A)>=0,$$(call int.geq.0,$$s  020),$$s  020)
$(call test,int.geq.0,(-A)>=0,$$(call int.geq.0,$$s -020),        )
$(call test,int.geq.0,(+0)>=0,$$(call int.geq.0,$$s  000),$$s  000)
$(call test,int.geq.0,(-0)>=0,$$(call int.geq.0,$$s -000),$$s -000)
$(call test,int.geq.0,(WS)>=0,$$(call int.geq.0,$$s  $$s),        )
$(call test,int.geq.0,(EE)>=0,$$(call int.geq.0,        ),        )

# [bool:A] <-- $(call int.leq.0,[int:A])
$(call test,int.leq.0,(+A)<=0,$$(call int.leq.0,$$s  020),        )
$(call test,int.leq.0,(-A)<=0,$$(call int.leq.0,$$s -020),$$s -020)
$(call test,int.leq.0,(+0)<=0,$$(call int.leq.0,$$s  000),$$s  000)
$(call test,int.leq.0,(-0)<=0,$$(call int.leq.0,$$s -000),$$s -000)
$(call test,int.leq.0,(WS)<=0,$$(call int.leq.0,$$s  $$s),        )
$(call test,int.leq.0,(EE)<=0,$$(call int.leq.0,        ),        )

# [bool:A] <-- $(call int.lss.0,[int:A])
$(call test,int.lss.0,(+A)<0,$$(call int.lss.0,$$s  020),        )
$(call test,int.lss.0,(-A)<0,$$(call int.lss.0,$$s -020),$$s -020)
$(call test,int.lss.0,(+0)<0,$$(call int.lss.0,$$s  000),        )
$(call test,int.lss.0,(-0)<0,$$(call int.lss.0,$$s -000),        )
$(call test,int.lss.0,(WS)<0,$$(call int.lss.0,$$s  $$s),        )
$(call test,int.lss.0,(EE)<0,$$(call int.lss.0,        ),        )

# [bool:A] <-- $(call int.equ,[int:A],[int:B])
$(call test,int.equ,(+A)==(+B),$$(call int.equ,$$s   20,$$s   99),        )
$(call test,int.equ,(+A)==(-B),$$(call int.equ,$$s  020,$$s  -99),        )
$(call test,int.equ,(-A)==(+B),$$(call int.equ,$$s  -20,$$s  099),        )
$(call test,int.equ,(-A)==(-B),$$(call int.equ,$$s -020,$$s -099),        )
$(call test,int.equ,(+A)==(+A),$$(call int.equ,$$s   20,$$s   20),$$s   20)
$(call test,int.equ,(+A)==(-A),$$(call int.equ,$$s   20,$$s -020),        )
$(call test,int.equ,(-A)==(+A),$$(call int.equ,$$s -020,$$s   20),        )
$(call test,int.equ,(-A)==(-A),$$(call int.equ,$$s -020,$$s -020),$$s -020)
$(call test,int.equ,(+A)==(+0),$$(call int.equ,$$s   20,$$s    0),        )
$(call test,int.equ,(-0)==(-A),$$(call int.equ,$$s -000,$$s  -20),        )
$(call test,int.equ,(+A)==(WS),$$(call int.equ,$$s  020,$$s  $$s),        )
$(call test,int.equ,(WS)==(+B),$$(call int.equ,$$s  $$s,$$s  099),        )
$(call test,int.equ,(WS)==(WS),$$(call int.equ,$$s  $$s,$$s  $$s),        )
$(call test,int.equ,(+A)==(EE),$$(call int.equ,$$s  020,        ),        )
$(call test,int.equ,(EE)==(+B),$$(call int.equ,        ,$$s  099),        )
$(call test,int.equ,(EE)==(EE),$$(call int.equ,        ,        ),        )

# [bool:A] <-- $(call int.neq,[int:A],[int:B])
$(call test,int.neq,(+A)!=(+B),$$(call int.neq,$$s   20,$$s   99),$$s   20)
$(call test,int.neq,(+A)!=(-B),$$(call int.neq,$$s  020,$$s  -99),$$s  020)
$(call test,int.neq,(-A)!=(+B),$$(call int.neq,$$s  -20,$$s  099),$$s  -20)
$(call test,int.neq,(-A)!=(-B),$$(call int.neq,$$s -020,$$s -099),$$s -020)
$(call test,int.neq,(+A)!=(+A),$$(call int.neq,$$s   20,$$s   20),        )
$(call test,int.neq,(+A)!=(-A),$$(call int.neq,$$s   20,$$s -020),$$s   20)
$(call test,int.neq,(-A)!=(+A),$$(call int.neq,$$s -020,$$s   20),$$s -020)
$(call test,int.neq,(-A)!=(-A),$$(call int.neq,$$s -020,$$s -020),        )
$(call test,int.neq,(+A)!=(+0),$$(call int.neq,$$s   20,$$s    0),$$s   20)
$(call test,int.neq,(-0)!=(-A),$$(call int.neq,$$s -000,$$s  -20),$$s -000)
$(call test,int.neq,(+A)!=(WS),$$(call int.neq,$$s  020,$$s  $$s),        )
$(call test,int.neq,(WS)!=(+B),$$(call int.neq,$$s  $$s,$$s  099),        )
$(call test,int.neq,(WS)!=(WS),$$(call int.neq,$$s  $$s,$$s  $$s),        )
$(call test,int.neq,(+A)!=(EE),$$(call int.neq,$$s  020,        ),        )
$(call test,int.neq,(EE)!=(+B),$$(call int.neq,        ,$$s  099),        )
$(call test,int.neq,(EE)!=(EE),$$(call int.neq,        ,        ),        )

# [bool:A] <-- $(call int.gtr,[int:A],[int:B])
$(call test,int.gtr,(+A)>(+B),$$(call int.gtr,$$s   20,$$s   99),        )
$(call test,int.gtr,(+A)>(-B),$$(call int.gtr,$$s  020,$$s  -99),$$s  020)
$(call test,int.gtr,(-A)>(+B),$$(call int.gtr,$$s  -20,$$s  099),        )
$(call test,int.gtr,(-A)>(-B),$$(call int.gtr,$$s -020,$$s -099),$$s -020)
$(call test,int.gtr,(+A)>(+A),$$(call int.gtr,$$s   20,$$s   20),        )
$(call test,int.gtr,(+A)>(-A),$$(call int.gtr,$$s   20,$$s -020),$$s   20)
$(call test,int.gtr,(-A)>(+A),$$(call int.gtr,$$s -020,$$s   20),        )
$(call test,int.gtr,(-A)>(-A),$$(call int.gtr,$$s -020,$$s -020),        )
$(call test,int.gtr,(+A)>(+0),$$(call int.gtr,$$s   20,$$s    0),$$s   20)
$(call test,int.gtr,(-0)>(-A),$$(call int.gtr,$$s -000,$$s  -20),$$s -000)
$(call test,int.gtr,(+A)>(WS),$$(call int.gtr,$$s  020,$$s  $$s),        )
$(call test,int.gtr,(WS)>(+B),$$(call int.gtr,$$s  $$s,$$s  099),        )
$(call test,int.gtr,(WS)>(WS),$$(call int.gtr,$$s  $$s,$$s  $$s),        )
$(call test,int.gtr,(+A)>(EE),$$(call int.gtr,$$s  020,        ),        )
$(call test,int.gtr,(EE)>(+B),$$(call int.gtr,        ,$$s  099),        )
$(call test,int.gtr,(EE)>(EE),$$(call int.gtr,        ,        ),        )

# [bool:A] <-- $(call int.geq,[int:A],[int:B])
$(call test,int.geq,(+A)>=(+B),$$(call int.geq,$$s   20,$$s   99),        )
$(call test,int.geq,(+A)>=(-B),$$(call int.geq,$$s  020,$$s  -99),$$s  020)
$(call test,int.geq,(-A)>=(+B),$$(call int.geq,$$s  -20,$$s  099),        )
$(call test,int.geq,(-A)>=(-B),$$(call int.geq,$$s -020,$$s -099),$$s -020)
$(call test,int.geq,(+A)>=(+A),$$(call int.geq,$$s   20,$$s   20),$$s   20)
$(call test,int.geq,(+A)>=(-A),$$(call int.geq,$$s   20,$$s -020),$$s   20)
$(call test,int.geq,(-A)>=(+A),$$(call int.geq,$$s -020,$$s   20),        )
$(call test,int.geq,(-A)>=(-A),$$(call int.geq,$$s -020,$$s -020),$$s -020)
$(call test,int.geq,(+A)>=(+0),$$(call int.geq,$$s   20,$$s    0),$$s   20)
$(call test,int.geq,(-0)>=(-A),$$(call int.geq,$$s -000,$$s  -20),$$s -000)
$(call test,int.geq,(+A)>=(WS),$$(call int.geq,$$s  020,$$s  $$s),        )
$(call test,int.geq,(WS)>=(+B),$$(call int.geq,$$s  $$s,$$s  099),        )
$(call test,int.geq,(WS)>=(WS),$$(call int.geq,$$s  $$s,$$s  $$s),        )
$(call test,int.geq,(+A)>=(EE),$$(call int.geq,$$s  020,        ),        )
$(call test,int.geq,(EE)>=(+B),$$(call int.geq,        ,$$s  099),        )
$(call test,int.geq,(EE)>=(EE),$$(call int.geq,        ,        ),        )

# [bool:A] <-- $(call int.leq,[int:A],[int:B])
$(call test,int.leq,(+A)<=(+B),$$(call int.leq,$$s   20,$$s   99),$$s   20)
$(call test,int.leq,(+A)<=(-B),$$(call int.leq,$$s  020,$$s  -99),        )
$(call test,int.leq,(-A)<=(+B),$$(call int.leq,$$s  -20,$$s  099),$$s  -20)
$(call test,int.leq,(-A)<=(-B),$$(call int.leq,$$s -020,$$s -099),        )
$(call test,int.leq,(+A)<=(+A),$$(call int.leq,$$s   20,$$s   20),$$s   20)
$(call test,int.leq,(+A)<=(-A),$$(call int.leq,$$s   20,$$s -020),        )
$(call test,int.leq,(-A)<=(+A),$$(call int.leq,$$s -020,$$s   20),$$s -020)
$(call test,int.leq,(-A)<=(-A),$$(call int.leq,$$s -020,$$s -020),$$s -020)
$(call test,int.leq,(+A)<=(+0),$$(call int.leq,$$s   20,$$s    0),        )
$(call test,int.leq,(-0)<=(-A),$$(call int.leq,$$s -000,$$s  -20),        )
$(call test,int.leq,(+A)<=(WS),$$(call int.leq,$$s  020,$$s  $$s),        )
$(call test,int.leq,(WS)<=(+B),$$(call int.leq,$$s  $$s,$$s  099),        )
$(call test,int.leq,(WS)<=(WS),$$(call int.leq,$$s  $$s,$$s  $$s),        )
$(call test,int.leq,(+A)<=(EE),$$(call int.leq,$$s  020,        ),        )
$(call test,int.leq,(EE)<=(+B),$$(call int.leq,        ,$$s  099),        )
$(call test,int.leq,(EE)<=(EE),$$(call int.leq,        ,        ),        )

# [bool:A] <-- $(call int.lss,[int:A],[int:B])
$(call test,int.lss,(+A)<(+B),$$(call int.lss,$$s   20,$$s   99),$$s   20)
$(call test,int.lss,(+A)<(-B),$$(call int.lss,$$s  020,$$s  -99),        )
$(call test,int.lss,(-A)<(+B),$$(call int.lss,$$s  -20,$$s  099),$$s  -20)
$(call test,int.lss,(-A)<(-B),$$(call int.lss,$$s -020,$$s -099),        )
$(call test,int.lss,(+A)<(+A),$$(call int.lss,$$s   20,$$s   20),        )
$(call test,int.lss,(+A)<(-A),$$(call int.lss,$$s   20,$$s -020),        )
$(call test,int.lss,(-A)<(+A),$$(call int.lss,$$s -020,$$s   20),$$s -020)
$(call test,int.lss,(-A)<(-A),$$(call int.lss,$$s -020,$$s -020),        )
$(call test,int.lss,(+A)<(+0),$$(call int.lss,$$s   20,$$s    0),        )
$(call test,int.lss,(-0)<(-A),$$(call int.lss,$$s -000,$$s  -20),        )
$(call test,int.lss,(+A)<(WS),$$(call int.lss,$$s  020,$$s  $$s),        )
$(call test,int.lss,(WS)<(+B),$$(call int.lss,$$s  $$s,$$s  099),        )
$(call test,int.lss,(WS)<(WS),$$(call int.lss,$$s  $$s,$$s  $$s),        )
$(call test,int.lss,(+A)<(EE),$$(call int.lss,$$s  020,        ),        )
$(call test,int.lss,(EE)<(+B),$$(call int.lss,        ,$$s  099),        )
$(call test,int.lss,(EE)<(EE),$$(call int.lss,        ,        ),        )




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
