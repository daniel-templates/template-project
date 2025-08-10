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

# Digits ============================== type: {digit}
override digit.0     := 0
override digit.1     := 1
override digit.2     := 2
override digit.3     := 3
override digit.4     := 4
override digit.5     := 5
override digit.6     := 6
override digit.7     := 7
override digit.8     := 8
override digit.9     := 9

# Aliases for Common Characters ======= type: {char}
override s := $(char.space)#    Reference with '$s'
override t := $(char.tab)#      Reference with '$t'
override n := $(char.linefeed)# Reference with '$n'
override v := $(char.dollar)#   Reference with '$v'
override p := $(char.percnt)#   Reference with '$p'
override c := $(char.comma)#    Reference with '$c'
override o := $(char.period)#   Reference with '$o'

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
# TYPE CONVERSIONS
#===============================================================================
#	{word[T]} <-- $(call {type:T}.to.word[{type:T}],[T:val])
#	[T]       <-- $(call word[{type:T}].to.{type:T},[word[T]:packed_val])

override str.to.word{str}   = $(if $1,$(subst $n,$$n,$(subst $t,$$t,$(subst $s,$$s,$(subst $v,$$v,$1)))),$$e)
override word{str}.to.str   = $(subst $$v,$v,$(subst $$s,$s,$(subst $$t,$t,$(subst $$n,$n,$(subst $$e,$e,$(strip $1))))))

override list.to.word{list} = $(if $(strip $1),$(subst $s,$$s,$(subst $v,$$v,$(strip $1))),$$e)
override word{list}.to.list = $(subst $$v,$v,$(subst $$s,$s,$(subst $$e,$e,$(strip $1))))

override line.to.word{line} = $(if $1,$(subst $s,$$s,$(subst $v,$$v,$1)),$$e)
override word{line}.to.line = $(subst $$v,$v,$(subst $$s,$s,$(subst $$e,$e,$(strip $1))))

override word.to.word{word} = $(if $1,$(subst $v,$$v,$(strip $1)),$$e)
override word{word}.to.word = $(subst $$v,$v,$(subst $$e,$e,$(strip $1)))

override word{int}.to.int   = $(subst $$e,$e,$(strip $1))
override int.to.word{int}   = $(if $1,$(strip $1),$$e)

override uint.to.word{uint} = $(if $1,$(strip $1),$$e)
override word{uint}.to.uint = $(subst $$e,$e,$(strip $1))

override idx.to.word{idx}   = $(if $1,$(strip $1),$$e)
override word{idx}.to.idx   = $(subst $$e,$e,$(strip $1))

override pad.to.word{pad}   = $(if $1,$(strip $1),$$e)
override word{pad}.to.pad   = $(subst $$e,$e,$(strip $1))


#-------------------------------------------------------------------------------
# word.pack
#
#	{word[T]} <-- $(call word.pack,[type:T],[T:val])
#
#	Encodes [val] to a single nonempty {word}, or to literal '$e' if [val] is [empty].
#	Returns [val] unmodified if [type:T] is [empty]
#-------------------------------------------------------------------------------
override word.pack = $(if $1,$(call $1.to.word{$1},$2),$2)


#-------------------------------------------------------------------------------
# word.unpack
#
#	[T] <-- $(call word.unpack,[type:T],[word[T]:packed_val])
#
#	Decodes a [word[T]:packed_val], returning the original value of [val].
#	Returns [val] unmodified if [type:T] is [empty], or if [packed_val] is omitted.
#-------------------------------------------------------------------------------
override word.unpack = $(if $1,$(call word{$1}.to.$1,$2),$2)


