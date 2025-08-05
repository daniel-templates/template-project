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
#  Call a function:
#
#     filename := $(this.filename)
#     list = $(call list.concat,$(COLON),item1 item2 item3)
#     $(call print.vars,filename list)
#
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
#===============================================================================






#===============================================================================
# SPECIAL CHARACTERS
#===============================================================================
EMPTY   :=
SPACE   := $(EMPTY) $(EMPTY)
TAB     := $(EMPTY)	$(EMPTY)
define LF


endef
BTICK   := `$(EMPTY)
TILDE   := ~$(EMPTY)
EXCLM   := !$(EMPTY)
AT      := @$(EMPTY)
POUND   := \#$(EMPTY)
DOLLAR  := $$$(EMPTY)
PERCENT := %$(EMPTY)
CARET   := ^$(EMPTY)
AMPER   := &$(EMPTY)
AST     := *$(EMPTY)
OPAREN  := ($(EMPTY)
CPAREN  := )$(EMPTY)
EQUAL   := =$(EMPTY)
BSLASH  := \$(EMPTY)
PIPE    := |$(EMPTY)
SEMIC   := ;$(EMPTY)
COLON   := :$(EMPTY)
SQUOTE  := '$(EMPTY)
DQUOTE  := "$(EMPTY)
COMMA   := ,$(EMPTY)
LCARET  := <$(EMPTY)
PERIOD  := .$(EMPTY)
RCARET  := >$(EMPTY)
FSLASH  := /$(EMPTY)
QUEST   := ?$(EMPTY)
OSQBKT  := [$(EMPTY)
CSQBKT  := ]$(EMPTY)
ORDBKT  := {$(EMPTY)
CRDBKT  := }$(EMPTY)

# Character sets
chr.lowers          := a b c d e f g h i j k l m n o p q r s t u v w x y z
chr.uppers          := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
chr.digits          := 0 1 2 3 4 5 6 7 8 9
chr.int             := 0 1 2 3 4 5 6 7 8 9 -
chr.whitespace      := $(SPACE)$(TAB)$(LF)
chr.whitespace.vars := SPACE TAB LF
chr.nonwhitespace   := $(chr.lowers) $(chr.uppers) $(chr.digits) ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , < . > / ?
chr.varnames        := $(chr.lowers) $(chr.uppers) $(chr.digits) ` ~ ! @    $$ % ^ & * ( ) - _   + { } [ ] \ | ;   ' " , < . > / ?
#===============================================================================






#===============================================================================
# PRINTING
#===============================================================================
# Info
#-----------------------------------------------------------
# $(call print.info,{msg},[indent])
# $(call print.vars,{vars},[indent],[col])
# $(call print.list,[list],[indent],[col])
# $(call print.debug,{msg},[indent])
# $(call print.trace,{msg},[indent])
#-----------------------------------------------------------
# Warnings
#-----------------------------------------------------------
# Errors
#-----------------------------------------------------------
# [str]   <-- $(STR.ERROR.PREFIX)          Error message line prefix
# [str]   <-- $(STR.ERROR.INDENT)          Error message line indentation
#
# {error} <-- $(call error.dynamic,[str:dynamic],[str:details])
# {error} <-- $(call error.expansion,[str:expr],[str:details])
# {error} <-- $(call error.builtin,[builtin],[str:details])
# {error} <-- $(call error.call,[fcn],[str:details])
# {error} <-- $(call error.call.arg,[fcn],[idx:argnum],[type:argtype],[word:argname],[bool:is_required],[str:argval],[str:details])
# {error} <-- $(call error.call.arg.empty,[fcn],[idx:argnum],[type:argtype],[word:argname])
# {error} <-- $(call error.call.arg.empty_or_whitespace,[fcn],[idx:argnum],[type:argtype],[word:argname])
# {error} <-- $(call error.call.arg.multiline,[fcn],[idx:argnum],[type:argtype],[word:argname],[bool:is_required])
#
# {str:message} <-- $(call str.error....,...)
#-----------------------------------------------------------
STR.INFO.PREFIX    ?= $(EMPTY)
STR.INFO.INDENT    ?= $(SPACE)$(SPACE)
STR.WARNING.PREFIX ?= >>
STR.WARNING.INDENT ?= $(STR.INFO.INDENT)
STR.ERROR.PREFIX   ?= >>
STR.ERROR.INDENT   ?= $(STR.INFO.INDENT)

TAB.SIZE           ?= $(STR.INFO.INDENT)
INDENT.COMMAND     ?= $(STR.INFO.INDENT)$(DOLLAR)$(DOLLAR)$(SPACE)

print.vars = $(if $(2),$(if $(3),$(foreach var,$(1),$(call print.var,$(var),$(2),$(3),[,])),$(call print.vars,$(1),$(2),$(call print.vars.col,$(1)))),$(call print.vars,$(1),$(STR.INFO.INDENT),$(3)))

# $(call print.var,{var},{indent},{col},{prefix},{suffix})
print.var = $(info $(2)$(call str.pad.left,$(1),$(3))=$(4)$(subst $(LF),$(5)$(LF)$(2)$(subst .,$(SPACE),$(3).)$(4),$($(1)))$(5))

# $(call print.vars.col,{vars})
print.vars.col = $(lastword $(sort $(call str.subst.list_to_str,$(chr.varnames),.,$(1))))

print.break = $(info )$(call print.vars,$(1))$(info )$(error Breakpoint reached. Exiting...)

print.debug.enable ?= false
print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $(1))))

print.trace.enable ?= false
print.trace = $(if $(findstring $(print.trace.enable),true),$(info $(LF)======= $(if $(strip $(1)),$(strip $(1)),make $@) =======))

