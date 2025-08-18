
# GNU Make - Type Reference

Like most scripting languages, GNU Make does not explicitly differentiate
between data types; all variables are strings. However, many contexts assert
character restrictions or formatting requirements in order to achieve a particular
result. For example, many Make functions operate on whitespace-separated lists;
Therefore, individual words cannot be empty or contain whitespace.

Rigorously defining the constitution of a "type" (such as a `list` or a `word`)
in this manner allows the
user to anticipate and mitigate edge-cases (like filenames with spaces), identify
error conditions, and design new functions around those "types" while remaining
maximally interoperable with existing functions and Makefiles.

### Definition of `type`

A `type` is a set of allowed characters and formatting requirements for a string.

The most general type is `[str]`, which may be empty or nonempty, and
may contain any characters, in any order.

### Subtypes

All other types are subsets of `[str]`; they may remove possible characters or add
formatting restrictions. Any `type` may be substituted for a more restrictive
sub-`type`, but not the other way around, similarly to how "type inheritance"
works in object-oriented languages. For example, `[word]`, which disallows
whitespace, is a subtype of `[str]` and may be used anywhere `[str]` is specified.

### Empty vs Nonempty Types

Another notable type is `[empty]`: the empty string. Since `[empty]` is such a common
value, with many uses and meanings, it is often necessary to indicate where `[empty]`
is allowed to be used:

```
 [type]             Square-bracketed types are either nonempty or [empty].
  |
  +--{type}            Braces indicate a type which is always nonempty.
  |  |
  |  +--{subtype}        Subtypes of a nonempty {type} must also be nonempty.
  |
  +--[empty]           The empty string is a subtype of every bracketed [type],
  |                   so may be used anywhere [type] is specified.
  |
  +--[subtype]         Counterpart of {subtype} which allows [empty].
      |
      +--{subtype}       Every braced {type} is a subtype of its bracketed [type].
      |
      +--[empty]
```

As shown above, type inheritance is not strictly heirarchical; a type may have
multiple parents.

The descendants of `[type]` include:

- `{type}`,     and its `{nonempty}` descendants
- `[subtype]s`, and their `[empty/nonempty]` and `{nonempty}` descendants
- `[empty]`

The descendants of `{type}` include:

- `{subtype}s`, and their `{nonempty}` descendants

## List of Types in GNU Make

Omitted:

- Nonempty (braced) types
    - For every `[type]`, there exists a subtype `{type}` which disallows `[empty]`.
    - Each nonempty `{type}` has a tree of nonempty descendants which is structurally
      identical to `[type]` but lacks `[empty]`. See above for details.
- Empty subtypes
    - `[empty]` is a subtype of every bracketed `[type]`; not just `[str]`.
- Non-heirarchical structures
    - Some types are subsets of multiple parents; for example, `[word]` is a subtype
      of `[line]` but is also a `[list]` of a single element.
    - Redundant trees are removed and indicated with `'...'`.


```
Type Name                     Inheritance                               Allowed Characters          Additional Requirements
-----------------------------------------------------------------------------------------------------------------------------------
String                        [str]                                     {*}
Empty String                  |  [empty]                                {}
Boolean                       |  [bool]                                 {*}
Logical True                  |  |  {true}                              {*}                         Must be nonempty.
                              |  |  |  {str}
                              |  |  |  |  ...
Logical False                 |  |  [false]                             {}                          Equivalent to `[empty]`.
                              |  |  |  [empty]
Single Line                   |  [line]                                 {*}-{\n}
Single Word                   |  |  [word]                              {*}-{ws}
Variable Name                 |  |  |  [var]                            {*}-{ws,#,=,:}
Variable Containing [type]    |  |  |  |  [var[type]]                   {*}-{ws,#,=,:}
Callable Function             |  |  |  |  [func]                        {*}-{ws,#,=,:}
Callable Function w/ Args     |  |  |  |  |  [func[type](...)]          {*}-{ws,#,=,:}
Variable Assignment Type      |  |  |  [flavor]                         See $(flavor)               See $(flavor)
Single-Word Pattern           |  |  |  [word.pattern]                   {*}-{ws}                    Contains zero or one wildcards '%'. See $(patsubst) for details and escape rules.
Single-Word Path Pattern      |  |  |  [word.path.pattern]              {*}-{ws,<,>,",|}            Contains zero or more wildcards '*', '?', '[...]'. See $(wildcard) for details and escape rules.
Single-Word Path              |  |  |  |  [word.path]                   {*}-{ws,<,>,",|,*,?}        System path.
Single-Word File Path         |  |  |  |  |  [word.file]                {*}-{ws,<,>,",|,*,?}        Path to a file.
Single-Word File Name         |  |  |  |  |  |  [word.filename]         {*}-{ws,<,>,",|,*,?,/,\,:}  Name of a file.
Single-Word Basename          |  |  |  |  |  |  |  [word.basename]      {*}-{ws,<,>,",|,*,?,/,\,:}  Path segment after last '/', before last '.'
Single-Word File Extension    |  |  |  |  |  |  |  |  [word.ext]        {*}-{ws,<,>,",|,*,?,/,\,:}  Path segment after last '/', after and including last '.'. Starts with '.'.
Single-Word Directory Path    |  |  |  |  |  [word.dir]                 {*}-{ws,<,>,",|,*,?}        Path to a directory. May end with '/'.
Single-Word Directory Path    |  |  |  |  |  |  [word.Dir]              {*}-{ws,<,>,",|,*,?}        Path to a directory. Does not end with '/'.
Single-Word Directory Name    |  |  |  |  |  |  |  [word.dirname]       {*}-{ws,<,>,",|,*,?,/,\}    Name of a directory. Does not end with '/'.
Integer                       |  |  |  [int]                            {0,1,2,3,4,5,6,7,8,9,-,+}   Starts with a single '-' or '+', no leading '0's.
Unsigned Integer              |  |  |  |  [uint]                        {0,1,2,3,4,5,6,7,8,9}       No leading '0's.
List Index                    |  |  |  |  |  [idx]                      {0,1,2,3,4,5,6,7,8,9}       Must be >= 1.
List                          |  [list]                                 {*}                         Contains a whitespace-separated list of words.
                              |  |  [word]
                              |  |  |  ...
String Pattern                |  [str.pattern]                          {*}                         Contains zero or more wildcards '%'. See $(patsubst) for details.
                              |  |  [word.pattern]
                              |  |  |  ...
Path Pattern                  |  [path.pattern]                         {*}-{<,>,",|}               Contains zero or more wildcards '*', '?', '[...]'. See $(wildcard) for details and escape rules.
                              |  |  [word.path.pattern]
                              |  |  |  ...
Path                          |  |  [path]                              {*}-{<,>,",|,*,?}           System path.
File Path                     |  |  |  [file]                           {*}-{<,>,",|,*,?}           Path to a file.
File Name                     |  |  |  |  [filename]                    {*}-{<,>,",|,*,?,/,\,:}     Name of a file.
Directory Path                |  |  |  [dir]                            {*}-{<,>,",|,*,?}           Path to a directory. May end with '/'.
Directory Path                |  |  |  |  [Dir]                         {*}-{<,>,",|,*,?}           Path to a directory. Does not end with '/'.
Directory Name                |  |  |  |  |  [dirname]                  {*}-{<,>,",|,*,?,/,\}       Name of a directory. Does not end with '/'.
Variable Assignment Origin    |  [origin]                               See $(origin)               See $(origin)
Shell Command                 |  [command]                              {*}                         Shell-specific syntax.
Makefile Syntax               |  [dynamic]                              {*}                         Must be valid Make syntax. See $(eval) for details.

```