#-------------------------------------------------------------------------------
# str.to.pad
#
#	[pad] <-- $(call str.to.list[pad],[str:lines])              For singular multiline types: Returns a [pad] equal to the length of the longest line in [str].
#	[pad] <-- $(call {T}.to.pad,[T:val])                  For all other singular types: Returns a [pad] equal to the length of [val].
#	[pad] <-- $(call list.to.list[pad],[list:vals])             For normal lists:             Returns a [pad] equal to the length of the longest [word] in [list].
#	[pad] <-- $(call list[{T}].to.pad,[list[T]:vals])     For packed-word lists:        Returns a [pad] equal to the length of the longest {T} value in [list[T]].
#-------------------------------------------------------------------------------
override str.to.pad         = $(lastword $(sort $(call str.to.list[pad],$1)))
override list.to.pad        = $(lastword $(sort $(call list.to.list[pad],$1)))
override line.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(subst $s,.,$1))
override word.to.pad        = $(call str.subst.list_to_str,$(char.type.word),.,$(strip $1))
override int.to.pad         = $(call str.subst.list_to_str,$(char.type.int),.,$(strip $1))
override uint.to.pad        = $(call str.subst.list_to_str,$(char.type.uint),.,$(strip $1))
override idx.to.pad         = $(call str.subst.list_to_str,$(char.type.idx),.,$(strip $1))
override pad.to.pad         = $(strip $1)
override str.to.list[pad]        = $(call line.to.pad,$(subst $t,$(pad.tab),$1))
override list.to.list[pad]       = $(foreach word,$1,$(call word.to.pad,$(word)))
override list[T].to.list[pad]    = $(foreach word,$2,$(call $1.to.pad,$(call word[$1].to.$1,$(word))))
override list[str].to.list[pad]  = $(call list[T].to.list[pad],str,$1)
override list[list].to.list[pad] = $(call list[T].to.list[pad],list,$1)
override list[line].to.list[pad] = $(call list[T].to.list[pad],line,$1)
override list[word].to.list[pad] = $(call list[T].to.list[pad],word,$1)
override list[int].to.list[pad]  = $(call list[T].to.list[pad],int,$1)
override list[uint].to.list[pad] = $(call list[T].to.list[pad],uint,$1)
override list[idx].to.list[pad]  = $(call list[T].to.list[pad],idx,$1)
override list[pad].to.list[pad]  = $1


#-------------------------------------------------------------------------------
# pad.to.str
#
#	[str] <-- $(call pad.to.str,[pad],[char])
#
#	Returns a sequence of [char] equal in length to [pad].
#	Uses space ' ' if [char] is omitted.
#-------------------------------------------------------------------------------
override pad.to.str = $(subst .,$(or $2,$s),$(strip $1))






#===============================================================================
# STRING MANIPULATION
#===============================================================================


#-------------------------------------------------------------------------------
# str.equ, str.neq
#
#	[str] <-- $(call str.equ,[str:1],[str:2])
#	[str] <-- $(call str.neq,[str:1],[str:2])
#
#	Returns {true} if the strings are equal (or notequal).
#-------------------------------------------------------------------------------
override str.equ = $(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(false),$(true))
override str.neq = $(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(true),$(false))


#-------------------------------------------------------------------------------
# str.concat
# str.concat.pair
#
#	[str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
#	[str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])
#
#	Concatentates each nonempty [str] argument with the given separator [sep].
#	Each [empty] argument is skipped; no separator is included for them.
#
#-------------------------------------------------------------------------------
override str.concat.pair = $(if $(and $2,$3),$2$1$3,$(or $2,$3))
override str.concat = $(if $(or $3,$4,$5,$6,$7,$8,$9),$(call str.concat.pair,$1,$2,$(call str.concat,$1,$3,$4,$5,$6,$7,$8,$9)),$2)


#-------------------------------------------------------------------------------
# str.map
#
#	[str] <-- $(call str.map,[func],[type:T],
#	                         [str:split_sep],[str:split_keep_empty],
#	                         [str:merge_sep],[str:merge_keep_empty],
#	                         [str:1],[str:2],[str:3],[str:4])
#
#	Wrapper for list.map, but operates directly on [str] instead of [list], handling the list conversions internally.
#	1. Splits each string ([1]-[4]) on [split_sep]
#	   Empty tokens are removed unless [split_keep_empty] is {true}.
#	2. If [T] is nonempty, encodes the substrings between each [split_sep] as a packed [word[T]].
#	3. Iterates over each [list[T]] in parallel.
#	   For each iteration, calls [func], unpacking each [word[{T}]] into the first 4 arguments of [func]
#	4. If [T] is nonempty, encodes the value returned by [func] as a packed [word[{T}]]
#	5. Merges the resulting list with [merge_sep], and decodes it to [str].
#	   Empty tokens are removed unless [merge_keep_empty] is {true}.
#
#-------------------------------------------------------------------------------
override str.map = $(if $1,$(call list[str].to.str,$(call list[str].map,$1,$(if $7,$(call str.to.list$(if $2,[$2]),$7,$3,$4)),$(if $8,$(call str.to.list$(if $2,[$2]),$8,$3,$4)),$(if $9,$(call str.to.list$(if $2,[$2]),$9,$3,$4)),$(if $(10),$(call str.to.list$(if $2,[$2]),$(10),$3,$4))),$5,$6))