# [str]   <-- $(call str.lines.wrap,[str],[str:prefix],[str:suffix])
str.lines.wrap = $(2)$(subst $(LF),$(3)$(LF)$(2),$(1))$(3)

# [str]   <-- $(call str.info.var,[var],[col])
str.info.var = $(if $(strip $(1)),$(call str.pad.left,$(1),$(2))=$(4)$(subst $(LF),$(5)$(LF)$(subst .,$(SPACE),$(2).)$(4),$($(1)))$(5))

# error
error.dynamic                          = $(error $(str.error.dynamic))
error.expansion                        = $(error $(str.error.expansion))
error.builtin                          = $(error $(str.error.builtin))
error.call                             = $(error $(str.error.call))
error.call.arg                         = $(error $(str.error.call.arg))
error.call.arg.empty                   = $(error $(str.error.call.arg.empty))
error.call.arg.empty_or_whitespace     = $(error $(str.error.call.arg.empty_or_whitespace))

# str.error
str.error.dynamic                      = Error $(if $(1),at $(1),{unspecified})$(if $(2),:$(subst $(LF),$(LF)$(STR.ERROR.PREFIX)$(STR.ERROR.INDENT),$(LF)$(2)))$(LF)
str.error.expansion                    = $(call str.error.dynamic,$$($(or $(strip $(1)),...)),$(2))
str.error.builtin                      = $(call str.error.expansion,$(if $(strip $(1)),$(strip $(1))...),$(2))
str.error.call                         = $(call str.error.builtin,call$(SPACE)$(or $(strip $(1)),...)$(COMMA),$(2))
str.error.call.arg                     = $(call str.error.call,$(1),Invalid argument $(if $(strip $(2)),$(strip $(2)):$(SPACE))$(if $(or $(strip $(3)),$(strip $(4))),$(if $(strip $(5)),$(ORDBKT),$(OSQBKT))$(strip $(3))$(if $(and $(strip $(3)),$(strip $(4))),:)$(strip $(4))$(if $(strip $(5)),$(CRDBKT),$(CSQBKT))$(if $(6),$(SPACE)=$(SPACE)))$(if $(6),"$(6)")$(if $(7),$(subst $(LF),$(LF)$(str.error.INDENT),$(LF)$(7))))
str.error.call.arg.empty               = $(call str.error.call.arg,$(1),$(2),$(3),$(4),true,,Cannot be empty.)
str.error.call.arg.empty_or_whitespace = $(call str.error.call.arg,$(1),$(2),$(3),$(4),true,,Cannot be empty or contain only whitespace.)
str.error.call.arg.multiline           = $(call str.error.call.arg,$(1),$(2),$(3),$(4),$(5),,Cannot contain multiple lines.)
#===============================================================================






#===============================================================================
# STRING SUBSTITUTIONS
#===============================================================================
# [str] <-- $(call str.subst.vars_to_vars,[list<var>:from],[list<var>:to],[str:in])              Many-to-Many: $(subst $([from(i)]),$([to(i)]),[in])
# [str] <-- $(call str.subst.vars_to_list,[list<var>:from],[list<word>:to],[str:in])                           $(subst $([from(i)]),  [to(i)] ,[in])
# [str] <-- $(call str.subst.list_to_vars,[list<word>:from],[list<var>:to],[str:in])                           $(subst   [from(i)] ,$([to(i)]),[in])
# [str] <-- $(call str.subst.list_to_list,[list<word>:from],[list<word>:to],[str:in])                          $(subst   [from(i)] ,  [to(i)] ,[in])
# [str] <-- $(call str.subst.vars_to_str,[list<var>:from],[str:to],[str:in])                     Many-to-One:  $(subst $([from(i)]),  [to]    ,[in])
# [str] <-- $(call str.subst.list_to_str,[list<word>:from],[str:to],[str:in])                                  $(subst   [from(i)] ,  [to]    ,[in])
# [str] <-- $(call str.subst.prefix_vars,[str:prefix],[list<var>:from],[str:in])                 Prefix Many:  $(subst $([from(i)]),[prefix]$([from(i)]),[in])
# [str] <-- $(call str.subst.prefix_list,[str:prefix],[list<word>:from],[str:in])                              $(subst   [from(i)] ,[prefix]  [from(i)] ,[in])
# [str] <-- $(call str.subst.suffix_vars,[str:suffix],[list<var>:from],[str:in])                 Suffix Many:  $(subst $([from(i)]),$([from(i)])[suffix],[in])
# [str] <-- $(call str.subst.suffix_list,[str:suffix],[list<word>:from],[str:in])                              $(subst   [from(i)] ,  [from(i)] [suffix],[in])
# [str] <-- $(call str.subst.wrap_vars,[str:prefix],[str:suffix],[list<var>:from],[str:in])      Wrap Many:    $(subst $([from(i)]),[prefix]$([from(i)])[suffix],[in])
# [str] <-- $(call str.subst.wrap_list,[str:prefix],[str:suffix],[list<word>:from],[str:in])                   $(subst   [from(i)] ,[prefix]  [from(i)] [suffix],[in])
#
# [str] <-- $(call str.lower,[str])          Returns lowercase of [str].
# [str] <-- $(call str.upper,[str])          Returns uppercase of [str].
#-----------------------------------------------------------
# Performs a series of substitutions on [str:in].
# Argument types:
#
#   [list<var>:...]    Space-separated list of variable names, or empty.
#                      Each variable in the list is expanded before substitution.
#                      This allows for substituting special characters, $(EMPTY), etc.
#   [list<word>:...]   Space-separated list of words, or empty.
#                      Each word in the list is used literally.
#                      Faster, more convenient when there are no special characters involved.
#   [str:...]          String value, or empty.
#                      May contain special characters, whitespace, etc. if expanding directly in the
#                      function call; $(call ....,$(str))  <-- expanding variable "str"
#
#-----------------------------------------------------------
str.subst.vars_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$($(firstword $(2))),$(3))),$(3))
str.subst.vars_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$(firstword $(2)),$(3))),$(3))
str.subst.list_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$($(firstword $(2))),$(3))),$(3))
str.subst.list_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$(firstword $(2)),$(3))),$(3))
str.subst.vars_to_str  = $(if $(and $(3),$(firstword $(1))),$(call str.subst.vars_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $($(firstword $(1))),$(2),$(3))),$(3))
str.subst.list_to_str  = $(if $(and $(3),$(firstword $(1))),$(call str.subst.list_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $(firstword $(1)),$(2),$(3))),$(3))
str.subst.prefix_vars  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$(1)$($(firstword $(2))),$(3))),$(3))
str.subst.prefix_list  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(1)$(firstword $(2)),$(3))),$(3))
str.subst.suffix_vars  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$($(firstword $(2)))$(1),$(3))),$(3))
str.subst.suffix_list  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(firstword $(2))$(1),$(3))),$(3))
str.subst.wrap_vars    = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_vars,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $($(firstword $(3))),$(1)$($(firstword $(3)))$(2),$(4))),$(4))
str.subst.wrap_list    = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_list,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $(firstword $(3)),$(1)$(firstword $(3))$(2),$(4))),$(4))


