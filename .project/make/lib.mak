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
#     list = $(call list.concat,$(COL),item1 item2 item3)
#     $(call print.vars,filename list)
#
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
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
#-----------------------------------------------------------

# Empty String ======================== type: empty
override empty :=# Empty String


# Whitespace Characters =============== type: char
override char.space := $(empty) $(empty)
override char.tab   := $(empty)	$(empty)
override define char.linefeed # BEGIN: definition must contain exactly two empty lines. Do not modify.


endef # END

# Symbols ============================= type: char
override char.grave  := `
override char.tilde  := ~
override char.excl   := !
override char.commat := @
override char.num    := \#$(empty)
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
override char.bsol   := \$(empty)
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

# Aliases for Common Characters ======= type: char
override SP   := $(char.space)
override TAB  := $(char.tab)
override LF   := $(char.linefeed)
override DLR  := $(char.dollar)
override PCT  := $(char.percnt)
override CMA  := $(char.comma)
override LPAR := $(char.lparen)
override RPAR := $(char.rparen)
override QUOT := $(char.quot)
override APOS := $(char.apos)
override SOL  := $(char.sol)
override BSOL := $(char.bsol)
override COL  := $(char.colon)
override SEMI := $(char.semi)

# Character Sets ====================== type: list<char>
override char.type.lower    := a b c d e f g h i j k l m n o p q r s t u v w x y z
override char.type.upper    := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
override char.type.digit    := 0 1 2 3 4 5 6 7 8 9
override char.type.symbol   := ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , . < > / ?
override char.type.word     := $(char.type.lower) $(char.type.upper) $(char.type.digit) ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , < . > / ?
override char.type.var      := $(char.type.lower) $(char.type.upper) $(char.type.digit) ` ~ ! @    $$ % ^ & * ( ) - _   + { } [ ] \ | ;   ' " , < . > / ?
override char.type.alphanum := $(char.type.lower) $(char.type.upper) $(char.type.digit)
override char.type.letter   := $(char.type.lower) $(char.type.upper)
override char.type.int      := $(char.type.digit) -
override char.type.uint     := $(char.type.digit)

# Character Namespaces ================ type: ns<char>
override char.vars.symbol := char.grave char.tilde char.excl char.commat char.num char.dollar char.percnt char.hat char.amp \
  char.ast char.lparen char.rparen char.hyphen char.lowbar char.equals char.plus char.lsqb char.rsqb char.lcub char.rcub    \
  char.bsol char.verbar char.semi char.colon char.apos char.quot char.comma char.period char.lt char.gt char.sol char.quest
override char.vars.ws := char.space char.tab char.linefeed
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
# {error} <-- $(call error.call,[func],[str:details])
# {error} <-- $(call error.call.arg,[func],[idx:argnum],[type:argtype],[word:argname],[bool:is_required],[str:argval],[str:details])
# {error} <-- $(call error.call.arg.empty,[func],[idx:argnum],[type:argtype],[word:argname])
# {error} <-- $(call error.call.arg.empty_or_whitespace,[func],[idx:argnum],[type:argtype],[word:argname])
# {error} <-- $(call error.call.arg.multiline,[func],[idx:argnum],[type:argtype],[word:argname],[bool:is_required])
#
# {str:message} <-- $(call str.error....,...)
#-----------------------------------------------------------
STR.INFO.PREFIX    ?= $(empty)
STR.INFO.INDENT    ?= $(SP)$(SP)
STR.WARNING.PREFIX ?= >>
STR.WARNING.INDENT ?= $(STR.INFO.INDENT)
STR.ERROR.PREFIX   ?= >>
STR.ERROR.INDENT   ?= $(STR.INFO.INDENT)

TAB.SIZE           ?= $(STR.INFO.INDENT)
INDENT.COMMAND     ?= $(STR.INFO.INDENT)$(DLR)$(DLR)$(SP)

override print.vars = $(if $(2),$(if $(3),$(foreach var,$(1),$(call print.var,$(var),$(2),$(3),[,])),$(call print.vars,$(1),$(2),$(call print.vars.col,$(1)))),$(call print.vars,$(1),$(STR.INFO.INDENT),$(3)))

# $(call print.var,{var},{indent},{col},{prefix},{suffix})
override print.var = $(info $(2)$(call str.justify.left,$(1),$(3))=$(4)$(subst $(LF),$(5)$(LF)$(2)$(subst .,$(SP),$(3).)$(4),$($(1)))$(5))

# $(call print.vars.col,{vars})
override print.vars.col = $(lastword $(sort $(call str.subst.list_to_str,$(char.type.var),.,$(1))))

override print.break = $(info )$(call print.vars,$(1))$(info )$(error Breakpoint reached. Exiting...)

override print.debug.enable ?= false
override print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $(1))))

override print.trace.enable ?= false
override print.trace = $(if $(findstring $(print.trace.enable),true),$(info $(LF)======= $(if $(strip $(1)),$(strip $(1)),make $@) =======))

# [str]   <-- $(call str.lines.wrap,[str],[str:prefix],[str:suffix])
override str.lines.wrap = $(2)$(subst $(LF),$(3)$(LF)$(2),$(1))$(3)