#-------------------------------------------------------------------------------
# str.map.lines
#
#	[str] <-- $(call str.map.lines,[func],[str:1],...,[str:4])
#
#	Iterates over each line of N strings, in parallel.
#	For each iteration, calls [func], passing one line from each string.
#
#-------------------------------------------------------------------------------
override str.map.lines = $(call str.map,$1,line,$n,$(true),$n,$(true),$2,$3,$4)


#-------------------------------------------------------------------------------
# str.to.lower, str.to.upper
#
#	[lower]   <-- $(call str.to.lower,[str])
#	[upper]   <-- $(call str.to.upper,[str])
#
#	Returns [lower]-case or [upper]-case of [str].
#
#-------------------------------------------------------------------------------
override str.to.lower = $(call str.subst.list_to_list,$(char.type.upper),$(char.type.lower),$1)
override str.to.upper = $(call str.subst.list_to_list,$(char.type.lower),$(char.type.upper),$1)


#-------------------------------------------------------------------------------
# str.indent
#
#	[str] <-- $(call str.indent,[str:prefix],[str:multiline])
#
#	For each line, strips leading whitespace, then applies the [prefix]
#Calls $(strip) on each line to remove leading/trailing whitespace,
# then prefixes each (nonempty) line with.
# WARNING:
#   The $(strip) operation removes consecutive whitespace from
#   the middle of the string! Escape important whitespace with:
#     '$$s' '$$t' '$$n'
override str.indent.lf := $n
override str.indent = $1$(subst $$(str.indent.lf),,$(subst $$(str.indent.lf)$s,$n$1,$(strip $(subst $n$s,$$(str.indent.lf)$s,$2))))


#===============================================================================
# STRING SUBSTITUTION
#===============================================================================
# Arguments:        If Argument Omitted:           If Argument Provided:
#  [var:from]        Nothing is matched             Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [list{var}:from]  Nothing is matched             Matches $({var}) in [in], or matches [in] == [empty] if $({var}) == [empty]
#  [str:from]        Nothing is matched             Matches   {str}  in [in]
#  [list:from]       Nothing is matched             Matches  {word}  in [in]
#
#  [var:to]          Nothing is replaced            Replaces matches with $({var})
#  [list{var}:to]    Nothing is replaced            Replaces matches with $({var})
#  [str:to]          Replaces matches with [empty]  Replaces matches with   {str}
#  [list:to]         Replaces matches with [empty]  Replaces matches with  {word}
#
#===============================================================================


#-------------------------------------------------------------------------------
# (Internal use only)
#
#	[str] <-- $(call __str.subst.multi_to_single,[func([word:1],[str:2], [acc])],[list:1],[str:2], [str:acc])
#	[str] <-- $(call __str.subst.multi_to_multi, [func([word:1],[word:2],[acc])],[list:1],[list:2],[str:acc])
#
#-------------------------------------------------------------------------------
override __str.subst.multi_to_single = $(if $(firstword $2),$(call __str.subst.multi_to_single,$1,$(wordlist 2,$(words $2),$2),$3,$(call $1,$(firstword $2),$3,$4)),$4)
override __str.subst.multi_to_multi  = $(if $(or $(firstword $2),$(firstword $3)),$(call __str.subst.multi_to_multi,$1,$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3),$(call $1,$(firstword $2),$(firstword $3),$4)),$4)


#-------------------------------------------------------------------------------
# str.subst.(Single Match, Single Replace)
#
#	[str] <-- $(call str.subst.str_to_str,[str:from],[str:to],[str:in])
#	[str] <-- $(call str.subst.str_to_var,[str:from],[var:to],[str:in])
#	[str] <-- $(call str.subst.var_to_str,[var:from],[str:to],[str:in])
#	[str] <-- $(call str.subst.var_to_var,[var:from],[var:to],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.str_to_str   = $(if $1,$(subst $1,$2,$3),$3)
override str.subst.str_to_var   = $(if $1,$(if $2,$(subst $1,$($2),$3),$3),$3)
override str.subst.var_to_str   = $(if $1,$(if $($1),$(subst $($1),$2,$3),$(if $3,$3,$2)),$3)
override str.subst.var_to_var   = $(if $1,$(if $2,$(if $($1),$(subst $($1),$($2),$3),$(if $3,$3,$($2))),$3),$3)


