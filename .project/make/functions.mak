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

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
TAB := $(EMPTY)	$(EMPTY)
COMMA := ,
PERCENT := %$(EMPTY)
BACKSLASH := \$(EMPTY)
POUND := \#
DOLLAR := $$
OPAREN := ($(EMPTY)
CPAREN := )$(EMPTY)
define LF


endef
INDENT := $(SPACE)$(SPACE)
INDENT.COMMAND := $(INDENT)$(DOLLAR)$(DOLLAR)$(SPACE)


#-----------------------------------------------------------
# $(call print.debug)
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
# padded_str = $(call rpad,str,col)
# padded_str = $(call lpad,str,col)
#-----------------------------------------------------------
# Pads str with whitespace so the total length is the same as col.
# Col is a sequence of "." to specify the column width.
# Example:
#   col := ..............................
#   str := Some Text
#   $(info [$(col)])                        [..............................]
#   $(info [$(str)])                        [Some Text]
#   $(info [$(call rpad,$(str),$(col))])    [Some Text                     ]
#   $(info [$(call lpad,$(str),$(col))])    [                     Some Text]
#
#-----------------------------------------------------------

__pad_subst := a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9 0 ! @ \# $$ ^ & * ( ) - _ + = [ ] { } | \ : ; " ' < , > . ? / ~ `
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

PATHSEP ?= :
pathsearch = $(firstword $(wildcard $(addsuffix /$(1),$(subst $(PATHSEP), ,$(PATH)))))



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
#
#-----------------------------------------------------------

concat = $(subst $(SPACE),$(1),$(foreach a,$(2),$(a)))


#-----------------------------------------------------------
# str = $(call concatargs,sep,[str1],[str2],...)
#-----------------------------------------------------------
# Concatentates each string argument with the given separator.
#
#-----------------------------------------------------------
concatargs = $(2)$(if $(3),$(1)$(3))$(if $(4),$(1)$(4))$(if $(5),$(1)$(5))$(if $(6),$(1)$(6))$(if $(7),$(1)$(7))$(if $(8),$(1)$(8))$(if $(9),$(1)$(9))



#-----------------------------------------------------------
# mkpath = $(call mkpath,list)
#-----------------------------------------------------------
# Concatenates a list of path segments into a single path.
# Corrects / and \ to $(FILESEP) in the final result.
#
#-----------------------------------------------------------

FILESEP ?= /
mkpath = $(subst /,$(FILESEP),$(subst $(BACKSLASH),$(FILESEP),$(call concat,$(FILESEP),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8))))



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
#-----------------------------------------------------------

define target.set_helptext
help_targets += help.$(strip $(1))
help.$(strip $(1)).shortdesc := $(subst $$@,$(strip $(1)),$(strip $(2)))
define help.$(strip $(1)).longdesc
$(subst $$@,$(strip $(1)),$(3))
endef
help.$(strip $(1)).variables := $(subst $$@,$(strip $(1)),$(strip $(4)))
endef



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


#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