# [str]   <-- $(call str.info.var,[var],[col])
override str.info.var = $(if $(strip $(1)),$(call str.justify.left,$(1),$(2))=$(4)$(subst $(LF),$(5)$(LF)$(subst .,$(SP),$(2).)$(4),$($(1)))$(5))

# error
override error.dynamic                          = $(error $(str.error.dynamic))
override error.expansion                        = $(error $(str.error.expansion))
override error.builtin                          = $(error $(str.error.builtin))
override error.call                             = $(error $(str.error.call))
override error.call.arg                         = $(error $(str.error.call.arg))
override error.call.arg.empty                   = $(error $(str.error.call.arg.empty))
override error.call.arg.empty_or_whitespace     = $(error $(str.error.call.arg.empty_or_whitespace))

# str.error
override str.error.dynamic                      = Error $(if $(1),at $(1),{unspecified})$(if $(2),:$(subst $(LF),$(LF)$(STR.ERROR.PREFIX)$(STR.ERROR.INDENT),$(LF)$(2)))$(LF)
override str.error.expansion                    = $(call str.error.dynamic,$$($(or $(strip $(1)),...)),$(2))
override str.error.builtin                      = $(call str.error.expansion,$(if $(strip $(1)),$(strip $(1))...),$(2))
override str.error.call                         = $(call str.error.builtin,call$(SP)$(or $(strip $(1)),...)$(CMA),$(2))
override str.error.call.arg                     = $(call str.error.call,$(1),Invalid argument $(if $(strip $(2)),$(strip $(2)):$(SP))$(if $(or $(strip $(3)),$(strip $(4))),$(if $(strip $(5)),$(char.lcub),$(char.lsqb))$(strip $(3))$(if $(and $(strip $(3)),$(strip $(4))),:)$(strip $(4))$(if $(strip $(5)),$(char.rcub),$(char.rsqb))$(if $(6),$(SP)=$(SP)))$(if $(6),"$(6)")$(if $(7),$(subst $(LF),$(LF)$(str.error.INDENT),$(LF)$(7))))
override str.error.call.arg.empty               = $(call str.error.call.arg,$(1),$(2),$(3),$(4),true,,Cannot be empty.)
override str.error.call.arg.empty_or_whitespace = $(call str.error.call.arg,$(1),$(2),$(3),$(4),true,,Cannot be empty or contain only whitespace.)
override str.error.call.arg.multiline           = $(call str.error.call.arg,$(1),$(2),$(3),$(4),$(5),,Cannot contain multiple lines.)
#===============================================================================






#===============================================================================
# STRING SUBSTITUTIONS
#===============================================================================
# Types:
#
#   [list<var>:...]    Space-separated list of variable names, or empty.
#                      Each variable in the list is expanded before substitution.
#                      This allows for substituting special characters, $(empty), etc.
#   [list:...]   Space-separated list of words, or empty.
#                      Each word in the list is used literally.
#                      Faster, more convenient when there are no special characters involved.
#   [str:...]          String value, or empty.
#                      May contain special characters, whitespace, etc. if expanding directly in the
#                      function call; $(call ....,$(str))  <-- expanding variable "str"
#-----------------------------------------------------------
# Many-to-Many:
#  [str] <-- $(call str.subst.vars_to_vars,[list<var>:from],[list<var>:to],[str:in])           Performs: $(subst $([from(i)]),$([to(i)]),[in])
#  [str] <-- $(call str.subst.vars_to_list,[list<var>:from],[list:to],[str:in])                Performs: $(subst $([from(i)]),  [to(i)] ,[in])
#  [str] <-- $(call str.subst.list_to_vars,[list:from],[list<var>:to],[str:in])                Performs: $(subst   [from(i)] ,$([to(i)]),[in])
#  [str] <-- $(call str.subst.list_to_list,[list:from],[list:to],[str:in])                     Performs: $(subst   [from(i)] ,  [to(i)] ,[in])
#
# Many-to-One:
#  [str] <-- $(call str.subst.vars_to_str,[list<var>:from],[str:to],[str:in])                  Performs: $(subst $([from(i)]),  [to]    ,[in])
#  [str] <-- $(call str.subst.list_to_str,[list:from],[str:to],[str:in])                       Performs: $(subst   [from(i)] ,  [to]    ,[in])
#
# Prefix Many:
#  [str] <-- $(call str.subst.prefix_vars,[str:prefix],[list<var>:from],[str:in])              Performs: $(subst $([from(i)]),[prefix]$([from(i)]),[in])
#  [str] <-- $(call str.subst.prefix_list,[str:prefix],[list:from],[str:in])                   Performs: $(subst   [from(i)] ,[prefix]  [from(i)] ,[in])
#
# Suffix Many:
#  [str] <-- $(call str.subst.suffix_vars,[str:suffix],[list<var>:from],[str:in])              Performs: $(subst $([from(i)]),$([from(i)])[suffix],[in])
#  [str] <-- $(call str.subst.suffix_list,[str:suffix],[list:from],[str:in])                   Performs: $(subst   [from(i)] ,  [from(i)] [suffix],[in])
#
# Wrap Many:
#  [str] <-- $(call str.subst.wrap_vars,[str:prefix],[str:suffix],[list<var>:from],[str:in])   Performs: $(subst $([from(i)]),[prefix]$([from(i)])[suffix],[in])
#  [str] <-- $(call str.subst.wrap_list,[str:prefix],[str:suffix],[list:from],[str:in])        Performs: $(subst   [from(i)] ,[prefix]  [from(i)] [suffix],[in])
#
# Type Conversions:
#  [lower]     <-- $(call str.to.lower,[str])             Returns lowercase of [str].
#  [upper]     <-- $(call str.to.upper,[str])             Returns uppercase of [str].
#  {word[str]} <-- $(call word[str].pack,[str])           Returns a nonempty {word} containing a packed [str]. Whitespace, dollar '$', and [empty] string are escaped.
#  [str]       <-- $(call word[str].unpack,{word[str]})   Unpacks a nonempty {word[str]}, restoring the original value of [str].
#-----------------------------------------------------------

