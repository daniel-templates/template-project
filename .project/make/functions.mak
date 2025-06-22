#===============================================================================
# functions.mak
#
# Common library of callable "functions" for use in target definitions, etc.
#
#===============================================================================


#===============================================================================
# UPSTREAM: daniel-templates/template-project
#===============================================================================


#-----------------------------------------------------------
# Special Characters
#-----------------------------------------------------------
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
#-----------------------------------------------------------

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
TAB := $(EMPTY)	$(EMPTY)
define LF


endef
COMMA := ,$(EMPTY)
PERCENT := %$(EMPTY)
BSLASH := \$(EMPTY)
FSLASH := /$(EMPTY)
POUND := \#$(EMPTY)
DOLLAR := $$$(EMPTY)
OPAREN := ($(EMPTY)
CPAREN := )$(EMPTY)
SQUOTE := '$(EMPTY)
DQUOTE := "$(EMPTY)
TILDE := ~$(EMPTY)
BTICK := `$(EMPTY)
COLON := :$(EMPTY)
SEMICOLON := ;$(EMPTY)
EQUAL := =$(EMPTY)
QUESTION := ?$(EMPTY)
EXC := !$(EMPTY)
AT := @$(EMPTY)
AST := *$(EMPTY)
AMPERSAND := &$(EMPTY)
PIPE := |$(EMPTY)
UCRT := ^$(EMPTY)
LCRT := <$(EMPTY)
RCRT := >$(EMPTY)
PERIOD := .$(EMPTY)
LOWERCASE := a b c d e f g h i j k l m n o p q r s t u v w x y z
UPPERCASE := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
DIGITS := 0 1 2 3 4 5 6 7 8 9

INDENT := $(SPACE)$(SPACE)
INDENT.COMMAND := $(INDENT)$(DOLLAR)$(DOLLAR)$(SPACE)

TRUE := true
FALSE := false

#-----------------------------------------------------------
# $(call print.var,[var1] [var2] ...)
#-----------------------------------------------------------
# Prints the values of one or more variables.
#-----------------------------------------------------------

print.var = $(foreach var,$(1),$(info $(INDENT)$(var)=[$($(var))]))


#-----------------------------------------------------------
# $(call print.debug,[msg])
#-----------------------------------------------------------
# Prints a debug message if print.debug.enable = true.
#-----------------------------------------------------------

print.debug.enable ?= false
print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $(1))))


#-----------------------------------------------------------
# $(call print.trace)
# $(call print.trace,[msg])
#-----------------------------------------------------------
# Prints a trace message if print.trace.enable = true.
#-----------------------------------------------------------

print.trace.enable ?= false
print.trace = $(if $(findstring $(print.trace.enable),true),$(info $(LF)======= $(if $(strip $(1)),$(strip $(1)),make $@) =======))



#-----------------------------------------------------------
# expanded_str = $(call expand,expr)
#-----------------------------------------------------------
# Performs an additional $-expansion on a string.
#
# Example:
#   expr := $$(call ...)                   expr contains a single literal '$'
#   expr2 := $(call expand,$(expr))        expr2 contains the result of $(call ...)
#-----------------------------------------------------------

expand = $(eval __expand := $(1))$(__expand)$(eval __expand :=)


#-----------------------------------------------------------
# str = $(call foreach_pair,name1,list1,name2,list2,expr,[sep])
#-----------------------------------------------------------
# Same as foreach, but iterates over two lists simultaneously.
# Returns a copy of expr for each pair of items in list1, list2.
# Within expr, the item from list1 can be referenced with $$(name1),
#   and the item from list2 can be referened with $$(name2).
# A [sep] is placed between each expr, if provided.
#
# Restrictions:
#   Lists are space-separated and cannot contain '#'.
#   Incorrect results when lists have different lengths
#
# Example:
#   list1 = a b c
#   list2 = 1 2 3
#   expr = $$(item1)$$(item2)
#   sep = $(SPACE)
#   list3 = $(call foreach_pair,item1,$(list1),item2,$(list2),$(expr),$(sep))
#         = a1 b2 c3
#-----------------------------------------------------------

foreach_pair = $(subst $(POUND),,$(subst $(POUND)$(SPACE),$(6),$(foreach __pair,$(join $(addsuffix $(POUND),$(2)),$(4)),$(subst $$($(1)),$(firstword $(subst $(POUND),$(SPACE),$(__pair))),$(subst $$($(3)),$(lastword $(subst $(POUND),$(SPACE),$(__pair))),$(5)))$(POUND))))


#-----------------------------------------------------------
# padded_str = $(call rpad,str,col)
# padded_str = $(call lpad,str,col)
#-----------------------------------------------------------
# Pads str with whitespace so the total length is the same as col.
# Col is a sequence of "." to specify the column width.
#
# Example:
#   col := ..............................
#   str := Some Text
#   $(info [$(col)])                        [..............................]
#   $(info [$(str)])                        [Some Text]
#   $(info [$(call rpad,$(str),$(col))])    [Some Text                     ]
#   $(info [$(call lpad,$(str),$(col))])    [                     Some Text]
#-----------------------------------------------------------

__pad_subst := $(LOWERCASE) $(UPPERCASE) $(DIGITS) $(EXC) $(AT) $(POUND) $(DOLLAR) $(UCRT) $(AMPERSAND) $(AST) $(OPAREN) $(CPAREN) - _ + $(EQUAL) [ ] { } $(PIPE) $(BSLASH) $(COLON) $(SEMICOLON) $(DQUOTE) $(SQUOTE) $(COMMA) $(LCRT) $(RCRT) $(PERIOD) $(QUESTION) $(FSLASH) $(TILDE) $(BTICK)
__pad_recurse = $(if $(strip $(1)),$(call __pad_recurse,$(filter-out $(firstword $(1)),$(1)),$(2),$(subst $(firstword $(1)),$(2),$(3))),$(3))
__pad_clear_if_eq = $(if $(subst $(2),,$(1)),$(1),)
rpad = $(if $(1),$(1)$(subst .,$(SPACE),$(call __pad_clear_if_eq,$(2:$(call __pad_recurse,$(__pad_subst),.,$(subst %,.,$(subst $(SPACE),.,$(1))))%=%),$(2))),$(subst .,$(SPACE),$(2)))
lpad = $(if $(1),$(subst .,$(SPACE),$(call __pad_clear_if_eq,$(2:$(call __pad_recurse,$(__pad_subst),.,$(subst %,.,$(subst $(SPACE),.,$(1))))%=%),$(2)))$(1),$(subst .,$(SPACE),$(2)))



#-----------------------------------------------------------
# filepath = $(call pathsearch,filename)
#-----------------------------------------------------------
# Finds the first instance of a file in PATH
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#-----------------------------------------------------------

sep.list ?= :
pathsearch = $(firstword $(wildcard $(addsuffix /$(1),$(subst $(sep.list), ,$(PATH)))))



#-----------------------------------------------------------
# newlist = $(call map,function,list)
#-----------------------------------------------------------
# Applies the function to each element of the (space-separated) list
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#-----------------------------------------------------------

map = $(foreach a,$(2),$(call $(1),$(a)))



#-----------------------------------------------------------
# str = $(call concat,sep,list)
#-----------------------------------------------------------
# Concatentates a (space-separated) list of strings with the given separator.
#-----------------------------------------------------------

concat = $(subst $(SPACE),$(1),$(foreach a,$(2),$(a)))


#-----------------------------------------------------------
# str = $(call concatargs,sep,[str1],[str2],...)
#-----------------------------------------------------------
# Concatentates each string argument with the given separator.
#-----------------------------------------------------------

concatargs = $(2)$(if $(3),$(1)$(3))$(if $(4),$(1)$(4))$(if $(5),$(1)$(5))$(if $(6),$(1)$(6))$(if $(7),$(1)$(7))$(if $(8),$(1)$(8))$(if $(9),$(1)$(9))



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

variable.set_with_alternatives = $(eval $(strip $(1)) $(strip $(2)) $(if $(or $(3),$(strip $(4)),$(5)),$$(or $(if $(3),$(3)$(COMMA))$(subst $(SPACE),$(COMMA),$(foreach var,$(strip $(4)),$$($(var))))$(if $(5),$(COMMA)$(5)))))



#-----------------------------------------------------------
# mkpath = $(call mkpath,list)
#-----------------------------------------------------------
# Concatenates a list of path segments into a single path.
# Corrects / and \ to $(sep.path) in the final result.
#-----------------------------------------------------------

sep.path ?= /
mkpath = $(subst /,$(sep.path),$(subst $(BSLASH),$(sep.path),$(call concat,$(sep.path),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8))))



#-----------------------------------------------------------
# $(eval $(call target.add_pretarget,target,LIST_OF_PREREQS SPACE SEPARATED,
# 	COMMANDS$$(LF)\
# ))
#-----------------------------------------------------------
# Defines a pretarget which runs exactly once before any of
# target's prerequisites.
#
# If target has no prerequisites, this pretarget never runs;
# To force pretarget to run even without prereqs, include the target name
# along with the list of its prereqs.
#
# Command formatting requirements:
#	Each line should begin with tab.
#	All $ must be escaped as $$.
#	Each line should end with $$(LF)\
#
# Quick reference:
#	$$(basename $$@)	Name of target this pretarget belongs to
#	$$^					List of prerequisites
#-----------------------------------------------------------

define target.add_pretarget
.PHONY: $(strip $(1)).pre
$(strip $(2)): | $(strip $(1)).pre
$(strip $(1)).pre:
	$(subst $$(LF)$(SPACE),$(LF)$(TAB),$(strip $(3)))
endef



#-----------------------------------------------------------
# $(eval $(call target.set_helptext,target,\
#   Short description text,\
#   Optional extended$(LF)\
#   multiline description text$(LF)\
#   ,\
#   LIST_OF_CONSUMED_VARIABLES SPACE SEPARATED
# ))
#-----------------------------------------------------------
# Stores usage info and help text for the given target.
# If a short description is provided, "make help" will print it.
# If a long description is provided, "make help.{target}" will print it.
# If a list of variable names are provided, variables and their values
#   will be printed below the long description.
#
# In any argument except 1, the literal string $@ is substituted
#   with the name of the target $(1).
# Since literal '$' must be escaped, must type "$$@".
#
# Requires target definitions from "help.mak"
#-----------------------------------------------------------

define target.set_helptext
help.definitions += help.$(strip $(1))
help.$(strip $(1)).shortdesc := $(subst $$@,$(strip $(1)),$(strip $(2)))
define help.$(strip $(1)).longdesc
$(subst $$@,$(strip $(1)),$(3))
endef
help.$(strip $(1)).variables := $(subst $$@,$(strip $(1)),$(strip $(4)))
endef


#-----------------------------------------------------------
# TARGET: help
#-----------------------------------------------------------

# Global Variables
help.colwidth ?= ........................
help.definitions ?=

# Help Text (make help.help)
$(eval $(call target.set_helptext,help,\
  Prints the top-level Make targets available in this project,\
  Targets can define help text using the "target.set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  help.colwidth\
  help.definitions\
))

# Target Definition (make help)
.PHONY: help
help:
	@$(call nop)
	$(info )
	$(info Usage:)
	$(info $(INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help.definitions)),$(if $($(tgt).shortdesc),\
	  $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(help.colwidth)) $($(tgt).shortdesc))\
	))
	$(info )



#-----------------------------------------------------------
# TARGET: help.[target]
#-----------------------------------------------------------

# Global Variables
expand ?= false

# Help Text (make help.[target]  (literally))
$(eval $(call target.set_helptext,help.[target],\
  Prints detailed info about a specific target,\
  Targets can define help text using the "target.set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  expand\
))

# Target Definition (make help.[target])
.PHONY: help.%
help.%:
	@$(call shell.nop)
	$(if $(filter $@,$(help.definitions)),\
	  $(info )\
	  $(info Usage:)\
	  $(info )\
	  $(info $(INDENT)make $(patsubst help.%,%,$@) [variable=value])\
	  $(if $($@.shortdesc),\
	    $(info )\
	    $(info $(INDENT)$($@.shortdesc))\
	  )\
	  $(if $($@.longdesc),\
	    $(info )\
	    $(info $(SPACE)$(subst $(LF)$(SPACE),$(LF)$(INDENT),$($@.longdesc)))\
	  )\
	  $(if $($@.variables),\
	    $(info )\
	    $(if $(findstring true,$(expand)),\
	      $(info $(call rpad,Variables:,....................) Values expanded recursively.)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$($(varn))])\
	      ),\
	      $(info $(call rpad,Variables:,....................) Expand values by rerunning with "expand=true".)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$(value $(varn))])\
	      )\
		)\
	  )\
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(help.definitions)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call rpad,Related Targets:,....................) For more info$(COMMA) run "make help.[target]".)\
	    $(info )\
	    $(foreach tgt,$(sort $(filter-out $@,$(help.definitions))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(help.colwidth)) $($(tgt).shortdesc))\
	      )\
	    )\
	  )\
	  $(info )\
	,\
	  $(info )\
	  $(info No information available for target "$(patsubst help.%,%,$@)".)\
	  $(info )\
	)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


