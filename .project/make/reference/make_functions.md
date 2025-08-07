# GNU Make - Built-In Functions

## Variable References

### `$(name)`

Normal Expansion expands to the value of a variable named `name`.

If the variable `name` contains references to other variables or
functions, those references are expanded recursively.

If `name` refers to a simply-expanded variable (assigned using `:=` or `::=`),
any references it contained were already expanded during assignment, so no
further expansion occurs.

##### Specification

```
$([var[str]:name]) --> [str]
```

##### Parameters

- `name`: Name of variable (`var[str]`), or `[empty]`.

##### Expands To

- `{str}`: The contents of the variable `name`, references expanded recursively.
- `[empty]`:
    - If `name` is omitted.
    - If the value of the variable `name` is `[empty]`.



### `$(name:match=replace)`

Substitution Expansion expands to the value of a variable,
then performs a match & replace on each word.

There are two distinct modes of operation, differentiated by whether `match`
contains the wildcard character `'%'`.


#### Wildcard Match & Replace (`match` contains `'%'`)

For each `word` in list `$(name)` matching wildcard pattern `match`,
replaces `word` with wildcard pattern `replace`.

If `match` contains no `'='` or whitespace, this expression is equivalent to:

```
$(patsubst match,replace,$(name))
```

##### Specification

```
$([list*:name]:{word.pattern:match}=[str.pattern:replace]) --> [list]
```

##### Parameters

- `name`: Name of variable to expand (`list*`), or `[empty]`.
- `match`: Single-word wildcard pattern (`word.pattern`), nonempty.
    - Cannot contain `'='` or whitespace.
    - Contains exactly one wildcard `'%'`, which matches zero or more
      characters in each `word`; as many characters as possible.
    - Before the wild `'%'`, escape each literal `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - After the wild `'%'`, all `'%'` and `'\'` are literal, and should *not* be
      escaped.
- `replace`: Replacement wildcard pattern (`str.pattern`), or `[empty]`.
    - Contains zero or one wildcard `'%'`, which is substituted
      for the value of `'%'` in each matched `word`.
    - Before the wild `'%'`, escape each literal `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - After the wild `'%'`, all `'%'` and `'\'` are literal, and should *not* be
      escaped.
    - If there is no wildcard, escape all `'%'` and `'\'`

##### Expands To

- `{list}`: Performs the match/replace operation on each word of `$(name)`
          then concatenates each nonempty result with a single space `' '`.
    - Extra whitespace added by `replace` is maintained, so the resulting `{list}`
       may have more words than the original list `$(name)`.
- `[empty]`:
    - If `name` is omitted.
    - If `$(name)` is `[empty]` or only contains whitespace.
    - If `match` matches every word in $(name) and `replace` is `[empty]`.


#### Suffix Match & Replace: When `match` does not contain `'%'`

For each `word` in list `$(name)`, if that `word` ends with suffix `match`,
that `match` is replaced with `replace`.

If `match` contains no `'='` or whitespace, this expression is equivalent to:

```
$(patsubst %match,%replace,$(name))
```

If `match` is empty, all words are matched, so this expression is equivalent to:

```
$(addsuffix match,$(name))
```

##### Specification

```
$([list*:name]:[word:match]=[str:replace]) --> [list]
```

##### Parameters

- `name`: Name of variable to expand (`list*`), or `[empty]`.
- `match`: Single-word suffix (`word`), or `[empty]`.
    - Cannot contain `'='` or whitespace.
    - Escape all `'%'` with `'\%'` and `'\'` with `'\\'`.
- `replace`: Replacement suffix (`{str}`), or `[empty]`.
    - Escape all `'%'` with `'\%'` and `'\'` with `'\\'`.

##### Expands To

- `{list}`: Performs the match/replace operation on each word of `$(name)`
          then concatenates each nonempty result with a single space `' '`.
    - Extra whitespace added by `replace` is maintained, so the resulting `{list}`
       may have more words than the original list `$(name)`.
- `[empty]`:
    - If `name` is omitted.
    - If `$(name)` is `[empty]` or only contains whitespace.





## Built-in Functions

### `$(patsubst match,replace,in)`

Performs a match & replace on `in`.

`match` may contain a wildcard `'%'`, or whitespace,
but not both!

There are two distinct modes of operation, differentiated by whether `match`
contains one word or multiple words.


