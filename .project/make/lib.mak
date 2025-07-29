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
#===============================================================================
# Data Types:
#
#  Like most scripting languages, GNU Make does not explicitly differentiate
#    between data types; all variables are strings.
#  However, the built-in Make functions do share a common set of usage conventions,
#    formatting expectations, and error conditions.
#  This library attempts to provide a taxonomy of "types" which cover each unique
#    usage of strings among the inputs and outputs of the Make built-ins.
#  Using these types as a basis, new types and functions can be defined which
#    expand on the basic features of Make while remaining maximally interoperable
#    with existing Makefiles.
#
# $([var:name]) --> [str]
#
#   Expands to the value of a variable named [name].
#     Expands recursively if [name] was assigned with the recursive-assignment operator '='.
#   Returns empty if [name] is empty, [name] contains empty, or [name] is undefined.
#
#
# $([var:list]:[pattern:match]=[pattern:replace]) --> [list]
#
#   Expands a list variable, performing a pattern substitution on each word.
#   If [pattern.match] contains a wildcard '%', equivalent to:
#     $(patsubst [pattern.match],[pattern.replace],$([var:list]))
#   If [pattern.match] contains no wildcard, assumes pattern is a suffix:
#     $(patsubst %[pattern.match],%[pattern.replace],$([var:list]))
#
#
# $(subst [str:find],[str:repl],[str:in]) --> [str]
#
#   Substitutes each occurrance of [str:find] in [str:in] with [str:repl].
#
#
# $(patsubst [pattern.match],[pattern.replace],[list]) --> [list]
#
#   For each word in [list] matching [pattern.match],
#     replaces that word with [pattern.replace].
#   If both patterns contain a wildcard '%', the value of '%' in the
#     original word is is substituted for '%' in the replacement word.
#   [pattern.match] may contain either a wildcard, or whitespace, but not both.
#   [pattern.replace] may contain both a wildcard and whitespace.
#   Returns a list with no leading/trailing whitespace and a single space ' ' between words.
#     However, additional whitespace inserted via [pattern.replace] is maintained.
#     Therefore, it's possible for the returned list to have more words than the original.
#   See definition of type "pattern" for more details.
#
#
# $(strip [str]) --> [str]
#
#   Removes leading and trailing whitespace characters.
#   Replaces tab and linefeed chars with spaces.
#   Consecutive whitespace is reduced to a single space ' '.
#
#
# $(findstring [str:find],[str:in]) --> [str:find]
# $(findstring [str:find],[str:in]) --> [bool:found]
#
#   Returns [str:find] if [str:in] contains [str:find]; empty otherwise.
#
#
# $(filter [pattern.matches],[list])     --> [list]
# $(filter-out [pattern.matches],[list]) --> [list]
#
#   For each word in [list], keeps (filter) or rejects (filter-out) the word
#     if matched by any pattern in [pattern.matches].
#   Since [pattern.matches] is a space-separated list of patterns,
#     they may not individually contain whitespace.
#
#
# $(sort [list]) --> [list]
#
#   Returns the words of [list], sorted lexicographically.
#
#
# $(words [list]) --> [uint]
#
#   Returns the number of words in [list], or 0 if [list] is empty or only contains whitespace.
#
#
# $(word {idx},[list])                      --> [word]
# $(wordlist {idx:start},{uint:end},[list]) --> [list]
#
#   Returns a single word or a sequence of words from [list].
#   Returns empty for indicies > $(words [list])
#   Returns empty if {idx:start} > {idx:end}.
#   Returns error if {idx}, {idx:start} not positive, nonempty integers.
#   Returns error if {uint:endidx} not positive, nonempty integer or 0.
#
#
# $(firstword [list]) --> [word]
# $(lastword [list])  --> [word]
#
#   Returns first or last word in a list.
#   Returns empty if [list] is empty.
#
#
# $(value [var]) --> [dynamic]
# $(eval [dynamic])
# $(origin [var]) --> [enum.origin]
# $(flavor [var]) --> [enum.flavor]
# $(info [str:message])
# $(error [str:message])
# $(warning [str:message])
# $(shell [str:command])
# [dirs] = $(dir [paths])
# [notdirs] = $(notdir [paths])
# [exts] = $(suffix [paths])
# [basenames] = $(basename [paths])
# [strs] = $(addprefix [str:prefix],[strs])
# [strs] = $(addsuffix [str:suffix],[strs])
# [strs] = $(join [strs],[strs])
# [paths] = $(wildcard [wildcards])
# [paths] = $(realpath [paths])
# [paths] = $(abspath [paths])
# [str] = $(if bool:condition,str:then[,str:else])
# [str] = $(or bool:condition[,str:cond2[,bool:cond3]])
# [str] = $(and bool:condition[,str:cond2[,bool:cond3]])
# [str] = $(intcmp int:lhs,int:rhs[,str:lss,[str:equ,[str:gtr]]])      (GNU Make 4.4+ only)
# [str] = $(let vars,vals,expr)
# [str] = $(foreath var,strs,expr)
# [str] = $(file < file)
#         $(file > file,str)
#         $(file >> file,str)
# [str] = $(call fcn[,arg1[,arg2[,...]]])
#
# [pattern]
#  |  A string which optionally contains a wildcard: '%'.
#  |  The wildcard is a placeholder for some other operation to fill in.
#  |    Before the '%' wildcard, literal '%' must be escaped as '\%' and '\' as '\\'.
#  |    After the '%' wildcard, all '%' and '\' are literal and should not be escaped!
#  |    Therefore, only the first '%' is wild.
#  |
#  +--[pattern.match]
#  |     A pattern for comparison against a [word] or [list].
#  |     An operation is then applied to each [word] (or group of [words]) that match the pattern.
#  |       - Wildcard '%' in pattern represents zero or more chars in [word]; as many chars as possible.
#  |       - Whitespace in pattern can match multiple consecutive [words] as one.
#  |       - Pattern may contain either a wildcard or whitespace, but not both!
#  |     Invalid patterns do not match anything, which should typically result in a no-op:
#  |       - Patterns containing both '%' and whitespace characters
#  |       - Patterns containing leading or trailing whitespace
#  |       - Patterns that are empty
#  |
#  +--[pattern.replace]
#         A pattern used to form new strings.
#         An operation substitutes the wildcard '%' in [pattern] with some other value,
#           then returns the result or uses it for subsequent operations.
#         Pattern may contain both wildcard and whitespace.
#
 EMPTY :=
 SPACE := $(EMPTY) $(EMPTY)
    TAB := $(EMPTY)	$(EMPTY)
