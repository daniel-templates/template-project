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
# WARNING: This file (and all makefiles) must maintain its
# original encoding! UTF-8, LF line endings.
# AND BY GOD don't let your IDE substitute TAB with SPACE!
#===============================================================================


#===============================================================================
# USER CONFIGURABLE VALUES
#===============================================================================

# Line Formatting ===================== type: [line]
line.indent        ?= $s$s
info.prefix        ?= $e
warning.prefix     ?= >>
error.prefix       ?= >>

# Type Formatting ===================== type: [line]
command.prefix     ?= $(line.indent)$v$s

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
#-------------------------------------------------------------------------------

# Empty String ======================== type: [empty]
override empty :=# Empty String
override e     :=$(empty)# Alias '$e'

# Logical Values ====================== type: {str}, [empty]
override true  := true
override false := $(empty)

# Whitespace Characters =============== type: {char}
override char.space := $e $e
override char.tab   := $e	$e
override define char.linefeed # BEGIN: definition must contain exactly two empty lines. Do not modify.


endef # END

# Symbols ============================= type: {char}
override char.grave  := `
override char.tilde  := ~
override char.excl   := !
override char.commat := @
override char.num    := \#$e
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
override char.bsol   := \$e
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

# Aliases for Common Characters ======= type: {char}
override s := $(char.space)
override t := $(char.tab)
override n := $(char.linefeed)
override v := $(char.dollar)
override p := $(char.percnt)
override c := $(char.comma)
override o := $(char.period)

# Character Sets ====================== type: {list{char}}
override char.type.lower    := a b c d e f g h i j k l m n o p q r s t u v w x y z
override char.type.upper    := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
override char.type.digit    := 0 1 2 3 4 5 6 7 8 9
override char.type.symbol   := ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , . < > / ?
override char.type.word     := $(char.type.lower) $(char.type.upper) $(char.type.digit) ` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , < . > / ?
override char.type.var      := $(char.type.lower) $(char.type.upper) $(char.type.digit) ` ~ ! @    $$ % ^ & * ( ) - _   + { } [ ] \ | ;   ' " , < . > / ?
override char.type.alphanum := $(char.type.lower) $(char.type.upper) $(char.type.digit)
override char.type.letter   := $(char.type.lower) $(char.type.upper)
override char.type.int      := 0 1 2 3 4 5 6 7 8 9 + -
override char.type.uint     := 0 1 2 3 4 5 6 7 8 9 +
override char.type.idx      :=   1 2 3 4 5 6 7 8 9 +
override char.type.pad      := .

# Character Namespaces ================ type: ns<char>
override char.vars.symbol := char.grave char.tilde char.excl char.commat char.num char.dollar char.percnt char.hat char.amp \
  char.ast char.lparen char.rparen char.hyphen char.lowbar char.equals char.plus char.lsqb char.rsqb char.lcub char.rcub    \
  char.bsol char.verbar char.semi char.colon char.apos char.quot char.comma char.period char.lt char.gt char.sol char.quest
override char.vars.ws := char.space char.tab char.linefeed

#===============================================================================




#===============================================================================
# TYPE CONVERSIONS
#===============================================================================
# Convert To Lower/Uppercase:
#  [lower]   <-- $(call str.to.lower,[str])                  Returns [lower]-case of [str].
#  [upper]   <-- $(call str.to.upper,[str])                  Returns [upper]-case of [str].
#
# Convert To/From Packed Word:
#  {word[T]} <-- $(call word.pack.T,{T},[T:val])             Returns a single word (no whitespace) containing an escaped
#  {word[T]} <-- $(call {T}.to.word[{T}],[T:val])              value of type T, or literal '$e' if [val] is [empty].
#
#  [T]       <-- $(call word.unpack.T,{T},[word[T]:val])     Returns the original value of [T:val], or [empty] if [val]
#  [T]       <-- $(call word[{T}].to.{T},[word[T]])            was originally [empty], or if [val] was omitted.
#
# Convert To/From List:
#  [list]     <-- $(call str.split,[list],[str:sep],[str:listsep])
#  [list]     <-- $(call str.to.list,[list],[str:sep],[str:listsep])
#  [list]     <-- $(call str.to.list[T],{T},[list],[str:sep],[str:keep_empty])
#  [list]     <-- $(call str.to.list[{T}],[list],[str:sep],[str:keep_empty])
#
#  [str]     <-- $(call list.concat,[list],[str:sep],[str:listsep])
#  [str]     <-- $(call list.to.str,[list],[str:sep],[str:listsep])
#  [str]     <-- $(call list[T].to.str,{T},[list],[str:sep],[str:keep_empty])
#  [str]     <-- $(call list[{T}].to.str,[list],[str:sep],[str:keep_empty])
#
# Convert To/From Pad:
#  [pad]     <-- $(call str.to.pad,[str:lines])              Returns a [pad] equal to the length of the longest line in [str].
#  [pad]     <-- $(call T.to.pad,{T},[T:val])                For all other singular types:
#  [pad]     <-- $(call {T}.to.pad,[T:val])                    Returns a [pad] equal to the length of [val].
#  [pad]     <-- $(call list.to.pad,[list:vals])             For normal lists: Returns a [pad] equal to the length of the longest [word] in [list].
#  [pad]     <-- $(call list[T].to.pad,{T},[list[T]:vals])   For all packed-word lists:
#  [pad]     <-- $(call list[{T}].to.pad,[list[T]:vals])       Returns a [pad] equal to the length of the longest {T} value in [list[T]].
#
#  [str]     <-- $(call pad.to.str,[pad],[char])             Returns a sequence of [char] equal in length to [pad].
#
#-------------------------------------------------------------------------------

# Convert To Lower/Uppercase ========== type: [lower], [upper]
override str.to.lower       = $(call str.subst.list_to_list,$(char.type.upper),$(char.type.lower),$1)
override str.to.upper       = $(call str.subst.list_to_list,$(char.type.lower),$(char.type.upper),$1)

# Convert To/From Packed Word ========= type: {word[T]}, [T]
override word.pack.T        = $(call $1.to.word[$1],$2)
override str.to.word[str]   = $(if $1,$(subst $n,$$n,$(subst $t,$$t,$(subst $s,$$s,$(subst $v,$$v,$1)))),$$e)
override list.to.word[list] = $(if $(strip $1),$(subst $s,$$s,$(subst $v,$$v,$(strip $1))),$$e)
override line.to.word[line] = $(if $1,$(subst $s,$$s,$(subst $v,$$v,$1)),$$e)
override word.to.word[word] = $(if $1,$(subst $v,$$v,$(strip $1)),$$e)
override int.to.word[int]   = $(if $1,$(strip $1),$$e)
override uint.to.word[uint] = $(if $1,$(strip $1),$$e)
override idx.to.word[idx]   = $(if $1,$(strip $1),$$e)
override pad.to.word[pad]   = $(if $1,$(strip $1),$$e)

override word.unpack.T      = $(call word[$1].to.$1,$2)
override word[str].to.str   = $(subst $$v,$v,$(subst $$s,$s,$(subst $$t,$t,$(subst $$n,$n,$(subst $$e,$e,$(strip $1))))))
override word[list].to.list = $(subst $$v,$v,$(subst $$s,$s,$(subst $$e,$e,$(strip $1))))
override word[line].to.line = $(subst $$v,$v,$(subst $$s,$s,$(subst $$e,$e,$(strip $1))))
override word[word].to.word = $(subst $$v,$v,$(subst $$e,$e,$(strip $1)))
override word[idx].to.idx   = $(subst $$e,$e,$(strip $1))
override word[uint].to.uint = $(subst $$e,$e,$(strip $1))
override word[idx].to.idx   = $(subst $$e,$e,$(strip $1))
override word[pad].to.pad   = $(subst $$e,$e,$(strip $1))

# Convert To/From List ================ type: [list[T]], [T]
override str.split          = $(str.to.list)# Alias
override str.to.list        = $(strip $(subst $2,$(or $3,$s),$1))

override str.to.list[T]     = $(call str.to.list,$(call $1.to.word[$1],$2),$(call $1.to.word[$1],$3),$(if $4,$$e$s$$e))
override str.to.list[str]   = $(call str.to.list[T],str,$1,$2,$3)
override str.to.list[list]  = $(call str.to.list[T],list,$1,$2,$3)
override str.to.list[line]  = $(call str.to.list[T],line,$1,$2,$3)
override str.to.list[word]  = $(call str.to.list[T],word,$1,$2,$3)
override str.to.list[int]   = $(call str.to.list[T],int,$1,$2,$3)
override str.to.list[uint]  = $(call str.to.list[T],uint,$1,$2,$3)
override str.to.list[idx]   = $(call str.to.list[T],idx,$1,$2,$3)
override str.to.list[pad]   = $(call str.to.list[T],pad,$1,$2,$3)

override list.concat        = $(list.to.str)# Alias
override list.to.str        = $(subst $s,$2,$(strip $(subst $(or $3,$s),$s,$1)))

override list[T].to.str     = $(call word[$1].to.$1,$(call list.to.str,$2,$(call $1.to.word[$1],$3),$(if $4,$$e$s$$e)))
#override list[T].to.str     = $(call word[$1].to.$1,$(call list.to.str,$(if $4,$(subst $$e,$e,$2),$2),$(call $1.to.word[$1],$3)))
override list[str].to.str   = $(call list[T].to.str,str,$1,$2,$3)
override list[list].to.str  = $(call list[T].to.str,list,$1,$2,$3)
override list[line].to.str  = $(call list[T].to.str,line,$1,$2,$3)
override list[word].to.str  = $(call list[T].to.str,word,$1,$2,$3)
override list[int].to.str   = $(call list[T].to.str,int,$1,$2,$3)
override list[uint].to.str  = $(call list[T].to.str,uint,$1,$2,$3)
override list[idx].to.str   = $(call list[T].to.str,idx,$1,$2,$3)
override list[pad].to.str   = $(call list[T].to.str,pad,$1,$2,$3)

# Convert To/From Pad ================= type: [pad], [str]
override T.to.pad           = $(call $1.to.pad,$2)
override str.to.pad         = $(lastword $(sort $(call line.to.pad,$(subst $t,$(pad.tab),$1))))
override list.to.pad        = $(lastword $(sort $(foreach word,$1,$(call word.to.pad,$(word)))))
override line.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(subst $s,.,$1))
override word.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(strip $1))
override int.to.pad         = $(call str.subst.list_to_str,$(char.type.int),.,$(strip $1))
override uint.to.pad        = $(call str.subst.list_to_str,$(char.type.uint),.,$(strip $1))
override idx.to.pad         = $(call str.subst.list_to_str,$(char.type.idx),.,$(strip $1))
override pad.to.pad         = $(strip $1)

override list[T].to.pad     = $(lastword $(sort $(foreach word[$1],$2,$(call $1.to.pad,$(call word[$1].to.$1,$(word[$1]))))))
override list[str].to.pad   = $(call list[T].to.pad,str,$1)
override list[list].to.pad  = $(call list[T].to.pad,list,$1)
override list[line].to.pad  = $(call list[T].to.pad,line,$1)
override list[word].to.pad  = $(call list[T].to.pad,word,$1)
override list[int].to.pad   = $(call list[T].to.pad,int,$1)
override list[uint].to.pad  = $(call list[T].to.pad,uint,$1)
override list[idx].to.pad   = $(call list[T].to.pad,idx,$1)
override list[pad].to.pad   = $(call list[T].to.pad,pad,$1)

override pad.to.str         = $(subst .,$(or $2,$s),$(strip $1))

#===============================================================================






#===============================================================================
# STRING SUBSTITUTIONS
#===============================================================================
# Type:                Description:
#  [var]                Variable name, or [empty].
#  [list{var}]          Whitespace-separated list of variables, or [empty].
#                       Variables are expanded before use.
#                       Unlike [str] substitutions, variable 'empty' can be used to match/replace
#                       the empty string.
#
#  [str]                String containing any characters, or [empty]. Used literally.
#  [list{word}]         Whitespace-separated list of {word}s, or [empty].
#                       Individual words cannot contain whitespace or be [empty].
#-------------------------------------------------------------------------------
# Arguments:           If Argument Omitted:             If Argument Provided:
#  [var:from]           Nothing is matched               Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [list{var}:from]     Nothing is matched               Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [str:from]           Nothing is matched               Matches   {str}  in [in]
#  [list{word}:from]    Nothing is matched               Matches  {word}  in [in]
#
#  [var:to]             Nothing is replaced              Replaces matches with $({var})
#  [list{var}:to]       Nothing is replaced              Replaces matches with $({var})
#  [str:to]             Replaces matches with [empty]    Replaces matches with   {str}
#  [list{word}:to]      Replaces matches with [empty]    Replaces matches with  {word}
#
#-------------------------------------------------------------------------------
# Single Match, Single Replace:
#  [str] <-- $(call str.subst.str_to_str,[str:from],[str:to],[str:in])
#  [str] <-- $(call str.subst.str_to_var,[str:from],[var:to],[str:in])
#  [str] <-- $(call str.subst.var_to_str,[var:from],[str:to],[str:in])
#  [str] <-- $(call str.subst.var_to_var,[var:from],[var:to],[str:in])
#
# Multiple Match, Single Replace:
#  [str] <-- $(call str.subst.list_to_str,[list{word}:from],[str:to],[str:in])
#  [str] <-- $(call str.subst.list_to_var,[list{word}:from],[var:to],[str:in])
#  [str] <-- $(call str.subst.vars_to_str,[list{var}:from],[str:to],[str:in])
#  [str] <-- $(call str.subst.vars_to_var,[list{var}:from],[var:to],[str:in])
#
# Multiple Match, Multiple Replace:
#  [str] <-- $(call str.subst.list_to_list,[list:from],[list{word}:to],[str:in])
#  [str] <-- $(call str.subst.list_to_vars,[list:from],[list{var}:to],[str:in])
#  [str] <-- $(call str.subst.vars_to_list,[list{var}:from],[list{word}:to],[str:in])
#  [str] <-- $(call str.subst.vars_to_vars,[list{var}:from],[list{var}:to],[str:in])
#
# Single Match, Single Prefix:
#  [str] <-- $(call str.subst.str_prefix,[str:find],[str:prefix],[str:in])
#  [str] <-- $(call str.subst.var_prefix,[var:find],[str:prefix],[str:in])
#
# Multiple Match, Single Prefix:
#  [str] <-- $(call str.subst.list_prefix,[list{word}:find],[str:prefix],[str:in])
#  [str] <-- $(call str.subst.vars_prefix,[list{var}:find],[str:prefix],[str:in])
#
# Single Match, Single Suffix:
#  [str] <-- $(call str.subst.str_suffix,[str:find],[str:suffix],[str:in])
#  [str] <-- $(call str.subst.var_suffix,[var:find],[str:suffix],[str:in])
#
# Multiple Match, Single Suffix:
#  [str] <-- $(call str.subst.list_suffix,[list{word}:find],[str:suffix],[str:in])
#  [str] <-- $(call str.subst.vars_suffix,[list{var}:find],[str:suffix],[str:in])
#
# Escape Sequences:
#  [str]       <-- $(call str.escape.vars,[list{var}],[str:in])  Substitutes each expanded value $(var) with literal string '$(var)'.
#  [str]       <-- $(call str.expand.vars,[list{var}],[str:in])  Substitutes each literal string '$(var)' with the expanded value of $(var).
#
#-------------------------------------------------------------------------------

# Recursion Helpers: Basically list.reduce but with args in a different order
# [str] <-- $(call str.subst.reduce.multi_to_single,[func([word:1],[str:2], [acc])],[list:1],[str:2], [str:acc])
# [str] <-- $(call str.subst.reduce.multi_to_multi, [func([word:1],[word:2],[acc])],[list:1],[list:2],[str:acc])
override str.subst.reduce.multi_to_single = $(if $(firstword $2),$(call str.subst.reduce.multi_to_single,$1,$(wordlist 2,$(words $2),$2),$3,$(call $1,$(firstword $2),$3,$4)),$4)
override str.subst.reduce.multi_to_multi  = $(if $(or $(firstword $2),$(firstword $3)),$(call str.subst.reduce.multi_to_multi,$1,$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3),$(call $1,$(firstword $2),$(firstword $3),$4)),$4)

# Single Match, Single Replace ======== type: [str]
override str.subst.str_to_str   = $(if $1,$(subst $1,$2,$3),$3)
override str.subst.str_to_var   = $(if $1,$(if $2,$(subst $1,$($2),$3),$3),$3)
override str.subst.var_to_str   = $(if $1,$(if $($1),$(subst $($1),$2,$3),$(if $3,$3,$2)),$3)
override str.subst.var_to_var   = $(if $1,$(if $2,$(if $($1),$(subst $($1),$($2),$3),$(if $3,$3,$($2))),$3),$3)

# Multiple Match, Single Replace ====== type: [str]
override str.subst.list_to_str  = $(call str.subst.reduce.multi_to_single,str.subst.str_to_str,$1,$2,$3)
override str.subst.list_to_var  = $(call str.subst.reduce.multi_to_single,str.subst.str_to_var,$1,$2,$3)
override str.subst.vars_to_str  = $(call str.subst.reduce.multi_to_single,str.subst.var_to_str,$1,$2,$3)
override str.subst.vars_to_var  = $(call str.subst.reduce.multi_to_single,str.subst.var_to_var,$1,$2,$3)

# Multiple Match, Multiple Replace ==== type: [str]
override str.subst.list_to_list = $(call str.subst.reduce.multi_to_multi,str.subst.str_to_str,$1,$2,$3)
override str.subst.list_to_vars = $(call str.subst.reduce.multi_to_multi,str.subst.str_to_var,$1,$2,$3)
override str.subst.vars_to_list = $(call str.subst.reduce.multi_to_multi,str.subst.var_to_str,$1,$2,$3)
override str.subst.vars_to_vars = $(call str.subst.reduce.multi_to_multi,str.subst.var_to_var,$1,$2,$3)

# Single Match, Single Prefix  ======== type: [str]
override str.subst.str_prefix   = $(if $1,$(subst $1,$2$1,$3),$3)
override str.subst.var_prefix   = $(if $1,$(if $($1),$(subst $($1),$2$($1),$3),$(if $3,$3,$2)),$3)

# Multiple Match, Single Prefix ======= type: [str]
override str.subst.list_prefix  = $(call str.subst.reduce.multi_to_single,str.subst.str_prefix,$1,$2,$3)
override str.subst.vars_prefix  = $(call str.subst.reduce.multi_to_single,str.subst.var_prefix,$1,$2,$3)

# Single Match, Single Suffix  ======== type: [str]
override str.subst.str_suffix   = $(if $1,$(subst $1,$1$2,$3),$3)
override str.subst.var_suffix   = $(if $1,$(if $($1),$(subst $($1),$($1)$2,$3),$(if $3,$3,$2)),$3)

# Multiple Match, Single Suffix ======= type: [str]
override str.subst.list_suffix  = $(call str.subst.reduce.multi_to_single,str.subst.str_suffix,$1,$2,$3)
override str.subst.vars_suffix  = $(call str.subst.reduce.multi_to_single,str.subst.var_suffix,$1,$2,$3)

# Escape Sequences ==================== type: [str]
override str.escape.vars        = $(call str.subst.vars_to_list,$1,$(foreach var,$1,$$($(var))),$2)
override str.expand.vars        = $(call str.subst.list_to_vars,$(foreach var,$1,$$($(var))),$1,$2)

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
#-------------------------------------------------------------------------------
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
#-----------------------------------------------------------
# Length:
#  Returns the number of nonempty words in [list].
#  - For normal lists, this is equivalent to $(words [list]).
#  - For packed lists, excludes each {word} containing a packed [empty] value.
#
# {uint:len} <-- $(call list.length,[list])
#
#-----------------------------------------------------------
# Trim:
#  Removes 'empty' words.
#  - For normal lists, this is equivalent to $(strip [list]).
#  - For packed lists, removes each {word} containing a packed [empty] value.
#
# [list] <-- $(call list.trim,[list])
#
#-----------------------------------------------------------
# Logical Tests:
#  Performs a logical test on a [list].
#  Returns [list] if the condition is true, [empty] if false.
#
# [list] <-- $(call list.is.empty,[list])           $(words [list]) == 0
# [list] <-- $(call list.is.nonempty,[list])        $(words [list]) != 0
# [list] <-- $(call list.has,[list],[word])         [list].contains([word]) == true
# [list] <-- $(call list.has.not,[list],[word])     [list].contains([word]) == false
#
#-----------------------------------------------------------
# Contains:
#  Returns [word] if [list] contains [word]; [empty] otherwise.
#  - For packed lists, packs [type] before search, and returns unpacked [type] if search was successful.
#
# [word] <-- $(call list.contains,[list],[word])
#
#
#-----------------------------------------------------------
# Join:
#  Maps N [list]s to 1 [list{list}].
#  Iterates over N [list]s in parallel. For each set of N [words], joins
#  them into a {list} and packs that {list} into a single-word {word{list}}.
#  - For packed lists, the original packed type is maintained.
#  Returns the resulting [list] of {word{list}}.
#
# [list{list}] <-- $(call list.join,[list:1],...,[list:4])
#
#-----------------------------------------------------------
# Map:
#  Maps N [list]s to 1 [list].
#  Iterates over N [list]s in parallel, calling a [func] with each set of N [word]s.
#  - For packed lists, words are unpacked before calling [func].
#    The result of [func] is re-packed before the next iteration.
#  Returns the list of words produced by [func].
#
# [list] <-- $(call list.map,[func[word]([word:1],...,[word:4])],[list:1],...,[list:4])
#
#-----------------------------------------------------------
# Reduce:
#  Maps N [list]s to 1 [str]ing.
#  Iterates over N [list]s in parallel, calling a [func] with the result of the previous
#  iteration [acc] and a set of N [word]s.
#  - For packed lists, words are unpacked before calling [func].
#    The result of [func] is not re-packed; [acc] is never modified by anything but [func].
#  Returns the final value of [acc] produced by [func].
#
#  [str] <-- $(call list.reduce,[func[str]([str:acc],[word:1],...,[word:4])],[str:acc],[list:1],...,[list:4])
#
#-----------------------------------------------------------
# List Index:
#  [idx]  <-- $(call list.idx,[list],[int:idx])             Returns [idx] if 1 <= [idx] <= $(words [list]); [empty] otherwise.
#  [idx]  <-- $(call list.idx.prev,[list],[int:idx])                [idx]+1
#  [idx]  <-- $(call list.idx.next,[list],[int:idx])                [idx]-1
#  [idx]  <-- $(call list.idx.first,[list])                 Returns 1 if [list] has at least 1 {word}; [empty] otherwise.
#  [idx]  <-- $(call list.idx.last,[list])                  Returns $(words [list]) if [list] has at least 1 {word}; [empty] otherwise.
#
#-----------------------------------------------------------
# Accessing Individual Elements:
#  [list] <-- $(call list.insert,[list],[word],[idx])       Inserts word at 1 <= [idx] <= 1+$(words [list]).
#  [list] <-- $(call list.insert.prev,[list],[word],[idx])    [idx]-1
#  [list] <-- $(call list.insert.next,[list],[word],[idx])    [idx]+1
#  [list] <-- $(call list.prepend,[list],[word])              1
#  [list] <-- $(call list.append,[list],[word])               $(words [list])
#
#  [list] <-- $(call list.remove,[list],[idx])              Removes word at 1 <= [idx] <= $(words [list])
#  [list] <-- $(call list.remove.prev,[list],[idx])           [idx]-1
#  [list] <-- $(call list.remove.next,[list],[idx])           [idx]+1
#  [list] <-- $(call list.remove.first,[list])                1
#  [list] <-- $(call list.remove.last,[list])                 $(words [list])
#
#  [word] <-- $(call list.get,[list],[idx])                 Returns word at 1 <= [idx] <= $(words [list])
#  [word] <-- $(call list.get.prev,[list],[idx])              [idx]-1
#  [word] <-- $(call list.get.next,[list],[idx])              [idx]+1
#  [word] <-- $(call list.get.first,[list])                   1
#  [word] <-- $(call list.get.last,[list])                    $(words [list])
#
#  [list] <-- $(call list.set,[list],[word],[idx])          Replaces word at 1 <= [idx] <= $(words [list]).
#  [list] <-- $(call list.set.prev,[list],[word],[idx])       [idx]-1.
#  [list] <-- $(call list.set.next,[list],[word],[idx])       [idx]+1.
#  [list] <-- $(call list.set.first,[list],[word])            1
#  [list] <-- $(call list.set.last,[list],[word])             $(words [list])
#
#-------------------------------------------------------------------------------

# list.is ============================= type: [list[type]]
override list.is.empty          = $(if $(firstword $1),,$1)
override list.is.nonempty       = $(if $(firstword $1),$1)

override list[str].is.empty     = $(if $(firstword $(call list[str].trim,$1)),,$1)
override list[str].is.nonempty  = $(if $(firstword $(call list[str].trim,$1)),$1)

# list.has ============================ type: [list[type]]
override list.has               = $(if $(call list.contains,$1,$2),$1)
override list.has.not           = $(if $(call list.contains,$1,$2),,$1)

override list[str].has          = $(if $(call list[str].contains,$1,$2),$1)
override list[str].has.not      = $(if $(call list[str].contains,$1,$2),,$1)

# list.contains ======================= type: [type]
override list.contains          = $(if $(findstring $(strip $2),$(strip $1)),$2)
override list[str].contains     = $(if $(findstring $(call str.to.word[str],$2),$1),$2)

# list.length ========================= type: {uint}
override list.length            = $(words $1)
override list[str].length       = $(call list.length,$(call list[str].trim,$1))

# list.trim =========================== type: [list[type]]
override list.trim              = $(strip $1)
override list[str].trim         = $(call list.trim,$(subst $$e,,$1))

# list.join =========================== type: [list[list[type]]]
override list.join              = $(join $(subst $v,$$v,$1),$(if $(or $2,$3,$4),$(addprefix $$s,$(call list.join,$2,$3,$4))))
override list[str].join         = $(list.join)

# list.map ============================ type: [list[type]]
override list.map               = $(foreach word,$(call list.join,$2,$3,$4,$5),$(call list.map.adapter,$1,$(call word[list].to.list,$(word))))
override list.map.adapter       = $(call $1,$(word 1,$2),$(word 2,$2),$(word 3,$2),$(word 4,$2))

override list[str].map          = $(foreach word,$(call list[str].join,$2,$3,$4,$5),$(call list[str].map.adapter,$1,$(call word[list].to.list,$(word))))
override list[str].map.adapter  = $(call str.to.word[str],$(call $1,$(call word[str].to.str,$(word 1,$2)),$(call word[str].to.str,$(word 2,$2)),$(call word[str].to.str,$(word 3,$2)),$(call word[str].to.str,$(word 4,$2))))

# list.reduce ========================= type: [str]
override list.reduce            = $(call list.reduce.recurse,$1,$2,$(call list.join,$3,$4,$5,$6))
override list.reduce.recurse    = $(if $3,$(call list.reduce.recurse,$1,$(call list.reduce.adapter,$1,$2,$(call word[list].to.list,$(firstword $3))),$(wordlist 2,$(words $3),$3)),$2)
override list.reduce.adapter    = $(call $1,$2,$(word 1,$3),$(word 2,$3),$(word 3,$3),$(word 4,$3))

override list[str].reduce         = $(call list[str].reduce.recurse,$1,$2,$(call list[str].join,$3,$4,$5,$6))
override list[str].reduce.recurse = $(if $3,$(call list[str].reduce.recurse,$1,$(call list[str].reduce.adapter,$1,$2,$(call word[list].to.list,$(firstword $3))),$(wordlist 2,$(words $3),$3)),$2)
override list[str].reduce.adapter = $(call $1,$2,$(call word[str].to.str,$(word 1,$3)),$(call word[str].to.str,$(word 2,$3)),$(call word[str].to.str,$(word 3,$3)),$(call word[str].to.str,$(word 4,$3)))

# list.idx ============================ type: [idx]
override list.idx.dec           = $(if $2,$(words $(wordlist 2,$2,$1 +1)))# [uint] <-- clamp([uint:2]-1,0,len(list:1))
override list.idx.inc           = $(if $2,$(words $(wordlist 1,$2,$1) +1))# [uint] <-- clamp([uint:2]+1,1,len(list:1)+1)

override list.idx               = $(and $(filter-out 0,$2),$(word $2,$1),$2)
override list.idx.prev          = $(filter-out 0 $(words $1 +1),$(call list.idx.dec,$1 +1,$2))
override list.idx.next          = $(filter-out   $(words $1 +1),$(call list.idx.inc,$1   ,$2))
override list.idx.first         = $(if $(firstword $1),1)
override list.idx.last          = $(filter-out 0,$(words $1))

override list[str].idx          = $(call list.idx,$1,$2)
override list[str].idx.prev     = $(call list.idx.prev,$1,$2)
override list[str].idx.next     = $(call list.idx.next,$1,$2)
override list[str].idx.first    = $(call list.idx.first,$1)
override list[str].idx.last     = $(call list.idx.last,$1)

# list.insert ========================= type: [list[type]]
override list.insert.N          = $(strip $(if $3,$(wordlist 1,$(call list.idx.dec,$1,$3),$1) $2 $(wordlist $3,$(words $1),$1),$1))

override list.insert            = $(call list.insert.N,$1,$2,$(call list.idx,$1 $$,$3))
override list.insert.prev       = $(call list.insert.N,$1,$2,$(call list.idx.prev,$1 $$,$3))
override list.insert.next       = $(call list.insert.N,$1,$2,$(call list.idx.next,$1 $$,$3))
override list.prepend           = $(strip $2 $1)
override list.append            = $(strip $1 $2)

override list[str].insert       = $(call list.insert,$1,$(call str.to.word[str],$2),$3)
override list[str].insert.prev  = $(call list.insert.prev,$1,$(call str.to.word[str],$2),$3)
override list[str].insert.next  = $(call list.insert.next,$1,$(call str.to.word[str],$2),$3)
override list[str].prepend      = $(call list.prepend,$1,$(call str.to.word[str],$2))
override list[str].append       = $(call list.append,$1,$(call str.to.word[str],$2))

# list.remove ========================= type: [list[type]]
override list.remove.N          = $(strip $(if $2,$(wordlist 1,$(call list.idx.dec,$1,$2),$1) $(wordlist $(call list.idx.inc,$1,$2),$(words $1),$1),$1))

override list.remove            = $(call list.remove.N,$1,$(call list.idx,$1,$2))
override list.remove.prev       = $(call list.remove.N,$1,$(call list.idx.prev,$1,$2))
override list.remove.next       = $(call list.remove.N,$1,$(call list.idx.next,$1,$2))
override list.remove.first      = $(call list.remove.N,$1,$(call list.idx.first,$1))
override list.remove.last       = $(call list.remove.N,$1,$(call list.idx.last,$1))

override list[str].remove       = $(call list.remove,$1,$2)
override list[str].remove.prev  = $(call list.remove.prev,$1,$2)
override list[str].remove.next  = $(call list.remove.next,$1,$2)
override list[str].remove.first = $(call list.remove.first,$1)
override list[str].remove.last  = $(call list.remove.last,$1)

# list.get ============================ type: [word[type]]
override list.get.N             = $(if $2,$(word $2,$1))

override list.get               = $(call list.get.N,$1,$(call list.idx,$1,$2))
override list.get.prev          = $(call list.get.N,$1,$(call list.idx.prev,$1,$2))
override list.get.next          = $(call list.get.N,$1,$(call list.idx.next,$1,$2))
override list.get.first         = $(firstword $1)
override list.get.last          = $(lastword $1)

override list[str].get          = $(call word[str].to.str,$(call list.get,$1,$2))
override list[str].get.prev     = $(call word[str].to.str,$(call list.get.prev,$1,$2))
override list[str].get.next     = $(call word[str].to.str,$(call list.get.next,$1,$2))
override list[str].get.first    = $(call word[str].to.str,$(call list.get.first,$1))
override list[str].get.last     = $(call word[str].to.str,$(call list.get.last,$1))

# list.set ============================ type: [list[type]]
override list.set.N             = $(strip $(if $3,$(wordlist 1,$(call list.idx.dec,$1,$3),$1) $2 $(wordlist $(call list.idx.inc,$1,$3),$(words $1),$1),$1))

override list.set               = $(call list.set.N,$1,$2,$(call list.idx,$1,$3))
override list.set.prev          = $(call list.set.N,$1,$2,$(call list.idx.prev,$1,$3))
override list.set.next          = $(call list.set.N,$1,$2,$(call list.idx.next,$1,$3))
override list.set.first         = $(call list.set.N,$1,$2,$(call list.idx.first,$1))
override list.set.last          = $(call list.set.N,$1,$2,$(call list.idx.last,$1))

override list[str].set          = $(call list.set,$1,$(call str.to.word[str],$2),$3)
override list[str].set.prev     = $(call list.set.prev,$1,$(call str.to.word[str],$2),$3)
override list[str].set.next     = $(call list.set.next,$1,$(call str.to.word[str],$2),$3)
override list[str].set.first    = $(call list.set.first,$1,$(call str.to.word[str],$2))
override list[str].set.last     = $(call list.set.last,$1,$(call str.to.word[str],$2))


#===============================================================================







#===============================================================================
# MULTILINE STRINGS
#===============================================================================
# Multiline strings can be created using the 'define' directive or by inserting
# a linefeed character $n into the string definition.
# Otherwise, string definitions may span multiple lines (each line must end with
# a '\'), but in this case linefeeds are removed and leading whitespace is
# replaced with a single $s.
#
# Types:
#   str       A string containing any characters.
#   line      A single line; may contain whitespace, but no linefeeds.
#   word      A single word; no whitespace.
#   [...]     Square brackets [] specify a value which is either empty or nonempty.
#   {...}     Curly brackets {} specify a value which is always nonempty.
#-------------------------------------------------------------------------------

# [str]  <--  $(call str.foreach.line,[str:multiline],[func],[str:arg2],[str:arg3],...)
override str.foreach.line = $(if $2,$(call word[line].to.line,$(subst $s,$n,$(foreach line,$(call line.to.word[line],$1),$(call line.to.word[line],$(call $2,$(call word[line].to.line,$(line)),$3,$4,$5,$6,$7,$8,$9))))),$1)

# str = $(call str.indent.byline,{indentation},{multiline_value})
# Calls $(strip) on each line to remove leading/trailing whitespace,
# then prefixes each (nonempty) line with {indentation}.
# WARNING:
#   The $(strip) operation removes consecutive whitespace from
#   the middle of the string! Escape important whitespace with:
#     $$s $$t $$n
override str.indent.byline.lf := $n
override str.indent.byline = $1$(subst $$(str.indent.byline.lf),,$(subst $$(str.indent.byline.lf)$s,$n$1,$(strip $(subst $n$s,$$(str.indent.byline.lf)$s,$2))))
#===============================================================================






#===============================================================================
# STRING PADDING
#===============================================================================
# A [pad] is a string of zero or more '.' characters representing the
# "column width" of a string.
# - For strings without tabs or linefeeds, a [pad] is equal in length to the string.
# - Tabs are replaced with $(pad.tab) during the pad conversion.
# - Linefeeds are treated as separators; each [line] is padded individually, and
#   the resulting [pad] is equal in length to the longest [line].
#
# Example:
#   pad := ..............................
#   line := Some Text
#   $(info [$(pad)])                                    -->  [..............................]
#   $(info [$(str)])                                    -->  [Some Text]
#   $(info [$(call line.justify.right,$(line),$(pad))]) -->  [Some Text                     ]
#   $(info [$(call line.justify.left,$(line),$(pad))])  -->  [                     Some Text]
#
#-------------------------------------------------------------------------------
#
# Pad Differences:
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
#                                                             [char] defaults to $s.
#
#  [line] <-- $(call line.justify.right,[line],[pad],[char])    Same as str.pad, but optimized for various other types.
#  [line] <-- $(call line.justify.left,[line],[pad],[char])
#  [line] <-- $(call word.justify.right,[word],[pad],[char])
#  [line] <-- $(call word.justify.left,[word],[pad],[char])
#  [line] <-- $(call int.justify.right,[int],[pad],[char])
#  [line] <-- $(call int.justify.left,[int],[pad],[char])
#-------------------------------------------------------------------------------

# String Padding ====================== type: [pad]
pad.line.indent    = $(call line.to.pad,$(line.indent))
pad.tab            = $(pad.line.indent)
pad.info.prefix    = $(call line.to.pad,$(info.prefix))
pad.warning.prefix = $(call line.to.pad,$(warning.prefix))
pad.error.prefix   = $(call line.to.pad,$(error.prefix))


# Pad Differences ===================== type: [pad]
override pad.subtract.pad   = $(filter-out $1,$(1:$2%=%))
override pad.subtract.str   = $(call pad.subtract.pad,$1,$(call str.to.pad,$2))
override pad.subtract.line  = $(call pad.subtract.pad,$1,$(call line.to.pad,$2))
override pad.subtract.word  = $(call pad.subtract.pad,$1,$(call word.to.pad,$2))
override pad.subtract.int   = $(call pad.subtract.pad,$1,$(call int.to.pad,$2))
override pad.subtract.uint  = $(call pad.subtract.pad,$1,$(call uint.to.pad,$2))
override pad.subtract.idx   = $(call pad.subtract.pad,$1,$(call idx.to.pad,$2))

# Left/Right Justification ============ type: [str]
override str.justify.right  = $(call str.foreach.line,$1,line.justify.right,$(or $2,$(call str.to.pad,$1)),$3)
override str.justify.left   = $(call str.foreach.line,$1,line.justify.left,$(or $2,$(call str.to.pad,$1)),$3)

override line.justify.right = $(subst $t,$(pad.tab),$1)$(subst .,$(or $3,$s),$(call pad.subtract.str,$2,$1))
override line.justify.left  = $(subst .,$(or $3,$s),$(call pad.subtract.str,$2,$1))$(subst $t,$(pad.tab),$1)

override word.justify.right = $1$(subst .,$(or $3,$s),$(call pad.subtract.word,$2,$1))
override word.justify.left  = $(subst .,$(or $3,$s),$(call pad.subtract.word,$2,$1))$1

override int.justify.right  = $1$(subst .,$(or $3,$s),$(call pad.subtract.int,$2,$1))
override int.justify.left   = $(subst .,$(or $3,$s),$(call pad.subtract.int,$2,$1))$1

override uint.justify.right = $1$(subst .,$(or $3,$s),$(call pad.subtract.uint,$2,$1))
override uint.justify.left  = $(subst .,$(or $3,$s),$(call pad.subtract.uint,$2,$1))$1

override idx.justify.right  = $1$(subst .,$(or $3,$s),$(call pad.subtract.idx,$2,$1))
override idx.justify.left   = $(subst .,$(or $3,$s),$(call pad.subtract.idx,$2,$1))$1
#===============================================================================



#===============================================================================
# PRINTING
#===============================================================================
# Info
# $(call print.info,{msg},[indent])
# $(call print.vars,{vars},[indent],[col])
# $(call print.list,[list],[indent],[col])
# $(call print.debug,{msg},[indent])
# $(call print.trace,{msg},[indent])
# Warnings
#-------------------------------------------------------------------------------

override print.vars = $(if $2,$(if $3,$(foreach var,$1,$(call print.var,$(var),$2,$3,[,])),$(call print.vars,$1,$2,$(call print.vars.col,$1))),$(call print.vars,$1,$(line.indent),$3))

# $(call print.var,{var},{indent},{col},{prefix},{suffix})
override print.var = $(info $2$(call str.justify.left,$1,$3)=$4$(subst $n,$5$n$2$(subst .,$s,$3.)$4,$($1))$5)

# $(call print.vars.col,{vars})
override print.vars.col = $(lastword $(sort $(call str.subst.list_to_str,$(char.type.var),.,$1)))

override print.break = $(info )$(call print.vars,$1)$(info )$(error Breakpoint reached. Exiting...)

override print.debug.enable ?= false
override print.debug = $(if $(findstring $(print.debug.enable),true),$(info DEBUG: $(strip $1)))

override print.trace.enable ?= false
override print.trace = $(if $(findstring $(print.trace.enable),true),$(info $n======= $(if $(strip $1),$(strip $1),make $@) =======))

# [str]   <-- $(call str.lines.wrap,[str],[str:prefix],[str:suffix])
override str.lines.wrap = $2$(subst $n,$3$n$2,$1)$3

# [str]   <-- $(call str.info.var,[var],[col])
override str.info.var = $(if $(strip $1),$(call str.justify.left,$1,$2)=$4$(subst $n,$5$n$(subst .,$s,$2.)$4,$($1))$5)






#===============================================================================
# ERROR HANDLING
#===============================================================================
# [str] <-- $(error.prefix)          Error message line prefix
# [str] <-- $(line.indent)          Error message line indentation
#
# Error Message Strings:
#  [str] <-- $(call str.error.dynamic,[str:dynamic],[str:details])
#  [str] <-- $(call str.error.expansion,[str:expr],[str:details])
#  [str] <-- $(call str.error.call,[func],[str:details])
#  [str] <-- $(call str.error.arg,[func],[idx:argnum],[word:argspec],[str:argval],[str:details])
#  [str] <-- $(call str.error.arg.empty,[func],[idx:argnum],[word:argspec])
#  [str] <-- $(call str.error.arg.nowords,[func],[idx:argnum],[word:argspec])
#  [str] <-- $(call str.error.arg.multiline,[func],[idx:argnum],[word:argspec])
#
# Assert:
#  [empty] <-- $(assert.{N}.is.nonempty)    Throws $(error) if function argument $({N}) is [empty].
#  [empty] <-- $(assert.{N}.has.words)      Throws $(error) if function argument $({N}) has 0 words.
#  [empty] <-- $(assert.{N}.is.line)        Throws $(error) if function argument $({N}) contains linefeeds.
#  [empty] <-- $(assert.{N}.is.word)        Throws $(error) if function argument $({N}) does not have exactly 1 word.
#
#-------------------------------------------------------------------------------
# str.error =========================== type: [str]
override str.error.dynamic         = Error $(if $1,at $1,{unspecified})$(if $2,:$(subst $n,$n$(error.prefix)$(line.indent),$n$2))$n
override str.error.expansion       = $(call str.error.dynamic,$$($(or $(strip $1),...)),$2)
override str.error.call            = $(call str.error.expansion,call$(if $(strip $1),$s$(strip $1)),$2)
override str.error.arg             = $(call str.error.call,$1,Invalid argument $(if $(strip $2),$(strip $2):$s)$(if $(strip $3),$(strip $3)$s$(if $4,=$s))$(if $4,"$4")$(if $5,$(subst $n,$n$(str.error.INDENT),$n$5)))
override str.error.arg.empty       = $(call str.error.arg,$1,$2,$3,,Must be nonempty.)
override str.error.arg.nowords     = $(call str.error.arg,$1,$2,$3,,Must contain at least one word.)
override str.error.arg.multiline   = $(call str.error.arg,$1,$2,$3,,Must not contain multiple lines.)
override str.error.arg.multiword   = $(call str.error.arg,$1,$2,$3,,Must contain exactly 1 word.)

# assert ============================== type: [empty]
override assert.1.is.nonempty      = $(if $1,,$(error $(call str.error.arg.empty,$0,1)))
override assert.2.is.nonempty      = $(if $2,,$(error $(call str.error.arg.empty,$0,2)))
override assert.3.is.nonempty      = $(if $3,,$(error $(call str.error.arg.empty,$0,3)))
override assert.4.is.nonempty      = $(if $4,,$(error $(call str.error.arg.empty,$0,4)))

override assert.1.has.words        = $(if $(strip $1),,$(error $(call str.error.arg.nowords,$0,1)))
override assert.2.has.words        = $(if $(strip $2),,$(error $(call str.error.arg.nowords,$0,2)))
override assert.3.has.words        = $(if $(strip $3),,$(error $(call str.error.arg.nowords,$0,3)))
override assert.4.has.words        = $(if $(strip $4),,$(error $(call str.error.arg.nowords,$0,4)))

override assert.1.is.line          = $(if $(findstring $n,$1),$(error $(call str.error.arg.multiline,$0,1)))
override assert.2.is.line          = $(if $(findstring $n,$2),$(error $(call str.error.arg.multiline,$0,2)))
override assert.3.is.line          = $(if $(findstring $n,$3),$(error $(call str.error.arg.multiline,$0,3)))
override assert.4.is.line          = $(if $(findstring $n,$4),$(error $(call str.error.arg.multiline,$0,4)))

override assert.1.is.word          = $(if $(filter-out 1,$(words $1)),$(error $(call str.error.arg.multiword,$0,1)))
override assert.2.is.word          = $(if $(filter-out 1,$(words $2)),$(error $(call str.error.arg.multiword,$0,2)))
override assert.3.is.word          = $(if $(filter-out 1,$(words $3)),$(error $(call str.error.arg.multiword,$0,3)))
override assert.4.is.word          = $(if $(filter-out 1,$(words $4)),$(error $(call str.error.arg.multiword,$0,4)))
#===============================================================================








#===============================================================================
# FUNCTION ARGUMENTS
#===============================================================================
# Concatenate Args:
#  Concatentates each nonempty [str] argument with the given separator [sep].
#  Each [empty] argument is skipped; no separator is included for them.
#
#  [str] <-- $(call args.concat,[str:sep],[str:1],[str:2],...,[str:8])
#-------------------------------------------------------------------------------

# args.concat ========================= type: [str]
override args.concat = $(if $(or $3,$4,$5,$6,$7,$8,$9),$(call args.concat.pair,$1,$2,$(call args.concat,$1,$3,$4,$5,$6,$7,$8,$9)),$2)
override args.concat.pair = $(if $(and $2,$3),$2$1$3,$(or $2,$3))

#===============================================================================






#===============================================================================
# FILE PATHS
#===============================================================================
# $(this.filepath)
# $(this.filename)
# $(this.dirpath)
# $(this.dirname)
#-------------------------------------------------------------------------------
# Returns parts of the path to this makefile.
# Must be expanded BEFORE any "include..." statements!
# Use Simple (immediate) Expansion ':=' early in the file to ensure correct results.
# Ex:
#    filename := $(this.filename)
#-------------------------------------------------------------------------------
override this.filepath = $(abspath $(lastword $(MAKEFILE_LIST)))
override this.filename = $(notdir $(lastword $(MAKEFILE_LIST)))
override this.dirpath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
override this.dirname = $(notdir $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
#===============================================================================






#===============================================================================
# BOOLEAN LOGIC
#===============================================================================
#-------------------------------------------------------------------------------
# For use in conditional evaluation.
#
# $(call is.truthy,{val})
# $(call is.falsey,{val})
# Returns $(TRUE.m) if {val} is truthy or falsey, respectively.
# Otherwise, returns $(FALSE.m).
#
# "Truthy" values are listed in $(TRUE.l).
# "Falsey" values are listed in $(FALSE.l). Empty is also considered falsey.
#-------------------------------------------------------------------------------

# "Boolean" types that are printable
override TRUE.p := true
override FALSE.p := false

# "Boolean" types that follow make's convention for conditional evaluation
override TRUE.m := true
override FALSE.m := $e

# "Boolean" types that follow shell conventions for exitcodes (and also C language)
override TRUE.s := 0
override FALSE.s := 1

# "Boolean" types that are actually binary in the traditional sense
override TRUE.b := 1
override FALSE.b := 0

# Lists of truthy values and falsy values, for interactive purposes
override TRUE.l := TRUE True true YES Yes yes Y y 1
override FALSE.l := FALSE False false NO No no N n 0

override is.truthy = $(if $(filter $(TRUE.l),$(strip $1)),$(TRUE.m),$(FALSE.m))
override is.falsey = $(if $(filter $(FALSE.l),$(or $(strip $1),false)),$(TRUE.m),$(FALSE.m))
#===============================================================================






#===============================================================================
# NUMERICS
#===============================================================================
# Numeric Types
# [int] can be any integer; positive, negative, or 0, or the empty string.
# [uint] can be any positive integer, 0, or the empty string.
#
#-------------------------------------------------------------------------------
# Trim:
#  Removes whitespace and '+' characters from a numeric value.
#
#  [int]  <-- $(call int.trim,[int])
#  [uint] <-- $(call uint.trim,[uint])
#  [idx]  <-- $(call idx.trim,[idx])
#
#-----------------------------------------------------------
# Integer Math
#  [int]  <-- $(call int.inc,[int])        Increments [int] by 1. Returns empty if [int] is empty.
#  [int]  <-- $(call int.dec,[int])        Decrements [int] by 1. Returns empty if [int] is empty.
#  [int]  <-- $(call int.abs,[int])        Returns absolute value of [int], or empty if [int] is empty.
#  [int]  <-- $(call int.neg,[int])        Returns negation of [int], or empty if [int] is empty.
#
#-----------------------------------------------------------
# Comparison (can be replaced with $(intcmp) on Make 4.4+)
#  {bool} <-- $(call int.equ,[int],[int])  Returns true (nonempty) if the arguments are equal; false (empty) if notequal or if either argument is empty.
#  {bool} <-- $(call int.neq,[int],[int])  Returns true (nonempty) if the arguments are not equal; false (empty) if equal or if either argument is empty.
#  {bool} <-- $(call int.equ.0,[int])      Returns true (nonempty) if [int] == 0; false (empty) if [int] != 0 or if [int] is empty.
#  {bool} <-- $(call int.neq.0,[int])      Returns true (nonempty) if [int] != 0.
#  {bool} <-- $(call int.gtr.0,[int])      Returns true (nonempty) if [int] >  0.
#  {bool} <-- $(call int.geq.0,[int])      Returns true (nonempty) if [int] >= 0.
#  {bool} <-- $(call int.leq.0,[int])      Returns true (nonempty) if [int] <= 0.
#  {bool} <-- $(call int.lss.0,[int])      Returns true (nonempty) if [int] <  0.
#
#-------------------------------------------------------------------------------

# Integer Math
override int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))
override int.dec = $(if $(filter 0 -%,$1),-)$(subst .,,$(call int.$(if $(filter 0 -%,$1),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))

override int.inc.recurse = $(if $(basename $1),$(if $(1:%9=),$(basename $1)$(call digit.inc,$(suffix $1),.),$(if $1,$(call int.inc.recurse,$(basename $1)).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $1),.),$(if $1,.1.0)))
override int.dec.recurse = $(if $(basename $1),$(if $(1:%0=),$(basename $1)$(call digit.dec,$(suffix $1),.),$(if $1,$(filter-out .0,$(call int.dec.recurse,$(basename $1))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $1),.)))

# [str] <-- $(call str.digits.addprefix,[prefix],[str])
override str.digits.addprefix = $(subst 9,$19,$(subst 8,$18,$(subst 7,$17,$(subst 6,$16,$(subst 5,$15,$(subst 4,$14,$(subst 3,$13,$(subst 2,$12,$(subst 1,$11,$(subst 0,$10,$2))))))))))

# {digit} <-- $(call digit.inc,[digit],[prefix])     Over/underflow wraps to 0/9. empty is treated as digit=0.
# {digit} <-- $(call digit.dec,[digit],[prefix])
override digit.inc  = $(addprefix $2,$(word 1$(1:$2%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
override digit.dec  = $(addprefix $2,$(word 1$(1:$2%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))

override int.abs = $(1:-%=%)
override int.neg = $(if $(1:-%=),$(if $(1:0=),-$1,$1),$(1:-%=%))

# Comparison
override int.equ    = $(filter $2,$1)
override int.neq    = $(filter-out $2,$1)
override int.equ.0  = $(filter 0,$1)
#int.equ.0 = $(if $(1:0=),,true)
override int.neq.0  = $(1:0=)
override int.gtr.0  = $(filter-out 0 -%,$1)
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
override int.geq.0  = $(1:-%=)
override int.leq.0  = $(filter 0 -%,$1)
override int.lss.0  = $(filter -%,$1)
#int.lss.0 = $(if $(1:-%=),,true)


# Trim
override int.trim   = $(strip $(subst +,,$1))
override uint.trim  = $(strip $(subst +,,$1))
override idx.trim   = $(strip $(subst +,,$1))
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
#-------------------------------------------------------------------------------

# {name} := [start,0]
# {name}.next = $(eval {name} := $(if $(filter-out [end],$({name})),$(call int.inc,$({name}))))$({name})
override iter.inc.define = $(eval $1 := $(or $2,0))$(eval $1.next = $$(eval $1 := $$(if $$(filter-out $3,$$($1)),$$(call int.inc,$$($1))))$$($1))
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
# 	COMMANDS$n\
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
#     $$s
#     $$t
#
# - Terminate each command line with $n, $$n, $n\ or $$n\.
#     Line indentation is automatically corrected.
#
# Quick reference:
#	$$(basename $$@)    Name of target this pretarget belongs to
#	$$^                 List of prerequisites
#
#-------------------------------------------------------------------------------


override define target.define.template
$(subst $n$s,$n,$(foreach target,$4,$(target): $(strip $1)$n))
$(subst $n$s,$n,$(foreach target,$5,$(target): | $(strip $1)$n))
$(strip $1: $2 $(if $(strip $3),| $(strip $3)))
$(if $(strip $6),$t$(subst $$n,$n$t,$(subst $$n$s,$$n,$(strip $(subst $n,$$n$n,$(subst $$n,$n,$6))))))
endef

override target.define = $(eval $(call target.define.template,$1,$2,$3,$4,$5,$6))


#-----------------------------------------------------------
# $(call target.pre.define,{target},{prereqs},\
# 	COMMANDS$n\
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

override target.pre.define = $(call target.define,$1.pre,,,,$2,$3)


#-----------------------------------------------------------
# str = $(call str.eval,{expr})
#-----------------------------------------------------------
# Performs an additional $-expansion on a string.
#
# Example:
#   expr := $$(call ...)                     expr contains literal syntax '$(call ...)'
#   expr2 := $(call str.eval,$(expr))      expr2 contains the result of $(call ...)
#-----------------------------------------------------------

override str.eval.tmp := $e
override str.eval = $(eval str.eval.tmp := $1)$(str.eval.tmp)$(eval str.eval.tmp :=)


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

override variable.set_with_alternatives = $(eval $(strip $1) $(strip $2) $(if $(or $3,$(strip $4),$5),$$(or $(if $3,$3$c)$(subst $s,$c,$(foreach var,$(strip $4),$$($(var))))$(if $5,$c$5))))


#===============================================================================



