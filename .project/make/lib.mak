#===============================================================================
# lib.mak
#
# Common library of callable "functions" for use in target definitions, etc.
#
# Usage:
#
#	Include in makefile:
#
#		include .project/make/lib.mak
#
#	Call a function:
#
#		filename := $(this.filename)
#		list = $(call concat,$(COLON),item1 item2 item3)
#		$(call print.var,filename list)
#
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


# Indentation preferences
INDENT := $(SPACE)$(SPACE)
INDENT.COMMAND := $(INDENT)$(DOLLAR)$(DOLLAR)$(SPACE)

# "Boolean" types that are printable
TRUE.p := true
FALSE.p := false

# "Boolean" types that follow make's convention for conditional evaluation
TRUE.m := true
FALSE.m := $(EMPTY)

# "Boolean" types that follow shell conventions for exitcodes (and also C language)
TRUE.s := 0
FALSE.s := 1

# "Boolean" types that are actually binary in the traditional sense
TRUE.b := 1
FALSE.b := 0

# Lists of truthy values and falsy values, for interactive purposes
TRUE.l := TRUE True true YES Yes yes Y y 1
FALSE.l := FALSE False false NO No no N n 0


#-----------------------------------------------------------
# $(this.filepath)
# $(this.filename)
# $(this.dirpath)
# $(this.dirname)
#-----------------------------------------------------------
# Returns parts of the path to this makefile.
# Must be expanded BEFORE any "include..." statements!
# Use immediate expansion := early in the file to ensure correct results.
# Ex:
#    filename := $(this.filename)
#-----------------------------------------------------------
this.filepath = $(abspath $(lastword $(MAKEFILE_LIST)))
this.filename = $(notdir $(lastword $(MAKEFILE_LIST)))
this.dirpath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
this.dirname = $(notdir $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

#-----------------------------------------------------------
# $(call is.truthy,{val})
# $(call is.falsey,{val})
#-----------------------------------------------------------
# For use in conditional evaluation.
#
# Returns $(TRUE.m) if {val} is truthy or falsey, respectively.
# Otherwise, returns $(FALSE.m).
#
# "Truthy" values are listed in $(TRUE.l).
# "Falsey" values are listed in $(FALSE.l). Empty is also considered falsey.
#-----------------------------------------------------------

is.truthy = $(if $(filter $(TRUE.l),$(strip $(1))),$(TRUE.m),$(FALSE.m))
is.falsey = $(if $(filter $(FALSE.l),$(or $(strip $(1)),false)),$(TRUE.m),$(FALSE.m))


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
# str = $(call str.expand,{expr})
#-----------------------------------------------------------
# Performs an additional $-expansion on a string.
#
# Example:
#   expr := $$(call ...)                   expr contains a single literal '$'
#   expr2 := $(call str.expand,$(expr))        expr2 contains the result of $(call ...)
#-----------------------------------------------------------

str.expand = $(eval str.expand.tmp := $(1))$(str.expand.tmp)$(eval str.expand.tmp :=)



#-----------------------------------------------------------
# str = $(call str.indent.byline,{indentation},{multiline_value})
#-----------------------------------------------------------
# Calls $(strip) on each line to remove leading/trailing whitespace,
# then prefixes each (nonempty) line with {indentation}.
#
# WARNING:
#   The $(strip) operation removes consecutive whitespace from
#   the middle of the string! Escape important whitespace with:
#     $$(SPACE)
#     $$(TAB)
#     $$(LF)
#-----------------------------------------------------------

str.indent.byline.lf := $(LF)
str.indent.byline = $(1)$(subst $$(str.indent.byline.lf),,$(subst $$(str.indent.byline.lf)$(SPACE),$(LF)$(1),$(strip $(subst $(LF)$(SPACE),$$(str.indent.byline.lf)$(SPACE),$(2)))))

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

concat = $(subst $(SPACE),$(1),$(strip $(2)))


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
# $(call pretarget.define,{target},{list of prereqs},\
# 	COMMANDS$(LF)\
# )
#-----------------------------------------------------------
# Defines a pretarget which runs exactly once before any of
# target's prerequisites.
#
# If target has no prerequisites, this pretarget never runs;
# To force pretarget to run even without prereqs, include the target name
# along with the list of its prereqs.
#
# Command formatting requirements:
#	Variables which should be evaluated at runtime should be escaped;
#	 instead of $(VAR), use $$(VAR).
#	 instead of $@, use $$@.
#
#	Each line should end with $(LF)\
#	Recipe line indentation is corrected automatically.
#
# Quick reference:
#	$$(basename $$@)	Name of target this pretarget belongs to
#	$$^					List of prerequisites
#
# WARNING:
#   Consecutive whitespace chars collapsed to a single space!
#   Replace important whitespace with:
#     $$(SPACE)
#     $$(TAB)
#     $$(LF)
#-----------------------------------------------------------




pretarget.define = $(eval $(subst $(LF)$(SPACE),$(LF),$(LF)\
	.PHONY: $(strip $(1)).pre$(LF)\
	$(strip $(2)): | $(strip $(1)).pre$(LF)\
	$(strip $(1)).pre:$(LF)\
	$(call str.indent.byline,$(TAB),$(3))$(LF)\
))