define LF


endef

pat.find = /path/with$(SPACE)spaces/%
pat.repl = {%}
 list.in = /path/without/spaces/file.x /path/with$(SPACE)spaces/file.x
  result := $(patsubst $(pat.find),$(pat.repl),$(list.in))

$(info )
$(info pat.find=[$(pat.find)])
$(info pat.repl=[$(pat.repl)])
$(info $(SPACE)list.in=[$(list.in)])
$(info $(SPACE)$(SPACE)result=[$(result)])
$(info )
$(error Exiting...)

#
# TAXONOMY OF DATA TYPES IN GNU MAKE
#
#
#  /str
#  /str/bool
#  /str/bool/true
#  /str/bool/false
#  /str/bool/false/empty
#  /str/list
#  /str/list/list<type>
#  /str/list/list<type>/word<type>
#  /str/list/word
#  /str/list/word/int
#  /str/list/word/int/uint
#  /str/list/word/int/uint/idx
#  /str/list/word/var
#  /str/list/word/var/fcn
#  /str/list/word/var/ns
#  /str/list/word/digit
#
#  str                    String:
#  |                        All variables in Make are strings.
#  |
#  +--bool                Boolean:
#  |  |                     Logical true or false, for use in conditional expansion.
#  |  |
#  |  +--true             True:
#  |  |                     A nonempty string.
#  |  |
#  |  +--false            False:
#  |     |                  The empty string.
#  |     |
#  |     +--empty         Empty:
#  |                        The empty string. Given an independent name to clarify its meaning in a non-logical context.
#  |
#  +--list                List:
#  |  |                     A string containing a whitespace-delimited list of words.
#  |  |                       --> Words cannot contain whitespace.
#  |  |                     Consecutive whitespace is treated as a single delimiter.
#  |  |                       --> Words cannot be empty or contain only whitespace.
#  |  |                     Lists are 1-indexed. Out-of-bounds indices should result in a no-op (where possible).
#  |  |                     The empty list is an empty string, or a string with only whitespace.
#  |  |
#  |  +--list<type>       List of Word <type>, or List of Word-Packed <type>:
#  |  |  |                  A list which only contains words of a specific <type> (or descendents of that <type>).
#  |  |  |                  Words are nonempty and cannot contain whitespace; <type> must be <word> or descended from <word>
#  |  |  |                  If <type> is <word> or descended from <word>, values of that <type> are list-compatible as-is.
#  |  |  |                  If <type> is one that allows empty strings or whitespace (incompatible with lists),
#  |  |  |                    then <type> is actually shorthand for <word<type>> (compatible with lists). See below for details.
#  |  |  |
#  |  |  +--word<type>    Word-Packed <type>:
#  |  |                     A word containing a potentially dangerous <type>, which has been modified to be list-safe.
#  |  |                     Operations that produce word<type> must guarantee the result is nonempty and contains no whitespace,
#  |  |                       and that the original value is able to be reconstituted by future operations.
#  |  |                     For general strings, this implies (at a minimum) escaping whitespace, escape characters, and empty strings;
#  |  |                       simpler types (such as bool) may be less work to make list-compatible.
#  |  |
#  |  +--word             Word:
#  |     |                  A nonempty string with no whitespace.
#  |     |                  An individual element of a list; a list with 1 element.
#  |     |
#  |     +--int           Integer:
#  |     |  |               A word containing an integer value: positive, negative, or 0.
#  |     |  |
#  |     |  +-uint        Unsigned Integer:
#  |     |    |             A word containing a positive integer, or 0.
#  |     |    |
#  |     |    +--idx      List Index:
#  |     |                  A word containing a positive integer.
#  |     |                  Lists are 1-indexed.
#  |     |                  - idx > $(words [list]) is a valid no-op.
#  |     |                  - idx < 1 is an error.
#  |     |
#  |     +--var           Variable:
#  |        |               A word containing the name of a variable.
#  |        |               Variable names can include any characters except "#", "=", ":",
#  |        |                 but whitespace, "$", "(", ")" are problematic and should always be avoided.
#  |        |
#  |        +--fcn        Function:
#  |        |               A word containing the name of a callable "function";
#  |        |                 a variable containing a recursively-expanded expression which takes parameters
#  |        |                 ( $(1) ... $(9) ) and/or produces side effects ( $(shell), $(info), $(eval), ... )
#  |        |               See documentation for Make built-in $(call) for more details.
#  |        |
#  |        +--ns         Namespace:
#  |                        A word containing the name of a "namespace": a collection of associated variables.
#  |                        A namespace definition consists of:
#  |                          1. A root variable {ns} of type list<var>, containing a list of all variables "within" the namespace.
#  |                          2. A collection of variables, functions, etc, each named {ns}.{var}.
#  |                        Example: Define a namespace "root", containing another namespace "root.sub"
#  |                          root = root.var1 root.var2 $(root.sub)
#  |                          root.var1 = Value 1
#  |                          root.var2 = Value 2
#  |                          root.sub = root.sub.var3
#  |                          root.sub.var3 = Value 3
#  |                          $(info $(root)) --> root.var1 root.var2 root.sub.var3
#  |
#  +--dynamic             Make Syntax:
#  |                        A string containing valid Make syntax.
#  |                        Used for dynamic programming.
#  |
#  +--path                Path:
#  |  |                     A nonempty string containing a system file or directory path.
#  |  |                     Absolute or relative paths allowed, symlinks allowed.
#  |  |                     Path may contain whitespace.
#  |  |                     Path separator should always be forward-slash "/".
#  |  |                     Directories may or may not have trailing "/".
#  |  |                     No leading or trailing whitespace.
#  |  |                     No quotes around path.
#  |  |
#  |  +--file             File Path:
#  |  |  |                  A path to a non-directory file.
#  |  |  |
#  |  |  +--filename      File Name:
#  |  |                     A file with no directory part.
#  |  |
#  |  +--dir              Directory Path:
#  |     |                  A path to a directory.
#  |     |
#  |     +--dirname       Directory Name:
#  |                        A dir with no parent directory part.
#  |
#  |
#  +--basename            Basename:
#  |
#  |--ext                 File Type Extension:
#
#===============================================================================