#### Wildcard Match & Replace: When `$(words [match])` == 1

For each `word` in list `in`, if `word` matches wildcard pattern `match`,
replaces `word` with wildcard pattern `replace`.

##### Specification

```
$(patsubst {word.pattern:match},[str.pattern:replace],[list:in]) --> [list]
```

##### Parameters

- `match`: Single-word wildcard pattern (`word.pattern`), nonempty.
    - Contains zero or one wildcard `'%'`, which matches zero or more
      characters in each `word`; as many characters as possible.
    - Before the wild `'%'`, escape each literal `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - After the wild `'%'`, all `'%'` and `'\'` are literal, and should *not* be
      escaped.
    - If there is no wildcard, escape all `'\'`.
- `replace`: Replacement wildcard pattern (`str.pattern`), or `[empty]`.
    - Contains zero or one wildcard `'%'`, which is substituted
      for the value of `'%'` in each matched `word`.
    - Before the wild `'%'`, escape each literal `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - After the wild `'%'`, all `'%'` and `'\'` are literal, and should *not* be
      escaped.
    - If there is no wildcard, escape all `'%'` and `'\'`
- `in`: List (`{list}`) of words to operate on, or `[empty]`

##### Expands To

- `{list}`: Performs the match/replace operation on each word of list `in`,
          then concatenates each nonempty result with a single space `' '`.
    - Extra whitespace added by `replace` is maintained, so the resulting `{list}`
       may have more words than the original `in`.
- `[empty]`:
    - If `list` is `[empty]` or only contains whitespace.
    - If `match` matches every word in `in` and `replace` is `[empty]`.


#### Sublist Match & Replace: When `$(words [match])` != 1

For each sequence of `N` words in list `in`, where `N = $(words match)`,
replaces that sequence of words with `replace`.

##### Specification

```
$(patsubst [list:match],[str:replace],[list:in])   --> [list]
```

##### Parameters

- `match`: List (`{list}`) of two or more whitespace-separated words, or `[empty]`.
    - Cannot contain wildcards. Escape all `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - Cannot contain leading/trailing whitespace.
    - Whitespace between words of `match` must exactly equal whitespace
      between words of `[list]`. To ignore differences in whitespace and match
      word content only, use `$(strip match)` and `$(strip list)`.
- `replace`: Replacement wildcard pattern (`str.pattern`), or `[empty]`.
    - Cannot contain wildcards. Escape all `'%'` with `'\%'` and `'\'` with
      `'\\'`.

- `in`: List (`{list}`) of words to operate on, or `[empty]`.

##### Expands To

- `{list}`: Performs the match/replace operation on each word/sublist of `in`,
          then concatenates each nonempty result with a single space `' '`.
    - Extra whitespace added by `replace` is maintained, so the resulting `{list}`
       may have more words than the original `in`.
- `[empty]`:
    - If `list` is `[empty]` or only contains whitespace.
    - If `match` matches every word/sublist in `in` and `replace` is `[empty]`.



### `$(subst find,replace,in)`

Substitutes each occurrance of `find` in string `in` with `replace`.

##### Specification

```
$(subst [str:find],[str:replace],[str:in]) --> [str]
```

##### Parameters

- `find`: String to match within `in`, or `[empty]` to do nothing.
- `replace`: String to substitute matched substrings with, or `[empty]` to remove.
- `in`: String to search.

##### Expands To

- `{str}`: Value of `in` after substitutions.
- `[empty]`:
    - If `in` is `[empty]`
    - If `find` equals `in` and `replace` is `[empty]`



### `$(strip string)`

Normalizes whitespace.

1. Tab and Linefeed are replaced with space `' '`.
1. Consecutive spaces are replaced with a single space ' '.
1. Removes leading and trailing spaces.

##### Specification

```
$(strip [str:string]) --> [str]
```

##### Parameters

- `string`: String (`{str}`) to strip.

##### Expands To

- `{str}`: Value of `string` after whitespace removal.
- `[empty]`: If `string` is `[empty]` or only contains whitespace



### `$(findstring find,in)`

Searches for substring `find` in string `in`.

Returns `find` if `in` contains `find`; `[empty]` otherwise.

##### Specification

```
$(findstring [str:find],[str:in]) --> [str:find]
```

##### Parameters

- `find`: String (`{str}`) to search for.
- `in`: String to search.

##### Expands To