str.lower = $(call str.subst.list_to_list,$(chr.uppers),$(chr.lowers),$(1))
str.upper = $(call str.subst.list_to_list,$(chr.lowers),$(chr.uppers),$(1))

# word<str>  <--  $(call str.pack,[str])
str.pack                = $(str.to.word<str>)
str.to.word<str>        = $(if $(1),$(subst $(LF),$$(LF),$(subst $(TAB),$$(TAB),$(subst $(SPACE),$$(SPACE),$(subst $(DOLLAR),$$(DOLLAR),$(1))))),$$(EMPTY))

# [str]   <--  $(call word.unpack,{word<str>})
word.unpack             = $(word<str>.to.str)
word<str>.to.str        = $(if $(strip $(1)),$(subst $$(DOLLAR),$(DOLLAR),$(subst $$(SPACE),$(SPACE),$(subst $$(TAB),$(TAB),$(subst $$(LF),$(LF),$(subst $$(EMPTY),$(EMPTY),$(strip $(1))))))),$(word<str>.to.str.error))
word<str>.to.str.error  = $(call error.call.arg.empty_or_whitespace,word<str>.to.str,1)
#===============================================================================






#===============================================================================
# MULTILINE STRINGS
#===============================================================================
#-----------------------------------------------------------
# [str]  <--  $(call str.lines.pack,[str])      Escapes whitespace, '$', such that each line in [str] is a single, nonempty word.
# [str]  <--  $(call str.lines.unpack,[str])    De-escapes lines in [str].
str.lines.pack   = $(if $(1),$(subst $(LF),$$(EMPTY)$(LF),$(subst $(TAB),$$(TAB),$(subst $(SPACE),$$(SPACE),$(subst $(DOLLAR),$$(DOLLAR),$(1))))),$$(EMPTY))
str.lines.unpack = $(subst $$(DOLLAR),$(DOLLAR),$(subst $$(SPACE),$(SPACE),$(subst $$(TAB),$(TAB),$(subst $$(EMPTY),$(EMPTY),$(1)))))

# [str]  <--  $(call str.foreach.line,[str:multiline],[fcn],[str:arg2],[str:arg3],...)
str.foreach.line = $(if $(2),$(call str.lines.unpack,$(subst $(SPACE),$(LF),$(foreach line,$(call str.lines.pack,$(1)),$(call str.lines.pack,$(call $(2),$(call str.lines.unpack,$(line)),$(3),$(4),$(5),$(6),$(7),$(8),$(9)))))),$(1))

# str = $(call str.indent.byline,{indentation},{multiline_value})
# Calls $(strip) on each line to remove leading/trailing whitespace,
# then prefixes each (nonempty) line with {indentation}.
# WARNING:
#   The $(strip) operation removes consecutive whitespace from
#   the middle of the string! Escape important whitespace with:
#     $$(SPACE) $$(TAB) $$(LF)
str.indent.byline.lf := $(LF)
str.indent.byline = $(1)$(subst $$(str.indent.byline.lf),,$(subst $$(str.indent.byline.lf)$(SPACE),$(LF)$(1),$(strip $(subst $(LF)$(SPACE),$$(str.indent.byline.lf)$(SPACE),$(2)))))
#===============================================================================