#-----------------------------------------------------------
# Special Characters
#-----------------------------------------------------------
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
#-----------------------------------------------------------


# Source: https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_6.html
# "A variable name may be any sequence of characters not containing `:', `#', `=', or leading or trailing whitespace."
#
 EMPTY :=
 SPACE := $(EMPTY) $(EMPTY)
   TAB := $(EMPTY)	$(EMPTY)
define LF


endef
 BTICK := `$(EMPTY)
 TILDE := ~$(EMPTY)
 EXCLM := !$(EMPTY)
    AT := @$(EMPTY)
 POUND := \#$(EMPTY)
DOLLAR := $$$(EMPTY)
PERCENT := %$(EMPTY)
 CARET := ^$(EMPTY)
 AMPER := &$(EMPTY)
   AST := *$(EMPTY)
OPAREN := ($(EMPTY)
CPAREN := )$(EMPTY)
 EQUAL := =$(EMPTY)
BSLASH := \$(EMPTY)
  PIPE := |$(EMPTY)
 SEMIC := ;$(EMPTY)
 COLON := :$(EMPTY)
SQUOTE := '$(EMPTY)
DQUOTE := "$(EMPTY)
 COMMA := ,$(EMPTY)
LCARET := <$(EMPTY)
PERIOD := .$(EMPTY)
RCARET := >$(EMPTY)
FSLASH := /$(EMPTY)
 QUEST := ?$(EMPTY)
   NaN := $(EMPTY)

# Character sets
       chr.lowers := a b c d e f g h i j k l m n o p q r s t u v w x y z
       chr.uppers := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
       chr.digits := 0 1 2 3 4 5 6 7 8 9
   chr.whitespace := $(SPACE)$(TAB)$(LF)
   chr.whitespace.vars := SPACE TAB LF
chr.nonwhitespace := $(chr.lowers) $(chr.uppers) $(chr.digits) ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , < . > / ?
     chr.varnames := $(chr.lowers) $(chr.uppers) $(chr.digits) ` ~ ! @    $$ % ^ & * ( ) - _   + { } [ ] \ | ;   ' " , < . > / ?



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
# $(call print.info,{msg},[indent])
# $(call print.vars,{vars},[indent],[col])
# $(call print.list,{list},[indent],[col])
# $(call print.debug,{msg},[indent])
# $(call print.trace,{msg},[indent])
#-----------------------------------------------------------
# {vars}           Space-separated list of variable names
# {list}           Space-separated list of strings
# {msg}            Singular string
#-----------------------------------------------------------