#-------------------------------------------------------------------------------
# str.subst.(Multiple Match, Single Replace)
#
#	[str] <-- $(call str.subst.list_to_str,[list:from],[str:to],[str:in])
#	[str] <-- $(call str.subst.list_to_var,[list:from],[var:to],[str:in])
#	[str] <-- $(call str.subst.vars_to_str,[list{var}:from],[str:to],[str:in])
#	[str] <-- $(call str.subst.vars_to_var,[list{var}:from],[var:to],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.list_to_str  = $(call __str.subst.multi_to_single,str.subst.str_to_str,$1,$2,$3)
override str.subst.list_to_var  = $(call __str.subst.multi_to_single,str.subst.str_to_var,$1,$2,$3)
override str.subst.vars_to_str  = $(call __str.subst.multi_to_single,str.subst.var_to_str,$1,$2,$3)
override str.subst.vars_to_var  = $(call __str.subst.multi_to_single,str.subst.var_to_var,$1,$2,$3)


#-------------------------------------------------------------------------------
# str.subst.(Multiple Match, Multiple Replace)
#
#	[str] <-- $(call str.subst.list_to_list,[list:from],[list:to],[str:in])
#	[str] <-- $(call str.subst.list_to_vars,[list:from],[list{var}:to],[str:in])
#	[str] <-- $(call str.subst.vars_to_list,[list{var}:from],[list:to],[str:in])
#	[str] <-- $(call str.subst.vars_to_vars,[list{var}:from],[list{var}:to],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.list_to_list = $(call __str.subst.multi_to_multi,str.subst.str_to_str,$1,$2,$3)
override str.subst.list_to_vars = $(call __str.subst.multi_to_multi,str.subst.str_to_var,$1,$2,$3)
override str.subst.vars_to_list = $(call __str.subst.multi_to_multi,str.subst.var_to_str,$1,$2,$3)
override str.subst.vars_to_vars = $(call __str.subst.multi_to_multi,str.subst.var_to_var,$1,$2,$3)


#-------------------------------------------------------------------------------
# str.subst.(Single Match, Single Prefix)
#
#	[str] <-- $(call str.subst.str_prefix,[str:find],[str:prefix],[str:in])
#	[str] <-- $(call str.subst.var_prefix,[var:find],[str:prefix],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.str_prefix   = $(if $1,$(subst $1,$2$1,$3),$3)
override str.subst.var_prefix   = $(if $1,$(if $($1),$(subst $($1),$2$($1),$3),$(if $3,$3,$2)),$3)


#-------------------------------------------------------------------------------
# str.subst.(Multiple Match, Single Prefix)
#
#	[str] <-- $(call str.subst.list_prefix,[list:find],[str:prefix],[str:in])
#	[str] <-- $(call str.subst.vars_prefix,[list{var}:find],[str:prefix],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.list_prefix  = $(call __str.subst.multi_to_single,str.subst.str_prefix,$1,$2,$3)
override str.subst.vars_prefix  = $(call __str.subst.multi_to_single,str.subst.var_prefix,$1,$2,$3)


#-------------------------------------------------------------------------------
# str.subst.(Single Match, Single Suffix)
#
#	[str] <-- $(call str.subst.str_suffix,[str:find],[str:suffix],[str:in])
#	[str] <-- $(call str.subst.var_suffix,[var:find],[str:suffix],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.str_suffix   = $(if $1,$(subst $1,$1$2,$3),$3)
override str.subst.var_suffix   = $(if $1,$(if $($1),$(subst $($1),$($1)$2,$3),$(if $3,$3,$2)),$3)


#-------------------------------------------------------------------------------
# str.subst.(Multiple Match, Single Suffix)
#
#	[str] <-- $(call str.subst.list_suffix,[list:find],[str:suffix],[str:in])
#	[str] <-- $(call str.subst.vars_suffix,[list{var}:find],[str:suffix],[str:in])
#
#-------------------------------------------------------------------------------
override str.subst.list_suffix  = $(call __str.subst.multi_to_single,str.subst.str_suffix,$1,$2,$3)
override str.subst.vars_suffix  = $(call __str.subst.multi_to_single,str.subst.var_suffix,$1,$2,$3)







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
#	str           A string containing any characters.
#	line          A {str} containing a single line; may contain whitespace, but no linefeeds.
#	word          A {str} containing a single word; no whitespace.
#	word[type]    A packed [word} containing an escaped string of [type] (which may be {type} or [empty]).
#	                  The original value may have contained any characters allowed for that [type].
#	list          A whitespace-separated list of plain {word} values.
#	                  Operations on a plain `list` take the value of each word literally.
#	list[type]    A list of packed words, where each word is a {word[type]}.
#	                  Operations on a packed `list` transparently pack/unpack each word as-needed;
#	                  For example, `list[str].append` first escapes a nonempty {str} or [empty] value,
#	                    then appends the escaped [str] to the list as a {word[str]}.
#	idx           An integer >= 1 representing a {word}'s position in a `list`.
#	                  idx > $(words [list]) typically results in a no-op.
#	                  idx < 1 is invalid and typically throws an error.
#===============================================================================