# Many-to-Many ======================== type: [str]
override str.subst.vars_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$($(firstword $(2))),$(3))),$(3))
override str.subst.vars_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$(firstword $(2)),$(3))),$(3))
override str.subst.list_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$($(firstword $(2))),$(3))),$(3))
override str.subst.list_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$(firstword $(2)),$(3))),$(3))

# Many-to-One ========================= type: [str]
override str.subst.vars_to_str  = $(if $(and $(3),$(firstword $(1))),$(call str.subst.vars_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $($(firstword $(1))),$(2),$(3))),$(3))
override str.subst.list_to_str  = $(if $(and $(3),$(firstword $(1))),$(call str.subst.list_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $(firstword $(1)),$(2),$(3))),$(3))

# Prefix Many ========================= type: [str]
override str.subst.prefix_vars  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$(1)$($(firstword $(2))),$(3))),$(3))
override str.subst.prefix_list  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(1)$(firstword $(2)),$(3))),$(3))

# Suffix Many ========================= type: [str]
override str.subst.suffix_vars  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$($(firstword $(2)))$(1),$(3))),$(3))
override str.subst.suffix_list  = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(firstword $(2))$(1),$(3))),$(3))

# Wrap Many =========================== type: [str]
override str.subst.wrap_vars    = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_vars,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $($(firstword $(3))),$(1)$($(firstword $(3)))$(2),$(4))),$(4))
override str.subst.wrap_list    = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_list,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $(firstword $(3)),$(1)$(firstword $(3))$(2),$(4))),$(4))

# Type Conversions ==================== type: [lower], [upper]
override str.to.lower           = $(call str.subst.list_to_list,$(char.type.upper),$(char.type.lower),$(1))
override str.to.upper           = $(call str.subst.list_to_list,$(char.type.lower),$(char.type.upper),$(1))

#                                       type: {word[str]}, [str]
override word[str].pack         = $(if $(1),$(subst $(LF),$$(LF),$(subst $(TAB),$$(TAB),$(subst $(SP),$$(SP),$(subst $(DLR),$$(DLR),$(1))))),$$(empty))
override word[str].unpack       = $(if $(strip $(1)),$(subst $$(DLR),$(DLR),$(subst $$(SP),$(SP),$(subst $$(TAB),$(TAB),$(subst $$(LF),$(LF),$(subst $$(empty),$(empty),$(strip $(1))))))),$(word[str].unpack.error))
override word[str].unpack.error = $(call error.call.arg.empty_or_whitespace,word[str].unpack,1)
#===============================================================================






#===============================================================================
# MULTILINE STRINGS
#===============================================================================
# Multiline strings can be created using the 'define' directive or by inserting
# a linefeed character $(LF) into the string definition.
# Otherwise, string definitions may span multiple lines (each line must end with
# a '\'), but in this case linefeeds are removed and leading whitespace is
# replaced with a single $(SP).
#
# Types:
#   str       A string containing any characters.
#   line      A single line; may contain whitespace, but no linefeeds.
#   word      A single word; no whitespace.
#   [...]     Square brackets [] specify a value which is either empty or nonempty.
#   {...}     Curly brackets {} specify a value which is always nonempty.
#-----------------------------------------------------------
# [str]  <--  $(call word[line].pack,[str])      Escapes whitespace, '$', such that each line in [str] is a single, nonempty word.
# [str]  <--  $(call word[line].unpack,[str])    De-escapes lines in [str].

# Type Conversions ==================== type: {word[line]}, [line]
override word[line].pack         = $(if $(1),$(subst $(LF),$$(empty)$$(LF),$(subst $(TAB),$$(TAB),$(subst $(SP),$$(SP),$(subst $(DLR),$$(DLR),$(1))))),$$(empty))
override word[line].unpack       = $(if $(strip $(1)),$(subst $$(DLR),$(DLR),$(subst $$(SP),$(SP),$(subst $$(TAB),$(TAB),$(subst $$(empty),$(empty),$(strip $(1)))))),$(word[line].unpack.error))
override word[line].unpack.error = $(call error.call.arg.empty_or_whitespace,word[line].unpack,1)