print.vars = $(if $(2),$(if $(3),$(foreach var,$(1),$(call print.var,$(var),$(2),$(3),[,])),$(call print.vars,$(1),$(2),$(call print.vars.col,$(1)))),$(call print.vars,$(1),$(INDENT),$(3)))

# $(call print.var,{var},{indent},{col},{prefix},{suffix})
print.var = $(info $(2)$(call str.lpad,$(1),$(3))=$(4)$(subst $(LF),$(5)$(LF)$(2)$(subst .,$(SPACE),$(3).)$(4),$($(1)))$(5))

# $(call print.vars.col,{vars})
print.vars.col = $(lastword $(sort $(call str.subst.list_to_str,$(chr.varnames),.,$(1))))

print.break = $(info )$(call print.vars,$(1))$(info )$(error Breakpoint reached. Exiting...)

print.debug.enable ?= false
print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $(1))))

print.trace.enable ?= false
print.trace = $(if $(findstring $(print.trace.enable),true),$(info $(LF)======= $(if $(strip $(1)),$(strip $(1)),make $@) =======))



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
# str = $(call str.rpad,str,col)
# str = $(call str.lpad,str,col)
#-----------------------------------------------------------
# Pads str with whitespace so the total length is the same as col.
# Col is a sequence of "." to specify the column width.
# Strings containing LF characters may not be padded correctly.
#
# Example:
#   col := ..............................
#   str := Some Text
#   $(info [$(col)])                            [..............................]
#   $(info [$(str)])                            [Some Text]
#   $(info [$(call str.rpad,$(str),$(col))])    [Some Text                     ]
#   $(info [$(call str.lpad,$(str),$(col))])    [                     Some Text]
#-----------------------------------------------------------

str.pad.clear_if_eq = $(if $(subst $(2),,$(1)),$(1),)
str.rpad = $(if $(1),$(1)$(subst .,$(SPACE),$(call str.pad.clear_if_eq,$(2:$(call str.subst.list_to_str,$(chr.nonwhitespace),.,$(call str.subst.vars_to_str,$(chr.whitespace.vars),.,$(1)))%=%),$(2))),$(subst .,$(SPACE),$(2)))
str.lpad = $(if $(1),$(subst .,$(SPACE),$(call str.pad.clear_if_eq,$(2:$(call str.subst.list_to_str,$(chr.nonwhitespace),.,$(call str.subst.vars_to_str,$(chr.whitespace.vars),.,$(1)))%=%),$(2)))$(1),$(subst .,$(SPACE),$(2)))



#-----------------------------------------------------------
# str = $(call str.concat,[sep],[str1],[str2],...)
# str = $(call str.concat.pair,[sep],[str1],[str2])
#-----------------------------------------------------------
# Concatentates each string argument with the given separator.
# Empty strings are skipped and no separator is included for them.
#-----------------------------------------------------------

str.concat.pair = $(if $(and $(2),$(3)),$(2)$(1)$(3),$(or $(2),$(3)))
str.concat = $(if $(or $(3),$(4),$(5),$(6),$(7),$(8),$(9)),$(call str.concat.pair,$(1),$(2),$(call str.concat,$(1),$(3),$(4),$(5),$(6),$(7),$(8),$(9))),$(2))



#-----------------------------------------------------------
# str = $(call str.digits.addprefix,{prefix},{str})
# str = $(call str.digits.addsuffix,{suffix},{str})
#-----------------------------------------------------------
# Prefixes or suffixes each numeric character (0-9) in {str}.
# $(EMPTY) -> $(EMPTY)
# Ex:
#   $(call str.digits.addprefix,.,1234) --> .1.2.3.4
#-----------------------------------------------------------
str.digits.addprefix = $(subst 9,$(1)9,$(subst 8,$(1)8,$(subst 7,$(1)7,$(subst 6,$(1)6,$(subst 5,$(1)5,$(subst 4,$(1)4,$(subst 3,$(1)3,$(subst 2,$(1)2,$(subst 1,$(1)1,$(subst 0,$(1)0,$(2)))))))))))
str.digits.addsuffix = $(subst 9,9$(1),$(subst 8,8$(1),$(subst 7,7$(1),$(subst 6,6$(1),$(subst 5,5$(1),$(subst 4,4$(1),$(subst 3,3$(1),$(subst 2,2$(1),$(subst 1,1$(1),$(subst 0,0$(1),$(2)))))))))))