#-------------------------------------------------------------------------------
# str.split
#
#	[list[T]] <-- $(call str.split,[type:T],[str],[str:sep],[bool:keep_empty])
#
#	Converts a string to a list.
#	1. If [T] is provided, packs [str] and [sep] to type {word[T]}.
#	2. Replaces each [sep] in [str] with space ' ', resulting in a [list].
#	3. [empty] words are removed, unless [keep_empty] is {true}
#
#-------------------------------------------------------------------------------
override str.split = $(strip $(subst $(call word.pack,$1,$3),$(if $(and $1,$4),$$e$s$$e,$s),$(call word.pack,$1,$2)))


#-------------------------------------------------------------------------------
# list.merge
#
#	[str] <-- $(call list.merge,[type:T],[list[T]],[str:sep],[bool:keep_empty])
#
#	Converts a list to a string.
#	1. Removes [empty] words from [list], unless [keep_empty] is {true}.
#	2. Replaces each space ' ' in [str] with [sep].
#	   If [T] is provided, [sep] is packed to type {word[T]} before substitution.
#	3. Unpacks result to [str]
#
#-------------------------------------------------------------------------------
override list.merge = $(call word.unpack,$1,$(subst $s,$(call word.pack,$1,$3),$(strip $(if $1,$(subst $$e,$e,$2),$2))))


#-------------------------------------------------------------------------------
# list.length
#
#	{uint:len} <-- $(call list.length,[list[T]])
#
#	Returns the number of [T] values in a list.
#	Counts both empty and nonempty [T] values.
#	To exclude packed [empty] values, use list.count.nonempty.
#-------------------------------------------------------------------------------
override list.length = $(words $1)


#-------------------------------------------------------------------------------
# list.trim
#
#	[list[T]] <-- $(call list.trim,[type:T],[list[T]])
#
#	Normalizes whitespace and removes [empty] values from a list.
#	 - For normal lists ([T]==[empty]), this is equivalent to $(strip [list]).
#	 - For packed lists ([T]!=[empty]), removes each {word} containing a packed [empty] value.
#-------------------------------------------------------------------------------
override list.trim = $(strip $(if $1,$(subst $$e,$e,$2),$2))


#-------------------------------------------------------------------------------
# list.is
#
#	[bool] <-- $(call list.is.empty,[list[T]])           $(words [list[T]]) == 0
#	[bool] <-- $(call list.is.nonempty,[list[T]])        $(words [list[T]]) != 0
#
#	Returns {true} (nonempty) if the condition is true;
#	Returns [false] (empty) if false.
#-------------------------------------------------------------------------------
override list.is.empty    = $(if $(firstword $1),,$1)
override list.is.nonempty = $(if $(firstword $1),$1)


#-------------------------------------------------------------------------------
# list.count
#
#	{uint} <-- $(call list.count,[type:T],[list[T]],[T:val])
#	{uint} <-- $(call list.count.empty,[type:T],[list[T]])
#	{uint} <-- $(call list.count.nonempty,[type:T],[list[T]])
#
#	Returns the number of values in the list equal to [val].
#-------------------------------------------------------------------------------
override list.count          = $(if $(firstword $2),,$2)
override list.count.empty    = $(if $1,$(words $(filter $$e,$2)),0)
override list.count.nonempty = $(if $1,$(words $(filter-out $$e,$2)),$(words $2))