# [str]  <--  $(call str.foreach.line,[str:multiline],[func],[str:arg2],[str:arg3],...)
override str.foreach.line = $(if $(2),$(call word[line].unpack,$(subst $(SP),$(LF),$(foreach line,$(call word[line].pack,$(1)),$(call word[line].pack,$(call $(2),$(call word[line].unpack,$(line)),$(3),$(4),$(5),$(6),$(7),$(8),$(9)))))),$(1))

# str = $(call str.indent.byline,{indentation},{multiline_value})
# Calls $(strip) on each line to remove leading/trailing whitespace,
# then prefixes each (nonempty) line with {indentation}.
# WARNING:
#   The $(strip) operation removes consecutive whitespace from
#   the middle of the string! Escape important whitespace with:
#     $$(SP) $$(TAB) $$(LF)
override str.indent.byline.lf := $(LF)
override str.indent.byline = $(1)$(subst $$(str.indent.byline.lf),,$(subst $$(str.indent.byline.lf)$(SP),$(LF)$(1),$(strip $(subst $(LF)$(SP),$$(str.indent.byline.lf)$(SP),$(2)))))
#===============================================================================






#===============================================================================
# STRING PADDING
#===============================================================================
# A [pad] is a string of '.' characters used to specify the length of another string.
#
# Example:
#   pad := ..............................
#   line := Some Text
#   $(info [$(pad)])                                    -->  [..............................]
#   $(info [$(str)])                                    -->  [Some Text]
#   $(info [$(call line.justify.right,$(line),$(pad))]) -->  [Some Text                     ]
#   $(info [$(call line.justify.left,$(line),$(pad))])  -->  [                     Some Text]
#
#-----------------------------------------------------------
# Type Conversions:
#  [pad]  <-- $(call str.to.pad,[str])                      Returns a [pad] equal to the length of the longest line in [str].
#  [pad]  <-- $(call line.to.pad,[line])                      length [pad] == length [line]
#  [pad]  <-- $(call word.to.pad,[word])                      length [pad] == length [word]
#  [pad]  <-- $(call int.to.pad,[int])                        length [pad] == length [int]
#
# Length Differences:
#  [pad]  <-- $(call pad.subtract.pad,[pad],[pad])          Returns a [pad] equal to the difference in lengths of the two arguments.
#  [pad]  <-- $(call pad.subtract.str,[pad],[str])            Uses length of longest line in [str]; not length of [str].
#  [pad]  <-- $(call pad.subtract.line,[pad],[line])
#  [pad]  <-- $(call pad.subtract.word,[pad],[word])
#  [pad]  <-- $(call pad.subtract.int,[pad],[int])
#
# Right/Left Justification:
#  [str]  <-- $(call str.justify.right,[str],[pad],[char])      Right-pads each line of [str] with [char]s up to the length of [pad].
#  [str]  <-- $(call str.justify.left,[str],[pad],[char])       Left-pads each line of [str]. Similar to a right-justify.
#                                                             [pad] defaults to a pad the length of the longest line in [str].
#                                                             [char] defaults to $(SP).
#
#  [line] <-- $(call line.justify.right,[line],[pad],[char])    Same as str.pad, but optimized for various other types.
#  [line] <-- $(call line.justify.left,[line],[pad],[char])
#  [line] <-- $(call word.justify.right,[word],[pad],[char])
#  [line] <-- $(call word.justify.left,[word],[pad],[char])
#  [line] <-- $(call int.justify.right,[int],[pad],[char])
#  [line] <-- $(call int.justify.left,[int],[pad],[char])
#-----------------------------------------------------------

# Type Conversions ==================== type: [pad]
override str.to.pad         = $(lastword $(sort $(call str.subst.list_to_str,$(char.type.word),.,$(subst $(SP),.,$(subst $(TAB),$(TAB.SIZE),$(1))))))
override line.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(subst $(SP),.,$(subst $(TAB),$(TAB.SIZE),$(1))))
override word.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(1))
override int.to.pad         = $(call str.subst.list_to_str,$(char.type.int),.,$(1))

# Length Differences ================== type: [pad]
override pad.subtract.pad   = $(filter-out $(1),$(1:$(2)%=%))
override pad.subtract.str   = $(call pad.subtract.pad,$(1),$(call str.to.pad,$(2)))
override pad.subtract.line  = $(call pad.subtract.pad,$(1),$(call line.to.pad,$(2)))
override pad.subtract.word  = $(call pad.subtract.pad,$(1),$(call word.to.pad,$(2)))
override pad.subtract.int   = $(call pad.subtract.pad,$(1),$(call int.to.pad,$(2)))

# Left/Right Justification ============ type: [str]
override str.justify.right  = $(call str.foreach.line,$(1),line.justify.right,$(or $(2),$(call str.to.pad,$(1))),$(3))
override str.justify.left   = $(call str.foreach.line,$(1),line.justify.left,$(or $(2),$(call str.to.pad,$(1))),$(3))