#-----------------------------------------------------------
# str = $(call str.subst.vars_to_vars,{vars_from},{vars_to},{str})
# str = $(call str.subst.vars_to_list,{vars_from},{list_to},{str})
# str = $(call str.subst.list_to_vars,{list_from},{vars_to},{str})
# str = $(call str.subst.list_to_list,{list_from},{list_to},{str})
# str = $(call str.subst.vars_to_str,{vars_from},{str_to},{str})
# str = $(call str.subst.list_to_str,{list_from},{str_to},{str})
# str = $(call str.subst.prefix_vars,{str_prefix},{vars_from},{str})
# str = $(call str.subst.prefix_list,{str_prefix},{list_from},{str})
# str = $(call str.subst.suffix_vars,{str_suffix},{vars_from},{str})
# str = $(call str.subst.suffix_list,{str_suffix},{list_from},{str})
# str = $(call str.subst.wrap_vars,{str_prefix},{str_suffix},{vars_from},{str})
# str = $(call str.subst.wrap_list,{str_prefix},{str_suffix},{list_from},{str})
#-----------------------------------------------------------
# Performs a series of substitutions on {str}.
#
#  {vars_...}    Space-separated list of variable names
#                  Each variable in the list is expanded before substitution.
#                  This allows for substituting special characters, $(EMPTY), etc.
#  {list_...}    Space-separated list of strings
#                  Each value in the list is used literally.
#                  Faster, more convenient when there are no special characters involved.
#  {str...}      Singlular string value.
#                  May contain special characters if expanding directly in the
#                  function call; $(call ....,$(str))  <-- expanding variable "str"
#
#-----------------------------------------------------------
# Variants:
#
# many_to_many:      Performs: $(subst from[i],to[i],{str})
#  .vars_to_vars:      for each [i] in pair: from[i] = $(vars_from[i]), to[i] = $(vars_to[i])
#  .vars_to_list:      for each [i] in pair: from[i] = $(vars_from[i]), to[i] = $(vars_to[i])
#  .list_to_vars:      for each [i] in pair: from[i] = $(vars_from[i]), to[i] = $(vars_to[i])
#  .list_to_list:      for each [i] in pair: from[i] = $(vars_from[i]), to[i] = $(vars_to[i])
#
# many_to_one:       Performs: $(subst from[i],{str_to},{str})
#  .vars_to_str:       for each [i] in: from[i] = $(vars_from[i])
#  .list_to_str:       for each [i] in: from[i] = list_from[i]
#
# prefix_many:       Performs: $(subst from[i],{str_prefix}from[i],{str})
#  .prefix_vars:       for each [i] in: from[i] = $(vars_from[i])
#  .prefix_list:       for each [i] in: from[i] = list_from[i]
#
# suffix_many:       Performs: $(subst from[i],from[i]{str_suffix},{str})
#  .suffix_vars:       for each [i] in: from[i] = $(vars_from[i])
#  .suffix_list:       for each [i] in: from[i] = list_from[i]
#
# wrap_many:         Performs: $(subst from[i],{str_prefix}from[i]{str_suffix},{str})
#  .wrap_vars:         for each [i] in: from[i] = $(vars_from[i])
#  .wrap_list:         for each [i] in: from[i] = list_from[i]
#
#-----------------------------------------------------------
str.subst.vars_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$($(firstword $(2))),$(3))),$(3))
str.subst.vars_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.vars_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(1))),$(firstword $(2)),$(3))),$(3))
str.subst.list_to_vars = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_vars,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$($(firstword $(2))),$(3))),$(3))
str.subst.list_to_list = $(if $(and $(3),$(firstword $(1)),$(firstword $(2))),$(call str.subst.list_to_list,$(wordlist 2,$(words $(1)),$(1)),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(1)),$(firstword $(2)),$(3))),$(3))
 str.subst.vars_to_str = $(if $(and $(3),$(firstword $(1))),$(call str.subst.vars_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $($(firstword $(1))),$(2),$(3))),$(3))
 str.subst.list_to_str = $(if $(and $(3),$(firstword $(1))),$(call str.subst.list_to_str,$(wordlist 2,$(words $(1)),$(1)),$(2),$(subst $(firstword $(1)),$(2),$(3))),$(3))
 str.subst.prefix_vars = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$(1)$($(firstword $(2))),$(3))),$(3))
 str.subst.prefix_list = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.prefix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(1)$(firstword $(2)),$(3))),$(3))
 str.subst.suffix_vars = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_vars,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $($(firstword $(2))),$($(firstword $(2)))$(1),$(3))),$(3))
 str.subst.suffix_list = $(if $(and $(3),$(1),$(firstword $(2))),$(call str.subst.suffix_list,$(1),$(wordlist 2,$(words $(2)),$(2)),$(subst $(firstword $(2)),$(firstword $(2))$(1),$(3))),$(3))
   str.subst.wrap_vars = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_vars,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $($(firstword $(3))),$(1)$($(firstword $(3)))$(2),$(4))),$(4))
   str.subst.wrap_list = $(if $(and $(4),$(or $(1),$(2)),$(firstword $(3))),$(call str.subst.wrap_list,$(1),$(2),$(wordlist 2,$(words $(3)),$(3)),$(subst $(firstword $(3)),$(1)$(firstword $(3))$(2),$(4))),$(4))