- `{str:find}`: If `in` contains `find`.
- `[empty]`:
    - If `in` does not contain `find`
    - If `find` is `[empty]`
    - If `in` is `[empty]`



### `$(filter patterns,list)`

### `$(filter-out patterns,list)`

For each `word` in `list`, keeps (`filter`) or rejects (`filter-out`) that
  `word`, if the `word` is matched by *any* pattern in `patterns`.

##### Specification

```
$(filter [list<word.pattern>:patterns],[list])     --> [list]
$(filter-out [list<word.pattern>:patterns],[list]) --> [list]
```

##### Parameters

- `patterns`: List of single-word patterns (`list<word.pattern>`)
    - Each pattern may contain zero or one wildcard `'%'`,
      which matches zero or more characters in each `word`;
      as many characters as possible.
    - Before the wild `'%'`, escape each literal `'%'` with `'\%'` and `'\'` with
      `'\\'`.
    - After the wild `'%'`, all `'%'` and `'\'` are literal, and should *not* be
      escaped.
    - If there is no wildcard in a pattern, escape all `'\'`.
- `list`: List (`{list}`) of words to operate on, or `[empty]`.

##### Expands To

- `{list}`: List of words taken from `in` which survived the `filter`/`filter-out`
          operation, each separated by a single space `' '`.
- `[empty]`:
    - If `list` is `[empty]` or only contains whitespace.
    - If `filter` is `[empty]` or only contains whitespace.
    - If no word in `list` is matched by `filter`
    - If every word in `list` is matched by `filter-out`



### `$(sort list)`

Sorts the words of `list` lexicographically.

##### Specification

```
$(sort [list]) --> [list]
```

##### Parameters

- `list`: List (`{list}`) of words to sort, or `[empty]`

##### Expands To

- `{list}`: Words taken from input `list`, sorted, each separated by a space `' '`.
- `[empty]`:
    - If `list` is `[empty]` or only contains whitespace.



### `$(words list)`

Returns the number of words in `list`.

##### Specification

```
$(words [list]) --> {uint}
```

##### Parameters

- `list`: List (`{list}`) of words, or `[empty]`.

##### Expands To

- `{uint}`: Number of words in `list`.
    - `'0'` if `list` is `[empty]` or only contains whitespace.


### `$(word n,list)`

Extracts the `n`th word from a list.

##### Specification

```
$(word {idx:n},[list]) --> [word]
```

##### Parameters

- `n`: Word index (`idx`); nonempty, nonzero, positive integer.
- `list`: List (`{list}`) of words, or `[empty]`.

##### Expands To

- `{word}`: Word at position `n` in `list`, if `1 <= n <= $(words list)`.
- `[empty]`:
    - If `n > $(words list)`
    - If `list` is `[empty]` or only contains whitespace.
- `[error]`:
    - If `n <= 0` or `n` is nonnumeric.



### `$(wordlist m,n,list)`

Extracts the `m`th through the `n`th word from a list.
Returns a [word] or stripped [list] of words by indexing a [list].
Lists are 1-indexed; first word has index 1.
Returns empty for indicies > $(words [list])
Returns empty if {idx:start} > {idx:end}.
Returns error if {idx}, {idx:start} not positive, nonempty integers.
Returns error if {uint:end} not positive, nonempty integer or 0.

##### Specification

```
$(wordlist {idx:m},{uint:n},[list]) --> [list]
```

##### Parameters

- `m`: Start index (`idx`); nonempty, nonzero, positive integer.
- `n`: End index (`uint`); nonempty, positive integer, or 0.
- `list`: List (`{list}`) of words, or `[empty]`.

##### Expands To

- `{list}`: Words from input `list`, starting from position `m` and ending at
   position `n`.
    - If `n >= m`
    - Returns `[empty]` for positions > $(words list)
- `[empty]`:
    - If `n,m > $(words list)`
    - If `n < m`
    - If `list` is `[empty]` or only contains whitespace.
- `[error]`:
    - If `m <= 0` or `m` is nonnumeric.
    - If `n < 0` or `n` is nonnumeric.



### `$(firstword list)`

### `$(lastword list)`

Returns first or last word in a list.

##### Specification

```
$(firstword [list]) --> [word]
$(lastword [list])  --> [word]
```

##### Parameters

- `list`: List (`{list}`) of words, or `[empty]`.

##### Expands To