override line.justify.right = $(subst $(TAB),$(TAB.SIZE),$(1))$(subst .,$(or $(3),$(SP)),$(call pad.subtract.str,$(2),$(1)))
override line.justify.left  = $(subst .,$(or $(3),$(SP)),$(call pad.subtract.str,$(2),$(1)))$(subst $(TAB),$(TAB.SIZE),$(1))

override word.justify.right = $(1)$(subst .,$(or $(3),$(SP)),$(call pad.subtract.word,$(2),$(1)))
override word.justify.left  = $(subst .,$(or $(3),$(SP)),$(call pad.subtract.word,$(2),$(1)))$(1)

override int.justify.right  = $(1)$(subst .,$(or $(3),$(SP)),$(call pad.subtract.int,$(2),$(1)))
override int.justify.left   = $(subst .,$(or $(3),$(SP)),$(call pad.subtract.int,$(2),$(1)))$(1)
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
override this.filepath = $(abspath $(lastword $(MAKEFILE_LIST)))
override this.filename = $(notdir $(lastword $(MAKEFILE_LIST)))
override this.dirpath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
override this.dirname = $(notdir $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
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
override TRUE.p := true
override FALSE.p := false

# "Boolean" types that follow make's convention for conditional evaluation
override TRUE.m := true
override FALSE.m := $(empty)

# "Boolean" types that follow shell conventions for exitcodes (and also C language)
override TRUE.s := 0
override FALSE.s := 1

# "Boolean" types that are actually binary in the traditional sense
override TRUE.b := 1
override FALSE.b := 0

# Lists of truthy values and falsy values, for interactive purposes
override TRUE.l := TRUE True true YES Yes yes Y y 1
override FALSE.l := FALSE False false NO No no N n 0

override is.truthy = $(if $(filter $(TRUE.l),$(strip $(1))),$(TRUE.m),$(FALSE.m))
override is.falsey = $(if $(filter $(FALSE.l),$(or $(strip $(1)),false)),$(TRUE.m),$(FALSE.m))
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
override int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))
override int.dec = $(if $(filter 0 -%,$(1)),-)$(subst .,,$(call int.$(if $(filter 0 -%,$(1)),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))

override int.inc.recurse = $(if $(basename $(1)),$(if $(1:%9=),$(basename $(1))$(call digit.inc,$(suffix $(1)),.),$(if $(1),$(call int.inc.recurse,$(basename $(1))).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $(1)),.),$(if $(1),.1.0)))
override int.dec.recurse = $(if $(basename $(1)),$(if $(1:%0=),$(basename $(1))$(call digit.dec,$(suffix $(1)),.),$(if $(1),$(filter-out .0,$(call int.dec.recurse,$(basename $(1)))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $(1)),.)))

# [str] <-- $(call str.digits.addprefix,[prefix],[str])
override str.digits.addprefix = $(subst 9,$(1)9,$(subst 8,$(1)8,$(subst 7,$(1)7,$(subst 6,$(1)6,$(subst 5,$(1)5,$(subst 4,$(1)4,$(subst 3,$(1)3,$(subst 2,$(1)2,$(subst 1,$(1)1,$(subst 0,$(1)0,$(2)))))))))))