#-----------------------------------------------------------
# str = $(call str.escape.vars,{vars},{str})
# str = $(call str.expand.vars,{vars},{str})
#-----------------------------------------------------------
# .escape      Substitutes each $(var) with literal "$(var)".
# .expand      Substitutes each literal "$(var)" with $(var).
#-----------------------------------------------------------

str.escape.vars = $(call str.subst.vars_to_list,$(1),$(foreach var,$(1),$$($(var))),$(2))
str.expand.vars = $(call str.subst.list_to_vars,$(foreach var,$(1),$$($(var))),$(1),$(2))



#-----------------------------------------------------------
# newlist = $(call list.map,function,list)
#-----------------------------------------------------------
# Applies the function to each element of the (space-separated) list
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#-----------------------------------------------------------

list.map = $(foreach a,$(2),$(call $(1),$(a)))



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

list.foreach.pair = $(subst $(POUND),,$(subst $(POUND)$(SPACE),$(6),$(foreach __pair,$(join $(addsuffix $(POUND),$(2)),$(4)),$(subst $$($(1)),$(firstword $(subst $(POUND),$(SPACE),$(__pair))),$(subst $$($(3)),$(lastword $(subst $(POUND),$(SPACE),$(__pair))),$(5)))$(POUND))))



#-----------------------------------------------------------
# str = $(call list.concat,sep,list)
#-----------------------------------------------------------
# Concatentates a (space-separated) list of strings with the given separator.
#-----------------------------------------------------------

list.concat = $(subst $(SPACE),$(1),$(strip $(2)))



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
# digit := $(call digit.inc,{digit},[prefix])
# digit := $(call digit.dec,{digit},[prefix])
#-----------------------------------------------------------
# Increments or decrements digit by 1.
# Optional prefix is stripped before operation, and reapplied after.
# Over/underflow wraps to 0/9.
# $(EMPTY) is handled as digit=0.
#
#   $(call digit.inc,$(EMPTY))    --> 1
#   $(call digit.inc,9)           --> 0
#   $(call digit.dec,$(EMPTY))    --> 9
#   $(call digit.dec,0)           --> 9
#-----------------------------------------------------------