#-------------------------------------------------------------------------------
# list.join
#
#	[list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4])
#
#	Combines N lists into 1 list[list].
#	1. Iterates over N [list[T]] in parallel.
#	2. For each set of N [word[T]], merges them into a [list[T]],
#	     and packs that list into a single-word {word[list[T]]}.
#        Shorter lists are padded with '$e'.
#	Returns the resulting list of word-packed lists: [list[list[T]]],
#	or [empty] if all lists omitted.
#
#-------------------------------------------------------------------------------
override list.join = $(strip $(if $(firstword $1$2$3$4),$(call word.pack,list,$(or $(firstword $1),$$e)$s$(or $(firstword $2),$$e)$s$(or $(firstword $3),$$e)$s$(or $(firstword $4),$$e)$s)$s$(call list.join,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2),$(wordlist 2,$(words $3),$3),$(wordlist 2,$(words $4),$4))))


#-----------------------------------------------------------
# list.map
#
#	[list[T]] <-- $(call list.map,[func[T]([T:1],[T:2],[T:3],[T:4])],
#	                              [type:T],[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4])
#
#	Maps N lists to 1 list.
#	1. Iterates over N [list[T]]s in parallel.
#	2  For each set of N [word[T]], calls [func] with each unpacked [T] value,
#	     then re-packs the result into a single-word {word[T]}.
#	Returns the list of words produced by [func]: [list[T]]
#
#-------------------------------------------------------------------------------
override list.map         = $(call list.map.recurse,$1,$e,$2,$3,$4,$5)
override list.map.recurse = $(if $(firstword $4$5$6$7),$(call list.map.recurse,$1,$(if $2,$2$s)$(call word.pack,$3,$(call $1,$(call word.unpack,$3,$(firstword $4)),$(call word.unpack,$3,$(firstword $5)),$(call word.unpack,$3,$(firstword $6)),$(call word.unpack,$3,$(firstword $7)))),$3,$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$(wordlist 2,$(words $7),$7)),$2)


#-------------------------------------------------------------------------------
# list.reduce
#
#	[str] <-- $(call list.reduce,[func[str]([str:acc],[T:1],[T:2],[T:3],[T:4])],
#	                             [str:acc],
#	                             [type:T],[list[T]:1],[list[T]:2],[list[T]:3],[list[T]:4])
#
#	Maps N lists to 1 string.
#	1. Iterates over N [list[T]]s in parallel.
#	2  For each set of N [word[T]], calls a [func] with each unpacked [T] value,
#	     and the result of the previous iteration, [acc].
#	   The result of [func] is not re-packed; it is passed to the next iteration unmodified.
#	Returns the final value of [acc] produced by [func].
#
#-------------------------------------------------------------------------------
override list.reduce = $(if $(firstword $4$5$6$7),$(call list.reduce,$1,$(call $1,$2,$(call word.unpack,$3,$(firstword $4)),$(call word.unpack,$3,$(firstword $5)),$(call word.unpack,$3,$(firstword $6)),$(call word.unpack,$3,$(firstword $7))),$3,$(wordlist 2,$(words $4),$4),$(wordlist 2,$(words $5),$5),$(wordlist 2,$(words $6),$6),$(wordlist 2,$(words $7),$7)),$2)


#-------------------------------------------------------------------------------
# list.reverse
#
#	[list[T]] <-- $(call list.reverse,[list[T]])
#
#	Reverses the order of words in a list.
#
#-------------------------------------------------------------------------------
override list.reverse = $(if $(word 2,$1),$(call list.reverse,$(wordlist 2,$(words $1),$1))$s$(firstword $1),$1)


#-------------------------------------------------------------------------------
# list.idx
#
#	[idx] <-- $(call list.idx,[list[T]],[int:idx])
#	[idx] <-- $(call list.idx.prev,[list[T]],[int:idx])
#	[idx] <-- $(call list.idx.next,[list[T]],[int:idx])
#	[idx] <-- $(call list.idx.first,[list[T]])
#	[idx] <-- $(call list.idx.last,[list[T]])
#
#	Returns [idx] if in the range [1,$(words [list])],
#	or [empty] if out-of-range, or if [list] is [empty].
#
#-------------------------------------------------------------------------------
override list.idx.dec   = $(if $2,$(words $(wordlist 2,$2,$1 +1)))# [uint] <-- clamp([uint:2]-1,0,len(list:1))
override list.idx.inc   = $(if $2,$(words $(wordlist 1,$2,$1) +1))# [uint] <-- clamp([uint:2]+1,1,len(list:1)+1)
override list.idx       = $(and $(filter-out 0,$2),$(word $2,$1),$2)
override list.idx.prev  = $(filter-out 0 $(words $1 +1),$(call list.idx.dec,$1 +1,$2))
override list.idx.next  = $(filter-out   $(words $1 +1),$(call list.idx.inc,$1   ,$2))
override list.idx.first = $(if $(firstword $1),1)
override list.idx.last  = $(filter-out 0,$(words $1))