- `[word]`: First or last `word` in `list`.
- `[empty]`:
    - If `list` is `[empty]` or only contains whitespace.



### `$(addprefix prefix,list)`

### `$(addprefix suffix,list)`

Adds `prefix` or `suffix` to the start or end of each word in `list`.

##### Specification

```
$(addprefix [str:prefix],[list]) --> [list]
$(addsuffix [str:suffix],[list]) --> [list]
```

##### Parameters

- `prefix`: String (`{str}`) to add to beginning of each word, or `[empty]`.
- `suffix`: String (`{str}`) to add to end of each word, or `[empty]`.
- `list`: List (`{list}`) of words, or `[empty]`.

##### Expands To

- `{list}`: List of words, taken from the input `list`, prefixed or suffixed, and
          concatenated with a single space `' '`.
    - Extra whitespace added by `prefix` or `suffix` is maintained, so the resulting
      `{list}` may have more words than the original `list`.
- `[empty]`:
    - If `list` is `[empty]` or contains only whitespace.



### `$(join list1,list2)`

Concatenates two lists word-for-word.

##### Specification

```
$(join [list:list1],[list:list2]) --> [list]
```

##### Parameters

- `list1`: First list (`{list}`), or `[empty]`.
- `list2`: Second list (`{list}`), or `[empty]`.

##### Expands To

- `{list}`: List of words, where each `word = [word1][word2]`.
    - word1 may be `[empty]` if `list1` has fewer words than `list2`.
    - word2 may be `[empty]` if `list2` has fewer words than `list1`.
- `[empty]`:
    - If `list1` and `list2` are both `[empty]` or contain only whitespace.



### `$(info message)`

### `$(warning message)`

### `$(error message)`

Each of these functions expands to `[empty]`,
but upon expansion causes Make to print `message` to the console.

- `$(warning)` and `$(error)`  also prints the file and line number at which
the function was expanded.
- `$(error)` exits the Make process with a numeric error code.

##### Specification

```
$(info [str:message])    --> [empty]    Effect: Prints [message]$(LF) to stdout.
$(warning [str:message]) --> [empty]    Effect: Prints [trace][message]$(LF) to stderr.
$(error [str:message])   --> [error]    Effect: Prints [trace][message]      to stderr,
                                          then kills Make process with an error code.
```

##### Parameters

- `message`: String message to print, or `[empty]`.

##### Expands To

- `[empty]`


### `$(shell command)`

Runs the shell `command`, then expands to the shell's output.
  Variable SHELL contains the path to the shell executable, and can be reassigned.
  Variable .SHELLFLAGS contains a list of flags passed to the shell.
Also sets variable .SHELLSTATUS to the numeric exit code of the shell (GNU Make 4.0+ only).
  .SHELLSTATUS == 0 (usually) indicates success; otherwise an error has occurred.
  .SHELLSTATUS == 127 (usually) indicates Make failed to start the shell process.
Error output from the shell process is not collected, but is piped to Make's stderr.
Returns empty if [command] is empty, and does not open a shell or set .SHELLSTATUS.

##### Specification

```
$(shell [str:command]) --> [str:stdout]   Effect: Runs the shell command, then sets
                                            .SHELLSTATUS to the shell's exit code.
                                            Output from `stderr` is printed.
```

##### Parameters

- `command`: String (`{str}`) containing a shell command, or `[empty]`
    - Variable `SHELL` contains the path to the shell executable.
        - Is usually set to an appropriate value by default.
        - Set path using `'/'`, not `'\'`, even on Windows.
    - Variable `.SHELLFLAGS` contains a list of flags passed to the shell
      before `command`.

##### Expands To

- `str:stdout`: String containing the non-error output of the shell command.
- `[empty]`:
    - If Make failed to start the shell.
    - If the shell did not return any non-error output.
    - If `command` is `[empty]`

##### Side Effects

- `[uint:.SHELLSTATUS]`: Variable named `.SHELLSTATUS` contains the numeric
  exit code of the most recent shell `command`. (GNU Make 4.0+ only)
    - `.SHELLSTATUS == 0` (usually) indicates success; otherwise an error has occurred.
    - `.SHELLSTATUS == 127` (usually) indicates Make failed to start the shell process.
    - `.SHELLSTATUS == empty` if no command has been run.
- `[str:stderr]`: Error output from the shell is printed to Make's `stderr`.


### `$(value name)`