#===============================================================================
# STRING PADDING
#===============================================================================
# A [pad] is a string of '.' characters used to specify the length of another string.
#
# Example:
#   pad := ..............................
#   line := Some Text
#   $(info [$(pad)])                                -->  [..............................]
#   $(info [$(str)])                                -->  [Some Text]
#   $(info [$(call line.pad.right,$(line),$(pad))]) -->  [Some Text                     ]
#   $(info [$(call line.pad.left,$(line),$(pad))])  -->  [                     Some Text]
#
#-----------------------------------------------------------
# [pad]  <-- $(call str.to.pad,[str])                      Returns a [pad] equal to the length of the longest line in [str].
# [pad]  <-- $(call line.to.pad,[line])                      length [pad] == length [line]
# [pad]  <-- $(call word.to.pad,[word])                      length [pad] == length [word]
# [pad]  <-- $(call int.to.pad,[int])                        length [pad] == length [int]
#
# [pad]  <-- $(call pad.subtract.pad,[pad],[pad])          Returns a [pad] equal to the difference in lengths of the two arguments.
# [pad]  <-- $(call pad.subtract.str,[pad],[str])            Uses length of longest line in [str]; not length of [str].
# [pad]  <-- $(call pad.subtract.line,[pad],[line])
# [pad]  <-- $(call pad.subtract.word,[pad],[word])
# [pad]  <-- $(call pad.subtract.int,[pad],[int])
#
# [str]  <-- $(call str.pad.right,[str],[pad],[char])      Right-pads each line of [str] with [char]s up to the length of [pad].
# [str]  <-- $(call str.pad.left,[str],[pad],[char])       Left-pads each line of [str]. Similar to a right-justify.
#                                                            [pad] defaults to a pad the length of the longest line in [str].
#                                                            [char] defaults to $(SPACE).
#
# [line] <-- $(call line.pad.right,[line],[pad],[char])    Same as str.pad, but optimized for various other types.
# [line] <-- $(call line.pad.left,[line],[pad],[char])
# [line] <-- $(call word.pad.right,[word],[pad],[char])
# [line] <-- $(call word.pad.left,[word],[pad],[char])
# [line] <-- $(call int.pad.right,[int],[pad],[char])
# [line] <-- $(call int.pad.left,[int],[pad],[char])
#-----------------------------------------------------------
str.to.pad        = $(lastword $(sort $(call str.subst.list_to_str,$(chr.nonwhitespace),.,$(subst $(SPACE),.,$(subst $(TAB),$(TAB.SIZE),$(1))))))
line.to.pad       = $(call str.subst.list_to_str,$(chr.nonwhitespace),.,$(subst $(SPACE),.,$(subst $(TAB),$(TAB.SIZE),$(1))))
word.to.pad       = $(call str.subst.list_to_str,$(chr.nonwhitespace),.,$(1))
int.to.pad        = $(call str.subst.list_to_str,$(chr.int),.,$(1))

pad.subtract.pad  = $(filter-out $(1),$(1:$(2)%=%))
pad.subtract.str  = $(call pad.subtract.pad,$(1),$(call str.to.pad,$(2)))
pad.subtract.line = $(call pad.subtract.pad,$(1),$(call line.to.pad,$(2)))
pad.subtract.word = $(call pad.subtract.pad,$(1),$(call word.to.pad,$(2)))
pad.subtract.int  = $(call pad.subtract.pad,$(1),$(call int.to.pad,$(2)))

str.pad.right     = $(call str.foreach.line,$(1),line.pad.right,$(or $(2),$(call str.to.pad,$(1))),$(3))
str.pad.left      = $(call str.foreach.line,$(1),line.pad.left,$(or $(2),$(call str.to.pad,$(1))),$(3))

line.pad.right    = $(subst $(TAB),$(TAB.SIZE),$(1))$(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.str,$(2),$(1)))
line.pad.left     = $(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.str,$(2),$(1)))$(subst $(TAB),$(TAB.SIZE),$(1))

word.pad.right    = $(1)$(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.word,$(2),$(1)))
word.pad.left     = $(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.word,$(2),$(1)))$(1)

int.pad.right     = $(1)$(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.int,$(2),$(1)))
int.pad.left      = $(subst .,$(or $(3),$(SPACE)),$(call pad.subtract.int,$(2),$(1)))$(1)
#===============================================================================






#===============================================================================
# FILE PATHS
#===============================================================================
# $(this.filepath)
# $(this.filename)
# $(this.dirpath)
# $(this.dirname)
#-----------------------------------------------------------
# Returns parts of the path to this makefile.
# Must be expanded BEFORE any "include..." statements!
# Use Simple (immediate) Expansion ':=' early in the file to ensure correct results.
# Ex:
#    filename := $(this.filename)
#-----------------------------------------------------------
this.filepath = $(abspath $(lastword $(MAKEFILE_LIST)))
this.filename = $(notdir $(lastword $(MAKEFILE_LIST)))
this.dirpath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
this.dirname = $(notdir $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
#===============================================================================






#===============================================================================
# BOOLEAN LOGIC
#===============================================================================
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

is.truthy = $(if $(filter $(TRUE.l),$(strip $(1))),$(TRUE.m),$(FALSE.m))
is.falsey = $(if $(filter $(FALSE.l),$(or $(strip $(1)),false)),$(TRUE.m),$(FALSE.m))
#===============================================================================






#===============================================================================
# NUMERICS
#===============================================================================
# Numeric Types
#-----------------------------------------------------------
# [int] can be any integer; positive, negative, or 0, or the empty string.
# [uint] can be any positive integer, 0, or the empty string.
#
#-----------------------------------------------------------
# Integer Math
#-----------------------------------------------------------
# [int]  <-- $(call int.inc,[int])        Increments [int] by 1. Returns empty if [int] is empty.
# [int]  <-- $(call int.dec,[int])        Decrements [int] by 1. Returns empty if [int] is empty.
# [int]  <-- $(call int.abs,[int])        Returns absolute value of [int], or empty if [int] is empty.
# [int]  <-- $(call int.neg,[int])        Returns negation of [int], or empty if [int] is empty.
#
#-----------------------------------------------------------
# Comparison (can be replaced with $(intcmp) on Make 4.4+)
#-----------------------------------------------------------
# {bool} <-- $(call int.equ,[int],[int])  Returns true (nonempty) if the arguments are equal; false (empty) if notequal or if either argument is empty.
# {bool} <-- $(call int.neq,[int],[int])  Returns true (nonempty) if the arguments are not equal; false (empty) if equal or if either argument is empty.
# {bool} <-- $(call int.equ.0,[int])      Returns true (nonempty) if [int] == 0; false (empty) if [int] != 0 or if [int] is empty.
# {bool} <-- $(call int.neq.0,[int])      Returns true (nonempty) if [int] != 0.
# {bool} <-- $(call int.gtr.0,[int])      Returns true (nonempty) if [int] >  0.
# {bool} <-- $(call int.geq.0,[int])      Returns true (nonempty) if [int] >= 0.
# {bool} <-- $(call int.leq.0,[int])      Returns true (nonempty) if [int] <= 0.
# {bool} <-- $(call int.lss.0,[int])      Returns true (nonempty) if [int] <  0.
#
#-----------------------------------------------------------
# Type Conversions
#-----------------------------------------------------------
# [uint] <-- $(call bool.to.uint,{bool})  Returns 0 if {bool} is true (nonempty); 1 if {bool} is false (empty).
# [uint] <-- $(call int.to.uint,[int])    Clamps negative [int] to 0; otherwise [int] is returned unchanged.
#-----------------------------------------------------------

# Integer Math
int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))
int.dec = $(if $(filter 0 -%,$(1)),-)$(subst .,,$(call int.$(if $(filter 0 -%,$(1)),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))

int.inc.recurse = $(if $(basename $(1)),$(if $(1:%9=),$(basename $(1))$(call digit.inc,$(suffix $(1)),.),$(if $(1),$(call int.inc.recurse,$(basename $(1))).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $(1)),.),$(if $(1),.1.0)))
int.dec.recurse = $(if $(basename $(1)),$(if $(1:%0=),$(basename $(1))$(call digit.dec,$(suffix $(1)),.),$(if $(1),$(filter-out .0,$(call int.dec.recurse,$(basename $(1)))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $(1)),.)))