#-------------------------------------------------------------------------------
# list.insert, list.prepend, list.append
#
#	[list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
#	[list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])
#	[list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])
#
#	Inserts the value of type [T] at [idx] in the list.
#	Word-packs [val] before storage, if necessary.
#
#-------------------------------------------------------------------------------
override list.insert.N = $(strip $(if $4,$(wordlist 1,$(call list.idx.dec,$2,$4),$2)$s$(call word.pack,$1,$3)$s$(wordlist $4,$(words $2),$2),$2))
override list.insert   = $(call list.insert.N,$1,$2,$3,$(call list.idx,$2$s$$,$4))
override list.prepend  = $(strip $(call word.pack,$1,$3) $2)
override list.append   = $(strip $2 $(call word.pack,$1,$3))


#-------------------------------------------------------------------------------
# list.remove
#
#	[list[T]] <-- $(call list.remove,[list[T]],[idx])
#	[list[T]] <-- $(call list.remove.first,[list[T]])
#	[list[T]] <-- $(call list.remove.last,[list[T]])
#
#	Removes the value at [idx] from the list.
#
#-------------------------------------------------------------------------------
override list.remove.N     = $(strip $(if $2,$(wordlist 1,$(call list.idx.dec,$1,$2),$1)$s$(wordlist $(call list.idx.inc,$1,$2),$(words $1),$1),$1))
override list.remove       = $(call list.remove.N,$1,$(call list.idx,$1,$2))
override list.remove.first = $(call list.remove.N,$1,$(call list.idx.first,$1))
override list.remove.last  = $(call list.remove.N,$1,$(call list.idx.last,$1))


#-------------------------------------------------------------------------------
# list.get
#
#	[T] <-- $(call list.get,[type:T],[list[T]],[idx])
#	[T] <-- $(call list.get.first,[type:T],list[T]])
#	[T] <-- $(call list.get.last,[type:T],list[T]])
#
#	Returns the original (unpacked) value of type [T] from [idx].
#
#-------------------------------------------------------------------------------
override list.get.N     = $(call word.unpack,$1,$(if $3,$(word $3,$2)))
override list.get       = $(call list.get.N,$1,$2,$(call list.idx,$2,$3))
override list.get.first = $(firstword $2)
override list.get.last  = $(lastword $2)


#-------------------------------------------------------------------------------
# list.set
#
#	[list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])
#	[list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])
#	[list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])
#
#	Replaces value of type [T] at [idx] with [val]
#	Word-packs [val] before storage, if necessary.
#
#-------------------------------------------------------------------------------
override list.set.N     = $(strip $(if $4,$(wordlist 1,$(call list.idx.dec,$2,$4),$2)$s$(call word.pack,$1,$3)$s$(wordlist $(call list.idx.inc,$2,$4),$(words $2),$2),$2))
override list.set       = $(call list.set.N,$1,$2,$3,$(call list.idx,$2,$4))
override list.set.first = $(call list.set.N,$1,$2,$3,$(call list.idx.first,$2))
override list.set.last  = $(call list.set.N,$1,$2,$3,$(call list.idx.last,$2))






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
#   $(info [$(call line.justify.r,$(line),$(pad))]) -->  [Some Text                     ]
#   $(info [$(call line.justify.l,$(line),$(pad))])  -->  [                     Some Text]
#
#-------------------------------------------------------------------------------
#
# Pad Differences:
#  [pad]  <-- $(call pad.diff,[pad],[pad])          Returns a [pad] equal to the difference in lengths of the two arguments.
#
# Right/Left Justification:
#  [str]  <-- $(call str.justify.r,[str],[pad],[char])      Right-pads each line of [str] with [char]s up to the length of [pad].
#  [str]  <-- $(call str.justify.l,[str],[pad],[char])       Left-pads each line of [str]. Similar to a right-justify.
#                                                             [pad] defaults to a pad the length of the longest line in [str].
#                                                             [char] defaults to $s.
#
#  [line] <-- $(call line.justify.r,[line],[pad],[char])    Same as str.pad, but optimized for various other types.
#  [line] <-- $(call line.justify.l,[line],[pad],[char])
#  [line] <-- $(call word.justify.r,[word],[pad],[char])
#  [line] <-- $(call word.justify.l,[word],[pad],[char])
#  [line] <-- $(call int.justify.r,[int],[pad],[char])
#  [line] <-- $(call int.justify.l,[int],[pad],[char])
#-------------------------------------------------------------------------------