# {digit} <-- $(call digit.inc,[digit],[prefix])     Over/underflow wraps to 0/9. empty is treated as digit=0.
# {digit} <-- $(call digit.dec,[digit],[prefix])
override digit.inc  = $(addprefix $(2),$(word 1$(1:$(2)%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
override digit.dec  = $(addprefix $(2),$(word 1$(1:$(2)%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))

override int.abs = $(1:-%=%)
override int.neg = $(if $(1:-%=),$(if $(1:0=),-$(1),$(1)),$(1:-%=%))

# Comparison
override int.equ    = $(filter $(2),$(1))
override int.neq    = $(filter-out $(2),$(1))
override int.equ.0  = $(filter 0,$(1))
#int.equ.0 = $(if $(1:0=),,true)
override int.neq.0  = $(1:0=)
override int.gtr.0  = $(filter-out 0 -%,$(1))
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
override int.geq.0  = $(1:-%=)
override int.leq.0  = $(filter 0 -%,$(1))
override int.lss.0  = $(filter -%,$(1))
#int.lss.0 = $(if $(1:-%=),,true)


# Type Conversions
override bool.to.uint = $(if $(1),0,1)
override int.to.uint  = $(or $(filter-out -%,$(2)),0)
#===============================================================================






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
#-----------------------------------------------------------
#
# Types:
#  str           A string containing any characters.
#  line          A [str} containing a single line; may contain whitespace, but no linefeeds.
#  word          A [str} containing a single word; no whitespace.
#  word[type]    A packed [word} containing an escaped string of [type] (which may be {type} or [empty]).
#                    The original value may have contained any characters allowed for that [type].
#  list          A whitespace-separated list of plain {word} values.
#                    Operations on a plain `list` take the value of each word literally.
#  list[type]    A list of packed words, where each word is a {word[type]}.
#                    Operations on a packed `list` transparently pack/unpack each word as-needed;
#                    For example, `list[str].append` first escapes a nonempty {str} or [empty] value,
#                      then appends the escaped [str] to the list as a {word[str]}.
#  idx           An integer >= 1 representing a {word}'s position in a `list`.
#                    idx > $(words [list]) typically results in a no-op.
#                    idx < 1 is invalid and typically throws an error.
#
# Empty vs Nonempty Lists:
#   {list}
#
#-----------------------------------------------------------
# Logical Operations:
#
# [bool]  <-- $(call list.is.empty,[list])
# [bool]  <-- $(call list.is.nonempty,[list])
#
# [str]   <-- $(call list.if.empty,[list],[str:if_true],[str:if_false])
# [str]   <-- $(call list.if.nonempty,[list],[str:if_true],[str:if_false])
#
# {uint:len}  <--  $(call list.length,[list])               Returns number of words in [list], or 0 if [list] is [empty] or contains only whitespace.
#
# [list]  <--  $(call list.trim,[list])                 Removes empty words from [list], which eliminates leading, trailing, and consecutive whitespace.
#                                                             For lists of packed-word types (such as list[str]), packed-words containing [empty] value are removed.
#
# [list]  <-- $(call list.map,[list],{func},[str:arg2],[str:arg3],...)
#
#
#-----------------------------------------------------------
# Accessing Individual Elements:
#
# [idx]  <-- $(call list.idx,[list],[int:idx])             Returns [idx]   if [idx]   is a valid position in [list]; empty otherwise.
# [idx]  <-- $(call list.idx.prev,[list],[int:idx])        Returns [idx]-1 if [idx]-1 is a valid position in [list]; empty otherwise.
# [idx]  <-- $(call list.idx.next,[list],[int:idx])        Returns [idx]+1 if [idx]+1 is a valid position in [list]; empty otherwise.
# [idx]  <-- $(call list.idx.first,[list])                 Returns 1 if list is nonempty; empty if [list] is empty or contains only whitespace.
# [idx]  <-- $(call list.idx.last,[list])                  Returns position of last word in [list]; empty if [list] is empty or contains only whitespace.
#
# [list] <-- $(call list.insert,[list],[word],[idx])       Inserts [word] at index = [idx]. Returns the modified [list].
# [list] <-- $(call list.insert.prev,[list],[word],[idx])    index = [idx]-1
# [list] <-- $(call list.insert.next,[list],[word],[idx])    index = [idx]+1
# [list] <-- $(call list.prepend,[list],[word])              index = 1
# [list] <-- $(call list.append,[list],[word])               index = $(words [list])
#
# [list] <-- $(call list.remove,[list],[idx])              Removes word at index = [idx]. Returns the modified [list].
# [list] <-- $(call list.remove.prev,[list],[idx])           index = [idx]-1
# [list] <-- $(call list.remove.next,[list],[idx])           index = [idx]+1
# [list] <-- $(call list.remove.first,[list])                index = 1
# [list] <-- $(call list.remove.last,[list])                 index = $(words [list])
#
# [word] <-- $(call list.get,[list],[idx])                 Returns [word] at index = [idx].
# [word] <-- $(call list.get.prev,[list],[idx])              index = [idx]-1
# [word] <-- $(call list.get.next,[list],[idx])              index = [idx]+1
# [word] <-- $(call list.get.first,[list])                   index = 1
# [word] <-- $(call list.get.last,[list])                    index = $(words [list])
#
# [list] <-- $(call list.set,[list],[word],[idx])          Sets word at index = [idx] to [word]. Returns the modified [list].
# [list] <-- $(call list.set.prev,[list],[word],[idx])       index = [idx]-1.
# [list] <-- $(call list.set.next,[list],[word],[idx])       index = [idx]+1.
# [list] <-- $(call list.set.first,[list],[word])            index = 1.
# [list] <-- $(call list.set.last,[list],[word])             index = $(words [list])
#
#===============================================================================

# list.is ============================  type: [bool]
override list.is.empty          = $(if $(firstword $(1)),,true)
override list.is.nonempty       = $(firstword $(1))

override list[str].is.empty     = $(call list.is.empty,$(call list[str].trim,$(1)))
override list[str].is.nonempty  = $(call list.is.nonempty,$(call list[str].trim,$(1)))

# list.if ============================  type: [str]
override list.if.empty          = $(if $(firstword $(1)),$(3),$(2))
override list.if.nonempty       = $(if $(firstword $(1)),$(3),$(2))

override list[str].if.empty     = $(call list.if.empty,$(call list[str].trim,$(1)),$(2),$(3))
override list[str].if.nonempty  = $(call list.if.nonempty,$(call list[str].trim,$(1)),$(2),$(3))

# list.length ========================= type: {uint}
override list.length            = $(words $(1))
override list[str].length       = $(call list.length,$(call list[str].trim,$(1)))

# list.trim =========================== type: [list], [list[str]]
override list.trim              = $(strip $(1))
override list[str].trim         = $(call list.trim,$(subst $$(empty),,$(1)))

# list.map ============================ type: [list], [list[str]]
override list.map               = $(strip $(foreach word,$(1),$(call $(2),$(word),$(3),$(4),$(5),$(6),$(7),$(8),$(9))))
override list[str].map          = $(strip $(foreach word,$(1),$(call word[str].pack,$(call $(2),$(call word[str].unpack,$(word)),$(3),$(4),$(5),$(6),$(7),$(8),$(9)))))

# list.idx ============================ type: [idx]
override list.idx.dec           = $(if $(2),$(words $(wordlist 2,$(2),$(1) +1)))# [uint] <-- clamp([uint:2]-1,0,len(list:1))
override list.idx.inc           = $(if $(2),$(words $(wordlist 1,$(2),$(1)) +1))# [uint] <-- clamp([uint:2]+1,1,len(list:1)+1)

override list.idx               = $(and $(filter-out 0,$(2)),$(word $(2),$(1)),$(2))
override list.idx.prev          = $(filter-out 0 $(words $(1) +1),$(call list.idx.dec,$(1) +1,$(2)))
override list.idx.next          = $(filter-out   $(words $(1) +1),$(call list.idx.inc,$(1)   ,$(2)))
override list.idx.first         = $(if $(firstword $(1)),1)
override list.idx.last          = $(filter-out 0,$(words $(1)))

override list[str].idx          = $(call list.idx,$(1),$(2))
override list[str].idx.prev     = $(call list.idx.prev,$(1),$(2))
override list[str].idx.next     = $(call list.idx.next,$(1),$(2))
override list[str].idx.first    = $(call list.idx.first,$(1))
override list[str].idx.last     = $(call list.idx.last,$(1))

# list.insert ========================= type: [list], [list[str]]
override list.insert.N          = $(strip $(if $(3),$(wordlist 1,$(call list.idx.dec,$(1),$(3)),$(1)) $(2) $(wordlist $(3),$(words $(1)),$(1)),$(1)))

override list.insert            = $(call list.insert.N,$(1),$(2),$(call list.idx,$(1) $$,$(3)))
override list.insert.prev       = $(call list.insert.N,$(1),$(2),$(call list.idx.prev,$(1) $$,$(3)))
override list.insert.next       = $(call list.insert.N,$(1),$(2),$(call list.idx.next,$(1) $$,$(3)))
override list.prepend           = $(strip $(2) $(1))
override list.append            = $(strip $(1) $(2))

override list[str].insert       = $(call list.insert,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].insert.prev  = $(call list.insert.prev,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].insert.next  = $(call list.insert.next,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].prepend      = $(call list.prepend,$(1),$(call word[str].pack,$(2)))
override list[str].append       = $(call list.append,$(1),$(call word[str].pack,$(2)))

# list.remove ========================= type: [list], [list[str]]
override list.remove.N          = $(strip $(if $(2),$(wordlist 1,$(call list.idx.dec,$(1),$(2)),$(1)) $(wordlist $(call list.idx.inc,$(1),$(2)),$(words $(1)),$(1)),$(1)))

override list.remove            = $(call list.remove.N,$(1),$(call list.idx,$(1),$(2)))
override list.remove.prev       = $(call list.remove.N,$(1),$(call list.idx.prev,$(1),$(2)))
override list.remove.next       = $(call list.remove.N,$(1),$(call list.idx.next,$(1),$(2)))
override list.remove.first      = $(call list.remove.N,$(1),$(call list.idx.first,$(1)))
override list.remove.last       = $(call list.remove.N,$(1),$(call list.idx.last,$(1)))

override list[str].remove       = $(call list.remove,$(1),$(2))
override list[str].remove.prev  = $(call list.remove.prev,$(1),$(2))
override list[str].remove.next  = $(call list.remove.next,$(1),$(2))
override list[str].remove.first = $(call list.remove.first,$(1))
override list[str].remove.last  = $(call list.remove.last,$(1))

# list.get ============================ type: [word], [str]
override list.get.N             = $(if $(2),$(word $(2),$(1)))

override list.get               = $(call list.get.N,$(1),$(call list.idx,$(1),$(2)))
override list.get.prev          = $(call list.get.N,$(1),$(call list.idx.prev,$(1),$(2)))
override list.get.next          = $(call list.get.N,$(1),$(call list.idx.next,$(1),$(2)))
override list.get.first         = $(firstword $(1))
override list.get.last          = $(lastword $(1))

override list[str].get          = $(call word[str].unpack,$(call list.get,$(1),$(2)))
override list[str].get.prev     = $(call word[str].unpack,$(call list.get.prev,$(1),$(2)))
override list[str].get.next     = $(call word[str].unpack,$(call list.get.next,$(1),$(2)))
override list[str].get.first    = $(call word[str].unpack,$(call list.get.first,$(1)))
override list[str].get.last     = $(call word[str].unpack,$(call list.get.last,$(1)))

# list.set ============================ type: [list], [list[str]]
override list.set.N             = $(strip $(if $(3),$(wordlist 1,$(call list.idx.dec,$(1),$(3)),$(1)) $(2) $(wordlist $(call list.idx.inc,$(1),$(3)),$(words $(1)),$(1)),$(1)))

override list.set               = $(call list.set.N,$(1),$(2),$(call list.idx,$(1),$(3)))
override list.set.prev          = $(call list.set.N,$(1),$(2),$(call list.idx.prev,$(1),$(3)))
override list.set.next          = $(call list.set.N,$(1),$(2),$(call list.idx.next,$(1),$(3)))
override list.set.first         = $(call list.set.N,$(1),$(2),$(call list.idx.first,$(1)))
override list.set.last          = $(call list.set.N,$(1),$(2),$(call list.idx.last,$(1)))

override list[str].set          = $(call list.set,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].set.prev     = $(call list.set.prev,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].set.next     = $(call list.set.next,$(1),$(call word[str].pack,$(2)),$(3))
override list[str].set.first    = $(call list.set.first,$(1),$(call word[str].pack,$(2)))
override list[str].set.last     = $(call list.set.last,$(1),$(call word[str].pack,$(2)))


list :=
list := $(call list[str].append,$(list),item 1)
list := $(call list[str].append,$(list),item 2)
list := $(call list[str].append,$(list),item 3)
func = $(info "$(1)")
result = $(call list[str].foreach,$(list),func)
$(call print.vars, list result)
$(error Exiting... )


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
#   sep = $(SP)
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
override list.foreach.pair = $(subst $(char.num),,$(subst $(char.num)$(SP),$(6),$(foreach __pair,$(join $(addsuffix $(char.num),$(2)),$(4)),$(subst $$($(1)),$(firstword $(subst $(char.num),$(SP),$(__pair))),$(subst $$($(3)),$(lastword $(subst $(char.num),$(SP),$(__pair))),$(5)))$(char.num))))
override list.concat = $(subst $(SP),$(1),$(strip $(2)))
override str.concat.pair = $(if $(and $(2),$(3)),$(2)$(1)$(3),$(or $(2),$(3)))
override str.concat = $(if $(or $(3),$(4),$(5),$(6),$(7),$(8),$(9)),$(call str.concat.pair,$(1),$(2),$(call str.concat,$(1),$(3),$(4),$(5),$(6),$(7),$(8),$(9))),$(2))
#===============================================================================






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
#-----------------------------------------------------------

# {name} := [start,0]
# {name}.next = $(eval {name} := $(if $(filter-out [end],$({name})),$(call int.inc,$({name}))))$({name})
override iter.inc.define = $(eval $(1) := $(or $(2),0))$(eval $(1).next = $$(eval $(1) := $$(if $$(filter-out $(3),$$($(1))),$$(call int.inc,$$($(1)))))$$($(1)))
#===============================================================================






#===============================================================================
# NAMESPACES
#===============================================================================
#
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
#     $$(SP)
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


override define target.define.template
$(subst $(LF)$(SP),$(LF),$(foreach target,$(4),$(target): $(strip $(1))$(LF)))
$(subst $(LF)$(SP),$(LF),$(foreach target,$(5),$(target): | $(strip $(1))$(LF)))
$(strip $(1): $(2) $(if $(strip $(3)),| $(strip $(3))))
$(if $(strip $(6)),$(TAB)$(subst $$(LF),$(LF)$(TAB),$(subst $$(LF)$(SP),$$(LF),$(strip $(subst $(LF),$$(LF)$(LF),$(subst $$(LF),$(LF),$(6)))))))
endef

override target.define = $(eval $(call target.define.template,$(1),$(2),$(3),$(4),$(5),$(6)))


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

override target.pre.define = $(call target.define,$(1).pre,,,,$(2),$(3))


#-----------------------------------------------------------
# str = $(call str.eval,{expr})
#-----------------------------------------------------------
# Performs an additional $-expansion on a string.
#
# Example:
#   expr := $$(call ...)                     expr contains literal syntax '$(call ...)'
#   expr2 := $(call str.eval,$(expr))      expr2 contains the result of $(call ...)
#-----------------------------------------------------------

override str.eval.tmp := $(empty)
override str.eval = $(eval str.eval.tmp := $(1))$(str.eval.tmp)$(eval str.eval.tmp :=)

#-----------------------------------------------------------
# str = $(call str.escape.vars,[vars],[str])
# str = $(call str.expand.vars,[vars],[str])
#-----------------------------------------------------------
# .escape      Substitutes each $(var) with literal "$(var)".
# .expand      Substitutes each literal "$(var)" with $(var).
#-----------------------------------------------------------

override str.escape.vars = $(call str.subst.vars_to_list,$(1),$(foreach var,$(1),$$($(var))),$(2))
override str.expand.vars = $(call str.subst.list_to_vars,$(foreach var,$(1),$$($(var))),$(1),$(2))

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

override variable.set_with_alternatives = $(eval $(strip $(1)) $(strip $(2)) $(if $(or $(3),$(strip $(4)),$(5)),$$(or $(if $(3),$(3)$(CMA))$(subst $(SP),$(CMA),$(foreach var,$(strip $(4)),$$($(var))))$(if $(5),$(CMA)$(5)))))


#===============================================================================