If [name] is a recursively-expanded variable (assigned with '=', '?=', ':::=', 'define')
  returns the literal string used to define [name], without expanding it.
If [name] is an simply-expanded variable (assigned with ':=', '::='),
  $(value [name]) is equivalent to regular variable expansion: $([name]).

##### Specification

```
$(value [name]) --> [dynamic]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(origin name)`

Returns one of the following values:

##### Specification

```
$(origin [var]) --> {origin}
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

  'undefined'               [var] was never defined, or [var] is empty (omitted).
  'default'                 [var] has a default value assigned by Make, like 'CC'.
  'environment'             [var] is an inherited environment variable.
  'environment override'    [var] is an inherited environment variable, overriding a Makefile assignment because of the '-e' command-line option.
  'file'                    [var] is assigned in a Makefile.
  'command line'            [var] is specified via a command-line flag.
  'override'                [var] is assigned in a Makefile with the 'override' directive; it takes precidence over command-line assignment.
  'automatic'               [var] is an automatically-assigned, target-specific variable, like '@' (usually expanded as $@)



### `$(flavor name)`

Description

##### Specification

```
$(flavor [var]) --> {flavor}
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

Returns one of the following values:
  'undefined'               Variable [var] was never defined, or [var] is empty (omitted).
  'recursive'               [var] is recursively-expanded (assigned using '=', '?=', ':::=', 'define')
  'simple'                  [var] is simply-expanded (assigned using ':=', '::=')



### `$(if condition,if_true,if_false)`

Returns [is_true] if [condition] is [true] (nonempty).
Returns [is_false] if [condition] is [false] (empty).
Expands only [is_true] or [is_false], according to [condition]; never both.

##### Specification

```
$(if [true:condition],[str:is_true],[str:is_false])  --> [str]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(or condition1,condition2,...)`

Returns the first [true] (nonempty) argument.
Returns [false] (empty) if all arguments are [false].
Short-circuiting; Expands each argument in order,
  then returns immediately upon encountering the first nonempty argument.

##### Specification

```
$(or [true:1],[true:2],...)  --> [true:N]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(and condition1,condition2,...)`

Returns the first argument if all arguments are [true] (nonempty).
Returns [false] (empty) if any arguments are [false].
Short-circuiting; Expands each argument in order,
  then returns immediately upon encountering the first empty argument.

##### Specification

```
$(and [true:1],[true:2],...) --> [true:1]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(intcmp left,right,lss,equ,gtr)` (GNU Make 4.4+)

Returns [lss] if {left} < {right}.
Returns [equ] if {left} == {right}.
Returns [gtr] if {left} > {right}.
Returns {error} if {left},{right} are empty or non-integers.

##### Specification

```
$(intcmp {int:left},{int:right},[str:lss],[str:equ],[str:gtr]) --> [str]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(foreach name,list,expr)`

Substitutes each [word] in [list] with the value of [expr].
  [expr] may reference a word named [var],
  which is set for each [word] in [list] prior to expanding [expr].

##### Specification

```
$(foreach [var:word],[list],[str([var]):expr]) --> [list]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(eval syntax)`

Description

##### Specification

```
$(eval [dynamic])
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(call name,param1,param2,...)`

Description

##### Specification

```
$(call fcn[,arg1[,arg2[,...]]])
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(dir paths)`

Description

##### Specification

```
$(dir [list<word.paths>])      --> [list<word.dirs>]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(notdir paths)`

Description

##### Specification

```
$(notdir [list<word.paths>])   --> [list<word.files>]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(suffix paths)`

Description

##### Specification

```
$(suffix [list<word.paths>])   --> [list<extwords>]
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(basename paths)`

Description

##### Specification

```
$(basename [list<word.paths>]) -->
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(wildcard paths)`

Description

##### Specification

```
$(wildcard [wildcards])
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(realpath paths)`

Description

##### Specification

```
$(realpath [paths])
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(abspath paths)`

Description

##### Specification

```
$(abspath [paths])
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(file < path)`

### `$(file > path,string)`

### `$(file >> path,string)`

Description

##### Specification

```
$(file < file)
$(file > file,str)
$(file >> file,str)
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



### `$(let names,values,expr)`

Description

##### Specification

```
$(let vars,vals,expr)
```

##### Parameters

- `param`: Description
    - Details

##### Expands To

- `type`: Description
- `[empty]`:
    - If `param` is `[empty]`