digit.inc  = $(addprefix $(2),$(word 1$(1:$(2)%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
digit.dec  = $(addprefix $(2),$(word 1$(1:$(2)%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))



#-----------------------------------------------------------
# int := $(call int.inc,{int})
# int := $(call int.dec,{int})
#-----------------------------------------------------------
# Increments or decrements an integer by 1.
# Negative numbers are supported.
# Returns empty if int is empty.
#-----------------------------------------------------------

int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))
int.dec = $(if $(filter 0 -%,$(1)),-)$(subst .,,$(call int.$(if $(filter 0 -%,$(1)),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))

int.inc.recurse = $(if $(basename $(1)),$(if $(1:%9=),$(basename $(1))$(call digit.inc,$(suffix $(1)),.),$(if $(1),$(call int.inc.recurse,$(basename $(1))).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $(1)),.),$(if $(1),.1.0)))
int.dec.recurse = $(if $(basename $(1)),$(if $(1:%0=),$(basename $(1))$(call digit.dec,$(suffix $(1)),.),$(if $(1),$(filter-out .0,$(call int.dec.recurse,$(basename $(1)))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $(1)),.)))



#-----------------------------------------------------------
# Integer comparisons
#-----------------------------------------------------------
# bool = $(call int.equ.0,{int})
# bool = $(call int.neq.0,{int})
# bool = $(call int.gtr.0,{int})
# bool = $(call int.geq.0,{int})
# bool = $(call int.leq.0,{int})
# bool = $(call int.lss.0,{int})
#
# Compares {int} to 0.
# Returns nonempty if comparison is true.
# Returns empty if comparison is false or if {int} is empty.
#
# Integer math
#   int = $(call int.abs,{int})
#   int = $(call int.neg,{int})
#
#   digit = $(call digit.inc,{digit},[prefix])
#   digit = $(call digit.dec,{digit},[prefix])
#-----------------------------------------------------------
# Increments or decrements digit by 1.
# Optional prefix is stripped before operation, and reapplied after.
# Over/underflow wraps to 0/9.
# $(EMPTY) is handled as digit=0.
#
#   $(call digit.inc,$(EMPTY))    --> 1
#   $(call digit.inc,9)           --> 0
#   $(call digit.dec,$(EMPTY))    --> 9
#   $(call digit.dec,0)           --> 9
#-----------------------------------------------------------
#-----------------------------------------------------------

int.equ.0 = $(filter 0,$(1))
#int.equ.0 = $(if $(1:0=),,true)
int.neq.0 = $(1:0=)
int.gtr.0 = $(filter-out 0 -%,$(1))
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
int.geq.0 = $(1:-%=)
int.leq.0 = $(filter 0 -%,$(1))
int.lss.0 = $(filter -%,$(1))
#int.lss.0 = $(if $(1:-%=),,true)



#-----------------------------------------------------------
#-----------------------------------------------------------
# int.abs:  Returns absolute value of {int};
#                   empty if {int} is empty.
# int.neg:  Returns negation of {int};
#                   empty if {int} is empty.
#-----------------------------------------------------------
int.abs = $(1:-%=%)
int.neg = $(if $(1:-%=),$(if $(1:0=),-$(1),$(1)),$(1:-%=%))



#-----------------------------------------------------------
# int = $(call int.clamp.lower.0,{int})
#-----------------------------------------------------------
# int.clamp.lower.0:  Returns {int} if int > 0; 0 otherwise.
#-----------------------------------------------------------
int.clamp.lower.0 = $(or $(filter-out -%,$(2)),0)


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
# len  = $(call list.length,{list})                     Returns number of items in list; 0 if list is empty.
#
# item = $(call list.str.escape,{str})                  Internal. Returns a list item containing str with special chars escaped.
# str  = $(call list.item.expand,{item})                Internal. Returns the original contents of str without escaping.
#
# idx  = $(call list.idx,{list},{idx})                  Returns idx   if (1<=idx<=len); empty otherwise.
# idx  = $(call list.idx.dec,{list},{idx})              Returns clamp(idx-1,0,len)
# idx  = $(call list.idx.inc,{list},{idx})              Returns clamp(idx+1,1,len+1)
# idx  = $(call list.idx.prev,{list},{idx})             Returns idx-1 if (1<=idx-1<=len); empty otherwise.
# idx  = $(call list.idx.next,{list},{idx})             Returns idx+1 if (1<=idx+1<=len); empty otherwise.
# idx  = $(call list.idx.first,{list},{idx})            Returns 1     if list is nonempty; empty otherwise.
# idx  = $(call list.idx.last,{list},{idx})             Returns len   if list is nonempty; empty otherwise.
#
# list = $(call list.insert,{list},{idx},{str})         Inserts item at index = idx    for 1<=idx  <=len+1 . Invalid idx returns list unchanged.
# list = $(call list.insert.prev,{list},{idx},{str})    Inserts item at index = idx-1  for 1<=idx-1<=len+1 . Invalid idx returns list unchanged.
# list = $(call list.insert.next,{list},{idx},{str})    Inserts item at index = idx+1  for 1<=idx+1<=len+1 . Invalid idx returns list unchanged.
# list = $(call list.prepend,{list},{str})              Inserts item at index = 1     .
# list = $(call list.append,{list},{str})               Inserts item at index = len+1 .
#
# list = $(call list.remove,{list},{idx})               Removes item at index = idx    for 1<=idx<=len   . Invalid idx returns list unchanged.
# list = $(call list.remove.prev,{list},{idx})          Removes item at index = idx-1  for 1<=idx-1<=len . Invalid idx returns list unchanged.
# list = $(call list.remove.next,{list},{idx})          Removes item at index = idx+1  for 1<=idx+1<=len . Invalid idx returns list unchanged.
# list = $(call list.remove.first,{list})               Removes item at index = 1   .
# list = $(call list.remove.last,{list})                Removes item at index = len .
#
# str  = $(call list.get,{list},{idx})                  Returns (unescaped) str at in
# str  = $(call list.get.prev,{list},{idx})
# str  = $(call list.get.next,{list},{idx})
# str  = $(call list.get.first,{list})
# str  = $(call list.get.last,{list})
#
# list = $(call list.set,{list},{idx},{str})
# list = $(call list.set.prev,{list},{idx},{str})
# list = $(call list.set.next,{list},{idx},{str})
# list = $(call list.set.first,{list},{str})
# list = $(call list.set.last,{list},{str})
#
#-----------------------------------------------------------



# misc
list.str.escape        = $(if $(1),$(subst $(LF),$$(LF),$(subst $(TAB),$$(TAB),$(subst $(SPACE),$$(SPACE),$(subst $(DOLLAR),$$(DOLLAR),$(1))))),$$(EMPTY))
list.item.expand       = $(subst $$(DOLLAR),$(DOLLAR),$(subst $$(SPACE),$(SPACE),$(subst $$(TAB),$(TAB),$(subst $$(LF),$(LF),$(subst $$(EMPTY),$(EMPTY),$(1))))))
list.length            = $(words $(1))
list.trim              = $(strip $(subst $$(EMPTY),,$(1)))

# list.idx
list.idx               = $(if $(and $(filter-out 0 -%,$(2)),$(word $(2),$(1))),$(2),$(EMPTY))
list.idx.dec           = $(words $(wordlist 2,$(or $(filter-out -%,$(2)),0),$(1) $$))
list.idx.inc           = $(words $(wordlist 1,$(or $(filter-out -%,$(2)),$(words $(1))),$(1)) $$)
list.idx.prev          = $(call list.idx,$(1),$(call list.idx.dec,$(1),$(2)))
list.idx.next          = $(call list.idx,$(1),$(call list.idx.inc,$(1),$(2)))
list.idx.first         = $(if $(filter-out 0,$(words $(1))),1,$(EMPTY))
list.idx.last          = $(filter-out 0,$(words $(1)))

# list.insert
list.insert            = $(call list.item.insert,$(1),$(2),$(call list.str.escape,$(3)))
list.insert.prev       = $(call list.item.insert.prev,$(1),$(2),$(call list.str.escape,$(3)))
list.insert.next       = $(call list.item.insert.next,$(1),$(2),$(call list.str.escape,$(3)))
list.prepend           = $(call list.item.prepend,$(1),$(call list.str.escape,$(2)))
list.append            = $(call list.item.append,$(1),$(call list.str.escape,$(2)))

# list.item.insert
list.item.insert       = $(strip $(if $(call list.idx,$(1) $$,$(2)),$(wordlist 1,$(call list.idx.dec,$(1),$(2)),$(1)) $(3) $(wordlist $(2),$(words $(1)),$(1)),$(1)))
list.item.insert.prev  = $(call list.item.insert,$(1),$(call list.idx.dec,$(1) $$,$(2)),$(3))
list.item.insert.next  = $(call list.item.insert,$(1),$(call list.idx.inc,$$ $(1),$(2)),$(3))
list.item.prepend      = $(strip $(2) $(1))
list.item.append       = $(strip $(1) $(2))

# list.remove
list.remove            = $(call list.item.remove,$(1),$(2))
list.remove.prev       = $(call list.item.remove.prev,$(1),$(2))
list.remove.next       = $(call list.item.remove.next,$(1),$(2))
list.remove.first      = $(call list.item.remove.first,$(1))
list.remove.last       = $(call list.item.remove.last,$(1))

# list.item.remove
list.item.remove       = $(strip $(if $(call list.idx,$(1),$(2)),$(wordlist 1,$(call list.idx.dec,$(1),$(2)),$(1)) $(wordlist $(call list.idx.inc,$(1),$(2)),$(words $(1)),$(1)),$(1)))
list.item.remove.prev  = $(call list.item.remove,$(1),$(call list.idx.dec,$(1) $$,$(2)))
list.item.remove.next  = $(call list.item.remove,$(1),$(call list.idx.inc,$$ $(1),$(2)))
list.item.remove.first = $(call list.item.remove,$(1),$(call list.idx.first,$(1)))
list.item.remove.last  = $(call list.item.remove,$(1),$(call list.idx.last,$(1)))

# list.get
list.get               = $(call list.item.expand,$(call list.item.get,$(1),$(2)))
list.get.prev          = $(call list.item.expand,$(call list.item.get.prev,$(1),$(2)))
list.get.next          = $(call list.item.expand,$(call list.item.get.next,$(1),$(2)))
list.get.first         = $(call list.item.expand,$(call list.item.get.first,$(1),$(2)))
list.get.last          = $(call list.item.expand,$(call list.item.get.last,$(1),$(2)))

# list.item.get
list.item.get          = $(if $(call list.idx,$(1),$(2)),$(word $(2),$(1)),$(EMPTY))
list.item.get.prev     = $(call list.item.get,$(1),$(call list.idx.dec,$(1) $$,$(2)))
list.item.get.next     = $(call list.item.get,$(1),$(call list.idx.inc,$$ $(1),$(2)))
list.item.get.first    = $(firstword $(1))
list.item.get.last     = $(lastword $(1))

# list.set
list.set               = $(call list.item.set,$(1),$(2),$(call list.str.escape,$(3)))
list.set.prev          = $(call list.item.set.prev,$(1),$(2),$(call list.str.escape,$(3)))
list.set.next          = $(call list.item.set.next,$(1),$(2),$(call list.str.escape,$(3)))
list.set.first         = $(call list.item.set.first,$(1),$(call list.str.escape,$(2)))
list.set.last          = $(call list.item.set.last,$(1),$(call list.str.escape,$(2)))

# list.item.set
list.item.set          = $(strip $(if $(call list.idx,$(1),$(2)),$(wordlist 1,$(call list.idx.dec,$(1),$(2)),$(1)) $(3) $(wordlist $(call list.idx.inc,$(1),$(2)),$(words $(1)),$(1)),$(1)))
list.item.set.prev     = $(call list.item.set,$(1),$(call list.idx.dec,$(1) $$,$(2)),$(3))
list.item.set.next     = $(call list.item.set,$(1),$(call list.idx.inc,$$ $(1),$(2)),$(3))
list.item.set.first    = $(call list.item.set,$(1),$(call list.idx.first,$(1)),$(2))
list.item.set.last     = $(call list.item.set,$(1),$(call list.idx.last,$(1)),$(2))


$(info )
$(info )
$(info )
$(error Exiting...)



list0 :=
list1 := $(call list.str.escape,Item 1)
list2 := $(list1) $(call list.str.escape,Item 2)
list3 := $(list2) $(call list.str.escape,Item 3)

list.org := $(list3)
idx := 5
rep := New Item
list.new := $(call list.insert.prev,$(list.org),$(idx),$(rep))

$(info )
$(call print.vars,list.org idx rep list.new)
$(info )
$(error Exiting...)