# String Padding ====================== type: [pad]
override pad.line.indent    = $(call line.to.pad,$(line.indent))
override pad.tab            = $(pad.line.indent)
override pad.info.prefix    = $(call line.to.pad,$(info.prefix))
override pad.warning.prefix = $(call line.to.pad,$(warning.prefix))
override pad.error.prefix   = $(call line.to.pad,$(error.prefix))


# Pad Differences ===================== type: [pad]
override pad.diff           = $(filter-out $1,$(1:$2%=%))

# Left/Right Justification ============ type: [str]
override T.justify.r    = $(call pad.to.str,$(call pad.diff,$3,$(call $1.to.pad,$2)),$4)$2
override T.justify.l    = $2$(call pad.to.str,$(call pad.diff,$3,$(call $1.to.pad,$2)),$4)

override str.justify.r  = $(call pad.to.str,$(call pad.diff,$(or $2,$(call str.to.list[pad],$1)),$(call line.to.pad,$(subst $t,$(pad.tab),$1))),$3)
#override str.justify.r  = $(call str.map.byline,$1,line.justify.r,$(or $2,$(call str.to.list[pad],$1)),$3)
#override str.justify.l  = $(call str.map.byline,$1,line.justify.l,$(or $2,$(call str.to.list[pad],$1)),$3)
override line.justify.r = $(call T.justify.r,line,$1,$2,$3)
override line.justify.l = $(call T.justify.l,line,$1,$2,$3)
override word.justify.r = $(call T.justify.r,word,$(strip $1),$2,$3)
override word.justify.l = $(call T.justify.l,word,$(strip $1),$2,$3)
override int.justify.r  = $(call T.justify.r,int,$(strip $1),$2,$3)
override int.justify.l  = $(call T.justify.l,int,$(strip $1),$2,$3)
override uint.justify.r = $(call T.justify.r,uint,$(strip $1),$2,$3)
override uint.justify.l = $(call T.justify.l,uint,$(strip $1),$2,$3)
override idx.justify.r  = $(call T.justify.r,idx,$(strip $1),$2,$3)
override idx.justify.l  = $(call T.justify.l,idx,$(strip $1),$2,$3)
#===============================================================================

type := str
list := $$e item$$s2 item$$s3
val  := {NEW VAL}
idx  := 1
res  := $(call list.set,$(type),$(list),$(val),$(idx))
$(info )
$(info type = [$(type)])
$(info list = [$(list)])
$(info $s  1 = [$(call word.unpack,$(type),$(word 1,$(list)))])
$(info $s  2 = [$(call word.unpack,$(type),$(word 2,$(list)))])
$(info $s  3 = [$(call word.unpack,$(type),$(word 3,$(list)))])
$(info $s  4 = [$(call word.unpack,$(type),$(word 4,$(list)))])
$(info val  = [$(val)])
$(info idx  = [$(idx)])
$(info res  = [$(res)])
$(info $s  1 = [$(call word.unpack,$(type),$(word 1,$(res)))])
$(info $s  2 = [$(call word.unpack,$(type),$(word 2,$(res)))])
$(info $s  3 = [$(call word.unpack,$(type),$(word 3,$(res)))])
$(info $s  4 = [$(call word.unpack,$(type),$(word 4,$(res)))])
$(info )
$(error Exiting...)











str1 := [1]$n[2]$n[3]$n[4]$n[5]$n[6]$n[7]$n[8]$n[9]
str2 := $nthis is$n a multi-line$n$nstring$n
func  = $(info $s$s$s$s$0: 1=[$1], 2=[$2], 3=[$3], 4=[$4])$1="$2"
str3 := $(call str.map.lines,func,$(str1),$(str2))

$(info str1  = [$(str1)])
$(info str2  = [$(str2)])
$(info str3  = [$(str3)])
$(error Exiting...)


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
override print.var = $(info $2$(call str.justify.l,$1,$3)=$4$(subst $n,$5$n$2$(subst .,$s,$3.)$4,$($1))$5)

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
override str.info.var = $(if $(strip $1),$(call str.justify.l,$1,$2)=$4$(subst $n,$5$n$(subst .,$s,$2.)$4,$($1))$5)






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