# [str] <-- $(call str.digits.addprefix,[prefix],[str])
str.digits.addprefix = $(subst 9,$(1)9,$(subst 8,$(1)8,$(subst 7,$(1)7,$(subst 6,$(1)6,$(subst 5,$(1)5,$(subst 4,$(1)4,$(subst 3,$(1)3,$(subst 2,$(1)2,$(subst 1,$(1)1,$(subst 0,$(1)0,$(2)))))))))))

# {digit} <-- $(call digit.inc,[digit],[prefix])     Over/underflow wraps to 0/9. empty is treated as digit=0.
# {digit} <-- $(call digit.dec,[digit],[prefix])
digit.inc  = $(addprefix $(2),$(word 1$(1:$(2)%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
digit.dec  = $(addprefix $(2),$(word 1$(1:$(2)%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))

int.abs = $(1:-%=%)
int.neg = $(if $(1:-%=),$(if $(1:0=),-$(1),$(1)),$(1:-%=%))

# Comparison
int.equ    = $(filter $(2),$(1))
int.neq    = $(filter-out $(2),$(1))
int.equ.0  = $(filter 0,$(1))
#int.equ.0 = $(if $(1:0=),,true)
int.neq.0  = $(1:0=)
int.gtr.0  = $(filter-out 0 -%,$(1))
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
int.geq.0  = $(1:-%=)
int.leq.0  = $(filter 0 -%,$(1))
int.lss.0  = $(filter -%,$(1))
#int.lss.0 = $(if $(1:-%=),,true)


# Type Conversions
bool.to.uint = $(if $(1),0,1)
int.to.uint  = $(or $(filter-out -%,$(2)),0)
#===============================================================================






#===============================================================================
# LISTS
#===============================================================================
# List Types
#-----------------------------------------------------------
# [list]
# [list<type>]
#-----------------------------------------------------------
# {uint:len}  <--  $(call list.length,[list])                     Returns number of words in [list], or 0 if [list] is `empty` or contains only whitespace.
# [list]      <--  $(call list.trim,[list])                       Removes leading, trailing, and consecutive whitespace from [list] and replaces $(LF), $(TAB) with $(SPACE).
#                                                                 For lists of packed-word types (such as list<str>), packed-words containing `empty` value are removed.
#
#
# idx     <--  $(call list.idx,[list],[uint:idx])                 Returns idx   if (1<=idx<=len); empty otherwise.
# idx     <--  $(call list.idx.dec,[list],[uint:idx])             Returns clamp(idx-1,0,len)
# idx     <--  $(call list.idx.inc,[list],[uint:idx])             Returns clamp(idx+1,1,len+1)
# idx     <--  $(call list.idx.prev,[list],[uint:idx])            Returns idx-1 if (1<=idx-1<=len); empty otherwise.
# idx     <--  $(call list.idx.next,[list],[uint:idx])            Returns idx+1 if (1<=idx+1<=len); empty otherwise.
# idx     <--  $(call list.idx.first,[list])                      Returns 1     if list is nonempty; empty otherwise.
# idx     <--  $(call list.idx.last,[list])                       Returns len   if list is nonempty; empty otherwise.
#
# [list]  <--  $(call list.insert,[list],[uint:idx],[word])       Inserts [word] at index = [idx]. Returns the modified [list].
# [list]  <--  $(call list.insert.prev,[list],[uint:idx],[word])    index = [idx]-1
# [list]  <--  $(call list.insert.next,[list],[uint:idx],[word])    index = [idx]+1
# [list]  <--  $(call list.prepend,[list],[word])                   index = 1
# [list]  <--  $(call list.append,[list],[word])                    index = $(words [list])
#
# [list]  <--  $(call list.remove,[list],[uint:idx])              Removes word at index = [idx]. Returns the modified [list].
# [list]  <--  $(call list.remove.prev,[list],[uint:idx])           index = [idx]-1
# [list]  <--  $(call list.remove.next,[list],[uint:idx])           index = [idx]+1
# [list]  <--  $(call list.remove.first,[list])                     index = 1
# [list]  <--  $(call list.remove.last,[list])                      index = $(words [list])
#
# [word]   <--  $(call list.get,[list],[uint:idx])                Returns [word] at index = [idx].
# [word]   <--  $(call list.get.prev,[list],[uint:idx])              index = [idx]-1
# [word]   <--  $(call list.get.next,[list],[uint:idx])              index = [idx]+1
# [word]   <--  $(call list.get.first,[list])                        index = 1
# [word]   <--  $(call list.get.last,[list])                         index = $(words [list])
#
# [list]  <--  $(call list.set,[list],[uint:idx],[word])          Sets word at index = [idx] to [word]. Returns the modified [list].
# [list]  <--  $(call list.set.prev,[list],[uint:idx],[word])       index = [idx]-1.
# [list]  <--  $(call list.set.next,[list],[uint:idx],[word])       index = [idx]+1.
# [list]  <--  $(call list.set.first,[list],[word])                 index = 1.
# [list]  <--  $(call list.set.last,[list],[word])                  index = $(words [list])
#
#===============================================================================

LIST.DEFAULT.TYPE      ?= word

# list.length
list.length             = $(list<$(LIST.DEFAULT.TYPE)>.length)
list<word>.length       = $(words $(1))
list<str>.length        = $(list<word>.length)

# list.trim
list.trim               = $(list<$(LIST.DEFAULT.TYPE)>.trim)
list<word>.trim         = $(strip $(1))
list<str>.trim          = $(call list<word>.trim,$(subst $$(EMPTY),,$(1)))

# list.idx
list.idx                = $(list<$(LIST.DEFAULT.TYPE)>.idx)
list.idx.dec            = $(list<$(LIST.DEFAULT.TYPE)>.idx.dec)
list.idx.inc            = $(list<$(LIST.DEFAULT.TYPE)>.idx.inc)
list.idx.prev           = $(list<$(LIST.DEFAULT.TYPE)>.idx.prev)
list.idx.next           = $(list<$(LIST.DEFAULT.TYPE)>.idx.next)
list.idx.first          = $(list<$(LIST.DEFAULT.TYPE)>.idx.first)
list.idx.last           = $(list<$(LIST.DEFAULT.TYPE)>.idx.last)

list<word>.idx          = $(if $(and $(filter-out 0 -%,$(2)),$(word $(2),$(1))),$(2),$(EMPTY))
list<word>.idx.dec      = $(words $(wordlist 2,$(or $(filter-out -%,$(2)),0),$(1) $$))
list<word>.idx.inc      = $(words $(wordlist 1,$(or $(filter-out -%,$(2)),$(words $(1))),$(1)) $$)
list<word>.idx.prev     = $(call list<word>.idx,$(1),$(call list<word>.idx.dec,$(1),$(2)))
list<word>.idx.next     = $(call list<word>.idx,$(1),$(call list<word>.idx.inc,$(1),$(2)))
list<word>.idx.first    = $(if $(filter-out 0,$(words $(1))),1,$(EMPTY))
list<word>.idx.last     = $(filter-out 0,$(words $(1)))

list<str>.idx           = $(list<word>.idx)
list<str>.idx.dec       = $(list<word>.idx.dec)
list<str>.idx.inc       = $(list<word>.idx.inc)
list<str>.idx.prev      = $(list<word>.idx.prev)
list<str>.idx.next      = $(list<word>.idx.next)
list<str>.idx.first     = $(list<word>.idx.first)
list<str>.idx.last      = $(list<word>.idx.last)

# list.insert
list.insert             = $(list<$(LIST.DEFAULT.TYPE)>.insert)
list.insert.prev        = $(list<$(LIST.DEFAULT.TYPE)>.insert.prev)
list.insert.next        = $(list<$(LIST.DEFAULT.TYPE)>.insert.next)
list.prepend            = $(list<$(LIST.DEFAULT.TYPE)>.prepend)
list.append             = $(list<$(LIST.DEFAULT.TYPE)>.append)

list<word>.insert       = $(strip $(if $(call list<word>.idx,$(1) $$,$(2)),$(wordlist 1,$(call list<word>.idx.dec,$(1),$(2)),$(1)) $(3) $(wordlist $(2),$(words $(1)),$(1)),$(1)))
list<word>.insert.prev  = $(call list<word>.insert,$(1),$(call list<word>.idx.dec,$(1) $$,$(2)),$(3))
list<word>.insert.next  = $(call list<word>.insert,$(1),$(call list<word>.idx.inc,$$ $(1),$(2)),$(3))
list<word>.prepend      = $(strip $(2) $(1))
list<word>.append       = $(strip $(1) $(2))

list<str>.insert        = $(call list<word>.insert,$(1),$(2),$(call str.pack,$(3)))
list<str>.insert.prev   = $(call list<word>.insert.prev,$(1),$(2),$(call str.pack,$(3)))
list<str>.insert.next   = $(call list<word>.insert.next,$(1),$(2),$(call str.pack,$(3)))
list<str>.prepend       = $(call list<word>.prepend,$(1),$(call str.pack,$(2)))
list<str>.append        = $(call list<word>.append,$(1),$(call str.pack,$(2)))

# list.remove
list.remove             = $(list<$(LIST.DEFAULT.TYPE)>.remove)
list.remove.prev        = $(list<$(LIST.DEFAULT.TYPE)>.remove.prev)
list.remove.next        = $(list<$(LIST.DEFAULT.TYPE)>.remove.next)
list.remove.first       = $(list<$(LIST.DEFAULT.TYPE)>.remove.first)
list.remove.last        = $(list<$(LIST.DEFAULT.TYPE)>.remove.last)

list<word>.remove       = $(strip $(if $(call list<word>.idx,$(1),$(2)),$(wordlist 1,$(call list<word>.idx.dec,$(1),$(2)),$(1)) $(wordlist $(call list<word>.idx.inc,$(1),$(2)),$(words $(1)),$(1)),$(1)))
list<word>.remove.prev  = $(call list<word>.remove,$(1),$(call list<word>.idx.dec,$(1) $$,$(2)))
list<word>.remove.next  = $(call list<word>.remove,$(1),$(call list<word>.idx.inc,$$ $(1),$(2)))
list<word>.remove.first = $(call list<word>.remove,$(1),$(call list<word>.idx.first,$(1)))
list<word>.remove.last  = $(call list<word>.remove,$(1),$(call list<word>.idx.last,$(1)))

list<str>.remove        = $(list<$(LIST.DEFAULT.TYPE)>.remove)
list<str>.remove.prev   = $(list<$(LIST.DEFAULT.TYPE)>.remove.prev)
list<str>.remove.next   = $(list<$(LIST.DEFAULT.TYPE)>.remove.next)
list<str>.remove.first  = $(list<$(LIST.DEFAULT.TYPE)>.remove.first)
list<str>.remove.last   = $(list<$(LIST.DEFAULT.TYPE)>.remove.last)

# list.get
list.get                = $(list<$(LIST.DEFAULT.TYPE)>.get)
list.get.prev           = $(list<$(LIST.DEFAULT.TYPE)>.get.prev)
list.get.next           = $(list<$(LIST.DEFAULT.TYPE)>.get.next)
list.get.first          = $(list<$(LIST.DEFAULT.TYPE)>.get.first)
list.get.last           = $(list<$(LIST.DEFAULT.TYPE)>.get.last)

list<word>.get          = $(if $(call list<word>.idx,$(1),$(2)),$(word $(2),$(1)),$(EMPTY))
list<word>.get.prev     = $(call list<word>.get,$(1),$(call list<word>.idx.dec,$(1) $$,$(2)))
list<word>.get.next     = $(call list<word>.get,$(1),$(call list<word>.idx.inc,$$ $(1),$(2)))
list<word>.get.first    = $(firstword $(1))
list<word>.get.last     = $(lastword $(1))

list<str>.get           = $(call word.unpack,$(call list<word>.get,$(1),$(2)))
list<str>.get.prev      = $(call word.unpack,$(call list<word>.get.prev,$(1),$(2)))
list<str>.get.next      = $(call word.unpack,$(call list<word>.get.next,$(1),$(2)))
list<str>.get.first     = $(call word.unpack,$(call list<word>.get.first,$(1),$(2)))
list<str>.get.last      = $(call word.unpack,$(call list<word>.get.last,$(1),$(2)))

# list.set
list.set                = $(list<$(LIST.DEFAULT.TYPE)>.set)
list.set.prev           = $(list<$(LIST.DEFAULT.TYPE)>.set.prev)
list.set.next           = $(list<$(LIST.DEFAULT.TYPE)>.set.next)
list.set.first          = $(list<$(LIST.DEFAULT.TYPE)>.set.first)
list.set.last           = $(list<$(LIST.DEFAULT.TYPE)>.set.last)

list<word>.set          = $(strip $(if $(call list<word>.idx,$(1),$(2)),$(wordlist 1,$(call list<word>.idx.dec,$(1),$(2)),$(1)) $(3) $(wordlist $(call list<word>.idx.inc,$(1),$(2)),$(words $(1)),$(1)),$(1)))
list<word>.set.prev     = $(call list<word>.set,$(1),$(call list<word>.idx.dec,$(1) $$,$(2)),$(3))
list<word>.set.next     = $(call list<word>.set,$(1),$(call list<word>.idx.inc,$$ $(1),$(2)),$(3))
list<word>.set.first    = $(call list<word>.set,$(1),$(call list<word>.idx.first,$(1)),$(2))
list<word>.set.last     = $(call list<word>.set,$(1),$(call list<word>.idx.last,$(1)),$(2))

list<str>.set           = $(call list.set,$(1),$(2),$(call str.pack,$(3)))
list<str>.set.prev      = $(call list.set.prev,$(1),$(2),$(call str.pack,$(3)))
list<str>.set.next      = $(call list.set.next,$(1),$(2),$(call str.pack,$(3)))
list<str>.set.first     = $(call list.set.first,$(1),$(call str.pack,$(2)))
list<str>.set.last      = $(call list.set.last,$(1),$(call str.pack,$(2)))


#-----------------------------------------------------------
# newlist = $(call list.map,function,list)
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#-----------------------------------------------------------
# str = $(call list.foreach.pair,name1,list1,name2,list2,expr,[sep])
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
#   list3 = $(call list.foreach.pair,item1,$(list1),item2,$(list2),$(expr),$(sep))
#         = a1 b2 c3
#-----------------------------------------------------------
# str = $(call list.concat,sep,list)
# Concatentates a (space-separated) list of strings with the given separator.
#-----------------------------------------------------------
# str = $(call str.concat,[sep],[str1],[str2],...)
# str = $(call str.concat.pair,[sep],[str1],[str2])
# Concatentates each string argument with the given separator.
# Empty strings are skipped and no separator is included for them.
#-----------------------------------------------------------
list.map = $(foreach a,$(2),$(call $(1),$(a)))
list.foreach.pair = $(subst $(POUND),,$(subst $(POUND)$(SPACE),$(6),$(foreach __pair,$(join $(addsuffix $(POUND),$(2)),$(4)),$(subst $$($(1)),$(firstword $(subst $(POUND),$(SPACE),$(__pair))),$(subst $$($(3)),$(lastword $(subst $(POUND),$(SPACE),$(__pair))),$(5)))$(POUND))))
list.concat = $(subst $(SPACE),$(1),$(strip $(2)))
str.concat.pair = $(if $(and $(2),$(3)),$(2)$(1)$(3),$(or $(2),$(3)))
str.concat = $(if $(or $(3),$(4),$(5),$(6),$(7),$(8),$(9)),$(call str.concat.pair,$(1),$(2),$(call str.concat,$(1),$(3),$(4),$(5),$(6),$(7),$(8),$(9))),$(2))
#===============================================================================






#===============================================================================
# ITERATORS
#===============================================================================
#
# {empty} <-- $(call iter.define,{var:name},[int:start],[int:end])
#
# Returns empty. As a side effect, defines the following variables:
#
#    [int:current] <-- $({name})            Returns current value of the iterator.
#                                             Initially at [start], or '0' if [start] is empty.
#                                             Returns empty if iterator has exceeded [end].
#
#    [int:next]    <-- $({name}.next)       Increments iterator and returns the incremented value.
#                                             Returns empty if iterator == [end], or if iterator is empty.
#-----------------------------------------------------------

# {name} := [start,0]
# {name}.next = $(eval {name} := $(if $(filter-out [end],$({name})),$(call int.inc,$({name}))))$({name})
iter.define = $(eval $(1) := $(or $(2),0))$(eval $(1).next = $$(eval $(1) := $$(if $$(filter-out $(3),$$($(1))),$$(call int.inc,$$($(1)))))$$($(1)))
#===============================================================================






#===============================================================================
# DYNAMIC PROGRAMMING
#===============================================================================
#-----------------------------------------------------------
# $(call target.define,{target},\
#      [prereqs],[orderonly],\
#      [prereq_of],[orderonly_of],\
# 	COMMANDS$(LF)\
# )
#-----------------------------------------------------------
# Defines a new target.
#
#   target               name of target
#   prereqs              (space-separated) list of prerequisites
#   orderonly            (space-separated) list of order-only prereqs
#   prereq_of            adds this target as a prerequisite of each target in this list
#   orderonly_of         adds this target as an order-only prereq of each target in this list
#   COMMANDS             Recipe commands to make this target.
#
# COMMAND formatting requirements:
# - Escape runtime variables:
#     instead of $@, use $$@.
#     instead of $(VAR), use $$(VAR).
#     instead of $(func ...), use $$(func ...).
#
# - Escape consectutive whitespace characters:
#     $$(SPACE)
#     $$(TAB)
#
# - Terminate each command line with $(LF), $$(LF), $(LF)\ or $$(LF)\.
#     Line indentation is automatically corrected.
#
# Quick reference:
#	$$(basename $$@)    Name of target this pretarget belongs to
#	$$^                 List of prerequisites
#
#-----------------------------------------------------------


define target.define.template
$(subst $(LF)$(SPACE),$(LF),$(foreach target,$(4),$(target): $(strip $(1))$(LF)))
$(subst $(LF)$(SPACE),$(LF),$(foreach target,$(5),$(target): | $(strip $(1))$(LF)))
$(strip $(1): $(2) $(if $(strip $(3)),| $(strip $(3))))
$(if $(strip $(6)),$(TAB)$(subst $$(LF),$(LF)$(TAB),$(subst $$(LF)$(SPACE),$$(LF),$(strip $(subst $(LF),$$(LF)$(LF),$(subst $$(LF),$(LF),$(6)))))))
endef

target.define = $(eval $(call target.define.template,$(1),$(2),$(3),$(4),$(5),$(6)))


#-----------------------------------------------------------
# $(call target.pre.define,{target},{prereqs},\
# 	COMMANDS$(LF)\
# )
#-----------------------------------------------------------
# Defines a pretarget which runs exactly once before any of
# target's prerequisites.
#
# If target has no prerequisites, this pretarget never runs;
# To force the pretarget to run even without prereqs,
#   include {target} along with the list of its prereqs.
#
# See "target.define" for command formatting requirements.
#
# Quick reference:
#	$$(basename $$@)    Name of target this pretarget belongs to
#	$$^                 List of prerequisites
#-----------------------------------------------------------

target.pre.define = $(call target.define,$(1).pre,,,,$(2),$(3))


#-----------------------------------------------------------
# str = $(call str.eval,{expr})
#-----------------------------------------------------------
# Performs an additional $-expansion on a string.
#
# Example:
#   expr := $$(call ...)                     expr contains literal syntax '$(call ...)'
#   expr2 := $(call str.eval,$(expr))      expr2 contains the result of $(call ...)
#-----------------------------------------------------------

str.eval.tmp := $(EMPTY)
str.eval = $(eval str.eval.tmp := $(1))$(str.eval.tmp)$(eval str.eval.tmp :=)

#-----------------------------------------------------------
# str = $(call str.escape.vars,[vars],[str])
# str = $(call str.expand.vars,[vars],[str])
#-----------------------------------------------------------
# .escape      Substitutes each $(var) with literal "$(var)".
# .expand      Substitutes each literal "$(var)" with $(var).
#-----------------------------------------------------------

str.escape.vars = $(call str.subst.vars_to_list,$(1),$(foreach var,$(1),$$($(var))),$(2))
str.expand.vars = $(call str.subst.list_to_vars,$(foreach var,$(1),$$($(var))),$(1),$(2))

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


#===============================================================================
